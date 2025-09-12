// 抽象的策略接口
import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:fast_ai/services/event_data.dart';
import 'package:fast_ai/services/app_cache.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
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
    FirebaseAnalytics.instance.logEvent(name: name, parameters: parameters);
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
    _startTimersAsync();
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
      // _startRetryTimer();
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

  // TODO:-
  String get androidURL => AppService().isDebugMode ? "" : "";

  String get iosURL => AppService().isDebugMode
      ? 'https://test-aint.fastaiapptop.com/iverson/typic/choose'
      : 'https://aint.fastaiapptop.com/applause/arisen/intuit';

  late final Dio _dio = Dio(
    BaseOptions(
      baseUrl: Platform.isAndroid ? androidURL : iosURL,
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
      final idfv = await AppService().getIdfv();
      final version = await AppService().version();
      final osVersion = await AppService().getOsVersion();
      final idfa = await AppService().getIdfa();

      if (Platform.isAndroid) {
        final gaid = await AppService().getGoogleAdId();
        final androidId = await AppService().getAndroidId();
        return {"galloway": androidId, "beijing": gaid, "dahl": deviceId};
      }

      return {
        "chicory": {
          "prostate": version,
          "helpful": Get.locale.toString(),
          "splice": deviceId,
          "farina": "mediate",
          "delphi": "mcc",
          "walden": uuid(),
        },
        "blockade": {"dusty": manufacturer, "fain": idfa},
        "halogen": {
          "scoop": DateTime.now().millisecondsSinceEpoch,
          "pyrite": idfv,
          "deportee": osVersion,
          "carabao": deviceModel,
          "cheryl": "com.fastgpt.aiup",
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
        // TODO:-
      } else {
        data["geode"] = "gulf";
        data["rubbish"] = "build/$build";
        data["nne"] = agent;
        final quaff = isLimitAdTrackingEnabled ? 'brendan' : 'hughes';
        data["quaff"] = quaff;
        data["chao"] = DateTime.now().millisecondsSinceEpoch;
        data["nairobi"] = DateTime.now().millisecondsSinceEpoch;
        data["canaan"] = DateTime.now().millisecondsSinceEpoch;
        data["meiosis"] = DateTime.now().millisecondsSinceEpoch;
        data["cellular"] = DateTime.now().millisecondsSinceEpoch;
        data["pleasure"] = DateTime.now().millisecondsSinceEpoch;
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
        // TODO:-
        data['mayhem'] = {};
      } else {
        data['ravenous'] = {};
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
        // TODO:-
        // data['swarthy'] = name;
        // // 处理自定义参数
        // params.forEach((key, value) {
        //   data['$key@tung'] = value;
        // });
      } else if (Platform.isIOS) {
        data['geode'] = name;
        // 处理自定义参数
        params.forEach((key, value) {
          data['trivium^$key'] = value;
        });
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
  dynamic get logId {
    if (Platform.isAndroid) {
      return ''; //TODO:
    } else {
      return this["chicory"]["walden"];
    }
  }
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
        title: const Text('Event Logs'),
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
                    name = Platform.isIOS ? dic["geode"] : '';
                  } catch (e) {}

                  return ListTile(
                    title: Text(
                      'eventType: ${log.eventType}',
                      style: TextStyle(color: Colors.deepOrange),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('id: ${log.id}', style: const TextStyle(color: Colors.blue)),
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
