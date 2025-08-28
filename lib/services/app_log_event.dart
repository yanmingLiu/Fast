// 抽象的策略接口
import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:fast_ai/data/event_data.dart';
import 'package:fast_ai/services/app_cache.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart' as path_provider;
import 'package:uuid/v4.dart';

import 'app_service.dart';

void logEvent(String name, {Map<String, Object>? parameters}) {
  try {
    log.d('[logEvent]: $name, $parameters');
    // FirebaseAnalytics.instance.logEvent(name: name, parameters: parameters);
    AppLogEvent().logCustomEvent(name: name, params: parameters ?? {});
  } catch (e) {
    log.e('FirebaseAnalytics: $e');
  }
}

/// ----------------------------------------------------------------------
///
/// ----------------------------------------------------------------------

/// 日志数据库服务
class LogEventDBService {
  static final LogEventDBService _instance = LogEventDBService._internal();
  factory LogEventDBService() => _instance;
  LogEventDBService._internal();

  static Box<EventData>? _box;
  static const String boxName = 'events_logs';

  Future<Box<EventData>> get box async {
    if (_box != null) return _box!;
    _box = await _initBox();
    return _box!;
  }

  Future<Box<EventData>> _initBox() async {
    final appDocumentDir = await path_provider.getApplicationDocumentsDirectory();
    Hive.init(appDocumentDir.path);
    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(EventDataAdapter());
    }
    return await Hive.openBox<EventData>(boxName);
  }

  Future<void> insertLog(EventData log) async {
    final box = await this.box;
    return await box.put(log.id, log);
  }

  Future<List<EventData>> getUnuploadedLogs({int limit = 10}) async {
    final box = await this.box;
    return box.values.where((log) => !log.isUploaded).take(limit).toList();
  }

  Future<List<EventData>> getFailedLogs({int limit = 10}) async {
    final box = await this.box;
    return box.values.where((log) => !log.isSuccess).take(limit).toList();
  }

  Future<void> markLogsAsSuccess(List<EventData> logs) async {
    final box = await this.box;
    final now = DateTime.now().millisecondsSinceEpoch;
    try {
      for (final log in logs) {
        final updatedLog = EventData(
          id: log.id,
          eventType: log.eventType,
          data: log.data,
          isSuccess: true,
          createTime: log.createTime,
          uploadTime: now,
          isUploaded: true,
        );
        await box.put(log.id, updatedLog);
      }
    } catch (e) {
      throw Exception('Failed to update logs: $e');
    }
  }
}

class AppLogEvent {
  static final AppLogEvent _instance = AppLogEvent._internal();

  factory AppLogEvent() => _instance;

  AppLogEvent._internal() {
    // _startTimersAsync();
  }

  final _adLogService = LogEventDBService();
  Timer? _uploadTimer;
  Timer? _retryTimer;
  bool _isProcessingUpload = false;
  bool _isProcessingRetry = false;

  /// 异步启动定时器，避免阻塞应用启动
  void _startTimersAsync() {
    // 使用微任务延迟执行，避免阻塞当前调用栈
    scheduleMicrotask(() {
      _startUploadTimer();
      _startRetryTimer();
    });
  }

  void _startUploadTimer() {
    _uploadTimer?.cancel();
    _uploadTimer = Timer.periodic(const Duration(seconds: 10), (timer) {
      // 防止重复执行，避免并发问题
      if (!_isProcessingUpload) {
        _uploadPendingLogsAsync();
      }
    });
  }

  void _startRetryTimer() {
    _retryTimer?.cancel();
    _retryTimer = Timer.periodic(const Duration(seconds: 30), (timer) {
      // 防止重复执行，避免并发问题
      if (!_isProcessingRetry) {
        _retryFailedLogsAsync();
      }
    });
  }

  /// 异步执行上传操作，避免阻塞定时器
  void _uploadPendingLogsAsync() {
    // 使用微任务异步执行，避免阻塞定时器回调
    scheduleMicrotask(() async {
      try {
        _isProcessingUpload = true;
        await _uploadPendingLogs();
      } catch (e) {
        log.e('[ad]log _uploadPendingLogsAsync error: $e');
      } finally {
        _isProcessingUpload = false;
      }
    });
  }

  /// 异步执行重试操作，避免阻塞定时器
  void _retryFailedLogsAsync() {
    // 使用微任务异步执行，避免阻塞定时器回调
    scheduleMicrotask(() async {
      try {
        _isProcessingRetry = true;
        await _retryFailedLogs();
      } catch (e) {
        log.e('[ad]log _retryFailedLogsAsync error: $e');
      } finally {
        _isProcessingRetry = false;
      }
    });
  }

