// 抽象的策略接口
import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:adjust_sdk/adjust.dart';
import 'package:dio/dio.dart';
import 'package:fast_ai/data/event_data.dart';
import 'package:fast_ai/services/app_cache.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart' as path_provider;
import 'package:uuid/v4.dart';

import 'app_service.dart';

void logEvent(String name, {Map<String, Object>? parameters}) {
  try {
    // FirebaseAnalytics.instance.logEvent(name: name, parameters: parameters);
    // FLogEvent().logCustomEvent(name: name, params: parameters ?? {});
  } catch (e) {
    log.e('FirebaseAnalytics: $e');
  }
}

/// ----------------------------------------------------------------------
///
/// ----------------------------------------------------------------------

class AdLogService {
  static final AdLogService _instance = AdLogService._internal();
  factory AdLogService() => _instance;
  AdLogService._internal();

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

class FLogEvent {
  static final FLogEvent _instance = FLogEvent._internal();

  factory FLogEvent() => _instance;

  FLogEvent._internal() {
    _startUploadTimer();
    _startRetryTimer();
  }

  final _adLogService = AdLogService();
  Timer? _uploadTimer;
  Timer? _retryTimer;

  void _startUploadTimer() {
    _uploadTimer?.cancel();
    _uploadTimer = Timer.periodic(const Duration(seconds: 10), (timer) {
      _uploadPendingLogs();
    });
  }

  void _startRetryTimer() {
    _retryTimer?.cancel();
    _retryTimer = Timer.periodic(const Duration(seconds: 30), (timer) {
      _retryFailedLogs();
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
    final deviceId = await AppCache().phoneId(isOrigin: true);
    final deviceModel = await AppService().getDeviceModel();
    final manufacturer = await AppService().getDeviceManufacturer();
    final idfv = await Adjust.getIdfv();
    final version = await AppService().version();
    final os = Platform.isIOS ? 'ibis' : 'behead';
    final osVersion = await AppService().getOsVersion();
    final gaid = Platform.isAndroid ? await Adjust.getGoogleAdId() : null;

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
      final logs = await _adLogService.getUnuploadedLogs();
      if (logs.isEmpty) return;

      final List<dynamic> dataList = logs.map((log) => jsonDecode(log.data)).toList();

      // // 打印 url
      // log.d('[ad]log logCustomEvent url: ${_dio.options.baseUrl}');
      // // 打印 datalist json 字符串
      // log.d('[ad]log logCustomEvent dataList: ${jsonEncode(dataList)}');

      final res = await _dio.post('', data: dataList);

      if (res.statusCode == 200) {
        await _adLogService.markLogsAsSuccess(logs);
        log.d('[ad]log Batch upload success: ${logs.length} logs');
      } else {
        log.e('[ad]log Batch upload error: ${res.statusMessage}');
      }
    } catch (e) {
      log.e('[ad]log Batch upload catch: $e');
    }
  }

  Future<void> _retryFailedLogs() async {
    try {
      final failedLogs = await _adLogService.getFailedLogs();
      if (failedLogs.isEmpty) return;

      final List<dynamic> dataList = failedLogs.map((log) => jsonDecode(log.data)).toList();
      final res = await _dio.post('', data: dataList);

      if (res.statusCode == 200) {
        await _adLogService.markLogsAsSuccess(failedLogs);
        log.d('[ad]log Retry success for: ${failedLogs.length}');
      } else {
        final ids = failedLogs.map((e) => e.id).toList();
        log.e('[ad]log Retry failed for: $ids');
      }
    } catch (e) {
      log.e('[ad]log Retry failed catch: $e');
    }
  }
}

extension Clannish on Map<String, dynamic> {
  dynamic get logId => Platform.isAndroid ? this['kumquat']['clannish'] : this["godson"]["day"];
}