  String get androidBurl => AppService().isDebugMode
      ? "https://test-cabin.kiraassociates.com/blimp/blare"
      : "https://cabin.kiraassociates.com/cohere/werent/conduct";

  late final Dio _dio = Dio(
    BaseOptions(
      baseUrl: Platform.isAndroid
          ? androidBurl
          : AppService().isDebugMode
          ? 'https://test-dominion.kiraassociates.com/bravery/obdurate'
          : 'https://dominion.kiraassociates.com/marmoset/indulge/final',
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      headers: {'Content-Type': 'application/json', 'Accept': 'application/json'},
    ),
  );

  String uuid() {
    String uuid = const UuidV4().generate();
    return uuid;
  }

  // 获取通用参数
  Future<Map<String, dynamic>?> _getCommonParams() async {
    try {
      final deviceId = await AppCache().phoneId(isOrigin: true);
      final deviceModel = await AppService().getDeviceModel();
      final manufacturer = await AppService().getDeviceManufacturer();
      final idfv = await AppService().getIdfv(); // 使用AppService的安全方法
      final version = await AppService().version();
      final os = Platform.isIOS ? 'ibis' : 'behead';
      final osVersion = await AppService().getOsVersion();

      // 使用AppService的安全方法获取Google AdId
      final gaid = Platform.isAndroid
          ? await AppService().getGoogleAdId().timeout(
              const Duration(seconds: 5),
              onTimeout: () {
                log.w('_getCommonParams: Google AdId获取超时，使用空值');
                return '';
              },
            )
          : null;

      if (Platform.isAndroid) {
        return {
          "cowhand": {"highball": manufacturer, "erosible": Get.locale.toString()},
          "shire": {
            "beijing": deviceModel,
            "dahl": deviceId,
            "tantric": "mcc",
            "ligament": DateTime.now().millisecondsSinceEpoch,
          },
          "kumquat": {
            "clannish": uuid(),
            "stood": deviceId,
            "nauseum": "agate",
            "wehr": "com.dream.kirasay",
            "staccato": osVersion,
          },
          "rest": {"oncoming": version},
        };
      }

      return {
        "godson": {
          "regina": deviceId,
          "day": uuid(),
          "folktale": deviceModel,
          "erode": Get.locale.toString(),
          "flaunt": manufacturer,
          "chasm": idfv,
        },
        "avis": {"stirling": version, "grille": os, "kovacs": "mcc"},
        "ladle": {"mystify": "com.rolekria.chat", "totem": DateTime.now().millisecondsSinceEpoch},
        "franca": {
          "innovate": Platform.isAndroid ? deviceId : null,
          "razor": gaid,
          "czarina": osVersion,
        },
      };
    } catch (e) {
      log.e('_getCommonParams error: $e');
      return null;
    }
  }

  Future<void> logInstallEvent() async {
    try {
      var data = await _getCommonParams() ?? {};

      final build = await AppService().buildNumber();
      final isLimitAdTrackingEnabled = await AppService().isLimitAdTrackingEnabled();
      final agent =
          "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/103.0.0.0 Safari/537.36";

      if (Platform.isAndroid) {
        final pour = isLimitAdTrackingEnabled ? 'gsa' : 'barb';

        data["abc"] = {
          "jogging": "build.$build",
          "act": agent,
          "hopkins": pour,
          "pan": DateTime.now().millisecondsSinceEpoch,
          "paycheck": DateTime.now().millisecondsSinceEpoch,
          "sterno": DateTime.now().millisecondsSinceEpoch,
          "hilt": DateTime.now().millisecondsSinceEpoch,
          "nob": DateTime.now().millisecondsSinceEpoch,
          "cockpit": DateTime.now().millisecondsSinceEpoch,
        };
      } else {
        final pour = isLimitAdTrackingEnabled ? 'adjust' : 'gherkin';

        var params = {
          "priam": {
            "hilarity": "build.$build",
            "incest":
                "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/103.0.0.0 Safari/537.36",
            "pour": pour,
            "incant": DateTime.now().millisecondsSinceEpoch,
            "rangy": DateTime.now().millisecondsSinceEpoch,
            "ink": DateTime.now().millisecondsSinceEpoch,
            "weasel": DateTime.now().millisecondsSinceEpoch,
            "dirt": DateTime.now().millisecondsSinceEpoch,
            "sticky": DateTime.now().millisecondsSinceEpoch,
          },
        };
        data.addAll(params);
      }

      final logModel = EventData(
        eventType: 'install',
        data: jsonEncode(data),
        createTime: DateTime.now().millisecondsSinceEpoch,
        id: uuid(),
      );
      await _adLogService.insertLog(logModel);
      log.d('[ad]log InstallEvent saved to database');
    } catch (e) {
      log.e('[ad]log logEvent error: $e');
    }
  }

  Future<void> logSessionEvent() async {
    try {
      var data = await _getCommonParams();

      if (data == null) {
        return;
      }

      if (Platform.isAndroid) {
        data['mayhem'] = {};
      } else {
        data['wow'] = "poet";
      }

      final logModel = EventData(
        id: data.logId,
        eventType: 'session',
        data: jsonEncode(data),
        createTime: DateTime.now().millisecondsSinceEpoch,
      );
      await _adLogService.insertLog(logModel);
      log.d('[ad]log logSessionEvent saved to database');
    } catch (e) {
      log.e('logEvent error: $e');
    }
  }

  Future<void> logCustomEvent({required String name, required Map<String, dynamic> params}) async {
    try {
      var data = await _getCommonParams();
      if (data == null) {
        return;
      }
      if (Platform.isAndroid) {
        data['swarthy'] = name;
        // 处理自定义参数
        params.forEach((key, value) {
          data['$key@tung'] = value;
        });
      } else if (Platform.isIOS) {
        data['wow'] = name;
        data['solve'] = params;
      }

      final logModel = EventData(
        eventType: 'custom',
        data: jsonEncode(data),
        createTime: DateTime.now().millisecondsSinceEpoch,
        id: data.logId,
      );
      await _adLogService.insertLog(logModel);
      log.d('[ad]log logCustomEvent saved to database');
    } catch (e) {
      log.e('[ad]log logCustomEvent error: $e');
    }
  }

  Future<void> _uploadPendingLogs() async {
    try {
      final logs = await _adLogService.getUnuploadedLogs().timeout(
        const Duration(seconds: 5),
        onTimeout: () {
          log.w('[ad]log getUnuploadedLogs timeout, returning empty list');
          return <EventData>[];
        },
      );

      if (logs.isEmpty) return;

      final List<dynamic> dataList = logs.map((log) => jsonDecode(log.data)).toList();

      // 添加超时控制，避免网络请求卡住应用
      final res = await _dio
          .post('', data: dataList)
          .timeout(
            const Duration(seconds: 15),
            onTimeout: () {
              log.w('[ad]log Upload request timeout');
              throw TimeoutException('Upload request timeout', const Duration(seconds: 15));
            },
          );

      if (res.statusCode == 200) {
        await _adLogService
            .markLogsAsSuccess(logs)
            .timeout(
              const Duration(seconds: 5),
              onTimeout: () {
                log.w('[ad]log markLogsAsSuccess timeout');
                throw TimeoutException('markLogsAsSuccess timeout', const Duration(seconds: 5));
              },
            );
        log.d('[ad]log Batch upload success: ${logs.length} logs');
      } else {
        log.e('[ad]log Batch upload error: ${res.statusMessage}');
      }
    } catch (e) {
      log.e('[ad]log Batch upload catch: $e');
      // 网络错误不应影响应用正常运行，仅记录日志
    }
  }

  Future<void> _retryFailedLogs() async {
    try {
      final failedLogs = await _adLogService.getFailedLogs().timeout(
        const Duration(seconds: 5),
        onTimeout: () {
          log.w('[ad]log getFailedLogs timeout, returning empty list');
          return <EventData>[];
        },
      );

      if (failedLogs.isEmpty) return;

      final List<dynamic> dataList = failedLogs.map((log) => jsonDecode(log.data)).toList();

      // 添加超时控制，避免网络请求卡住应用
      final res = await _dio
          .post('', data: dataList)
          .timeout(
            const Duration(seconds: 15),
            onTimeout: () {
              log.w('[ad]log Retry request timeout');
              throw TimeoutException('Retry request timeout', const Duration(seconds: 15));
            },
          );

      if (res.statusCode == 200) {
        await _adLogService
            .markLogsAsSuccess(failedLogs)
            .timeout(
              const Duration(seconds: 5),
              onTimeout: () {
                log.w('[ad]log markLogsAsSuccess timeout in retry');
                throw TimeoutException('markLogsAsSuccess timeout', const Duration(seconds: 5));
              },
            );
        log.d('[ad]log Retry success for: ${failedLogs.length}');
      } else {
        final ids = failedLogs.map((e) => e.id).toList();
        log.e('[ad]log Retry failed for: $ids');
      }
    } catch (e) {
      log.e('[ad]log Retry failed catch: $e');
      // 重试失败不应影响应用正常运行，仅记录日志
    }
  }

  /// 停止所有定时器，用于应用退出时清理资源
  void dispose() {
    _uploadTimer?.cancel();
    _retryTimer?.cancel();
    _uploadTimer = null;
    _retryTimer = null;
    log.d('[ad]log AppLogEvent disposed');
  }
}

extension Clannish on Map<String, dynamic> {
  dynamic get logId => Platform.isAndroid ? this['kumquat']['clannish'] : this["godson"]["day"];
}

class LogPage extends StatefulWidget {
  const LogPage({super.key});

  @override
  State<LogPage> createState() => _LogPageState();
}

class _LogPageState extends State<LogPage> {
  final _adLogService = LogEventDBService();
  List<EventData> _logs = [];
  bool _isLoading = true;
  String _filterType = 'all'; // all, pending, failed

  @override
  void initState() {
    super.initState();
    _loadLogs();
  }

  Future<void> _loadLogs() async {
    setState(() => _isLoading = true);
    try {
      final box = await _adLogService.box;
      var logs = box.values.toList();

      // Apply filter
      switch (_filterType) {
        case 'pending':
          logs = logs.where((log) => !log.isUploaded).toList();
          break;
        case 'failed':
          logs = logs.where((log) => !log.isSuccess).toList();
          break;
      }

      // Sort by createTime descending
      logs.sort((a, b) => b.createTime.compareTo(a.createTime));

      setState(() {
        _logs = logs;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      Get.snackbar('Error', 'Failed to load logs');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ad Logs'),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              setState(() => _filterType = value);
              _loadLogs();
            },
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'all', child: Text('All Logs')),
              const PopupMenuItem(value: 'pending', child: Text('Pending Logs')),
              const PopupMenuItem(value: 'failed', child: Text('Failed Logs')),
            ],
            child: const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Icon(Icons.filter_list),
            ),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _logs.isEmpty
          ? const Center(child: Text('No logs found'))
          : RefreshIndicator(
              onRefresh: _loadLogs,
              color: Colors.blue,
              child: ListView.builder(
                itemCount: _logs.length,
                itemBuilder: (context, index) {
                  final log = _logs[index];

                  var name = '';
                  try {
                    var dic = jsonDecode(log.data);
                    name = dic["wow"];
                  } catch (e) {}

                  return ListTile(
                    title: Text('Event: ${log.eventType}'),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('id: ${log.id}', style: const TextStyle(color: Colors.blue)),
                        if (name.isNotEmpty)
                          Text('name: $name', style: const TextStyle(color: Colors.blue)),
                        Text('Created: ${DateTime.fromMillisecondsSinceEpoch(log.createTime)}'),
                        if (log.uploadTime != null)
                          Text('Uploaded: ${DateTime.fromMillisecondsSinceEpoch(log.uploadTime!)}'),
                        Row(
                          children: [
                            Icon(
                              log.isUploaded ? Icons.cloud_done : Icons.cloud_upload,
                              color: log.isUploaded ? Colors.green : Colors.orange,
                              size: 16,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              log.isUploaded ? 'Uploaded' : 'Pending',
                              style: TextStyle(
                                color: log.isUploaded ? Colors.green : Colors.orange,
                              ),
                            ),
                            const SizedBox(width: 8),
                            if (log.isUploaded)
                              Icon(
                                log.isSuccess ? Icons.check_circle : Icons.error,
                                color: log.isSuccess ? Colors.green : Colors.red,
                                size: 16,
                              ),
                            const SizedBox(width: 4),
                            if (log.isUploaded)
                              Text(
                                log.isSuccess ? 'Success' : 'Failed',
                                style: TextStyle(color: log.isSuccess ? Colors.green : Colors.red),
                              ),
                          ],
                        ),
                      ],
                    ),
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: Text('Log Details - ${log.eventType}'),
                          content: SingleChildScrollView(
                            child: SelectableText(log.data), // 替换为SelectableText
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text('Close'),
                            ),
                            IconButton(
                              icon: const Icon(Icons.content_copy),
                              onPressed: () {
                                Clipboard.setData(ClipboardData(text: log.data));
                                Get.snackbar('Copied', 'Log data copied to clipboard');
                              },
                            ),
                          ],
                        ),
                      );
                    },
                  );
                },
              ),
            ),
    );
  }
}
