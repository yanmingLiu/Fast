import 'dart:async';
import 'dart:io';

import 'package:adjust_sdk/adjust.dart';
import 'package:adjust_sdk/adjust_config.dart';
import 'package:android_id/android_id.dart';
import 'package:app_tracking_transparency/app_tracking_transparency.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:fast_ai/services/api_service.dart';
import 'package:fast_ai/services/app_cache.dart';
import 'package:fast_ai/services/audio_manager.dart';
import 'package:fast_ai/services/network_service.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:logger/web.dart';
import 'package:package_info_plus/package_info_plus.dart';

enum Environment { dev, prod }

final log = Logger(printer: PrettyPrinter(methodCount: 0));

class AppService {
  static AppService? _instance;

  factory AppService() {
    _instance ??= AppService._internal();
    return _instance!;
  }

  AppService._internal();

  final Map<Environment, Map<String, dynamic>> _envConfig = {
    Environment.dev: {
      'baseUrl': 'https://liuhaipeng3.powerfulclean.net/release',
      'isDebugMode': true,
      'bundleId': 'com.dev.fast',
    },
    Environment.prod: Platform.isIOS
        ? {
            'baseUrl': 'https://server.aifastapp.com/release',
            'isDebugMode': false,
            'bundleId': 'com.fastgpt.aiup',
          }
        : {
            'baseUrl': 'https://server.aifastapp.com/release',
            'isDebugMode': false,
            'bundleId': 'com.qqchat.fast',
          },
  };

  // 平台
  String get platform => Platform.isIOS ? 'fast' : 'fast-android';
  String bundleId = '';
  static const prefix = 'release';

  static const String privacy = 'https://fastaiapptop.com/privacy/';
  static const terms = 'https://fastaiapptop.com/terms/';
  static const email = 'fastaiup@proton.me';

  late String baseUrl;
  late String apiKey;
  late bool isDebugMode;

  int maxFreeChatCount = 50;
  int showClothingCount = 5;

  /// 初始化方法，根据环境加载配置
  void init({required Environment env}) {
    final config = _envConfig[env]!;
    baseUrl = config['baseUrl'];
    isDebugMode = config['isDebugMode'];
    bundleId = config['bundleId'];

    ApiService().init(baseUrl: baseUrl);
  }

  Future start() async {
    // 初始化 GetStorage
    await GetStorage.init();

    await Get.putAsync<NetworkService>(() => NetworkService().init());

    // 初始化全局音频管理器
    Get.put(AudioManager.instance, permanent: true);
    log.d('[AudioManager]: 全局音频管理器初始化完成 ✅');

    await initAdjust();
    await initFirebase();
  }

  // Adjust 初始化
  Future<void> initAdjust() async {
    try {
      String deviceId = await AppCache().phoneId(isOrigin: true);
      String appToken = 'z44jxzaw8934';
      AdjustEnvironment env = AdjustEnvironment.production;

      AdjustConfig config = AdjustConfig(appToken, env)
        ..logLevel = AdjustLogLevel.error
        ..externalDeviceId = deviceId;
      Adjust.initSdk(config);
      log.d('[Adjust]: initializing ✅');
    } catch (e) {
      log.e('[Adjust] catch: $e');
    }
  }

  // Firebase 初始化
  Future<void> initFirebase() async {
    try {
      FirebaseApp app = await Firebase.initializeApp();
      log.d('[Firebase]: Initialized ✅ app: ${app.name}');

      // 分步初始化Firebase服务，确保核心服务先启动
      _initFirebaseAnalytics();
      _initRemoteConfig();
    } catch (e) {
      log.e('[Firebase]: 初始化失败 : $e');
      // 即使Firebase初始化失败，也不应该影响应用启动
    }
  }

  // 初始化Firebase Analytics（核心服务）
  Future<void> _initFirebaseAnalytics() async {
    try {
      FirebaseAnalytics.instance.setAnalyticsCollectionEnabled(true);
      log.d('[Firebase]: Analytics initialized ✅');
    } catch (e) {
      log.e('[Firebase]: Analytics 初始化失败: $e');
    }
  }

  // 初始化 Firebase Remote Config 服务
  Future<void> _initRemoteConfig() async {
    try {
      final remoteConfig = FirebaseRemoteConfig.instance;
      // 配置最小 fetch 时间，测试时设置为 0
      await remoteConfig.setConfigSettings(
        RemoteConfigSettings(
          fetchTimeout: const Duration(seconds: 5),
          minimumFetchInterval: const Duration(seconds: 30),
        ),
      );

      // 拉取 + 激活远程配置
      await remoteConfig.fetchAndActivate();

      // 获取配置值
      maxFreeChatCount = _getConfigValue('free_chat_count', remoteConfig.getInt, 50);
      showClothingCount = _getConfigValue('show_clothing_count', remoteConfig.getInt, 5);
    } catch (e) {
      log.e("Remote Config 错误: $e");
    }
  }

  // 获取配置值
  T _getConfigValue<T>(String key, T Function(String) fetcher, T defaultValue) {
    final value = fetcher(key);
    if ((value is String && value.isNotEmpty) || (value is int && value != 0)) {
      return value;
    }
    return defaultValue;
  }

  /*---------------------------------------*/

  Future<PackageInfo> packageInfo() async {
    return await PackageInfo.fromPlatform();
  }

  Future<String> version() async {
    return (await packageInfo()).version;
  }

  Future<String> buildNumber() async {
    return (await packageInfo()).buildNumber;
  }

  Future<String> packageName() async {
    return (await packageInfo()).packageName;
  }

  Future<String> getIdfa() async {
    if (!Platform.isIOS) {
      return '';
    }
    try {
      final status = await AppTrackingTransparency.trackingAuthorizationStatus;
      log.d('trackingAuthorizationStatus: $status');

      if (status == TrackingStatus.notDetermined) {
        await Future.delayed(const Duration(milliseconds: 200));
        await AppTrackingTransparency.requestTrackingAuthorization();
      }
      final idfa = await AppTrackingTransparency.getAdvertisingIdentifier();
      log.d('idfa: $idfa');
      return idfa;
    } catch (e) {
      log.e('getIdfa error: $e');
      return '';
    }
  }

  /// android_id
  Future<String> getAndroidId() async {
    try {
      final String? androidId = await AndroidId().getId();
      return androidId ?? '';
    } catch (e) {
      log.e('getAndroidId error: $e');
      return '';
    }
  }

  // 获取Adjust ID，带超时和错误处理
  Future<String> getAdid() async {
    try {
      final adid = await Adjust.getAdid().timeout(
        const Duration(seconds: 2),
        onTimeout: () {
          log.w('getAdid: 获取超时，返回空值');
          return '';
        },
      );
      return adid ?? '';
    } catch (e) {
      log.e('getAdid error: $e');
      return '';
    }
  }

  // 获取Google AdId，带超时和错误处理
  Future<String> getGoogleAdId() async {
    if (!Platform.isIOS) {
      return '';
    }
    try {
      final gpsAdid = await Adjust.getGoogleAdId().timeout(
        const Duration(seconds: 2),
        onTimeout: () {
          log.w('getGoogleAdId: 获取超时，返回空值');
          return '';
        },
      );
      return gpsAdid ?? '';
    } catch (e) {
      log.e('getGoogleAdId error: $e');
      return '';
    }
  }

  // 获取idfv
  Future<String> getIdfv() async {
    if (!Platform.isIOS) {
      return '';
    }
    try {
      final DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
      final iosInfo = await deviceInfo.iosInfo;
      return iosInfo.identifierForVendor ?? '';
    } catch (e) {
      log.e('getIdfv error: $e');
      return '';
    }
  }

  // 获取Adjust IDFV（备用方法）
  Future<String> getAdjustIdfv() async {
    try {
      final idfv = await Adjust.getIdfv().timeout(
        const Duration(seconds: 5),
        onTimeout: () {
          log.w('getAdjustIdfv: 获取超时，使用空值');
          return '';
        },
      );
      return idfv ?? '';
    } catch (e) {
      log.e('getAdjustIdfv error: $e');
      return '';
    }
  }

  // device_model
  Future<String> getDeviceModel() async {
    if (Platform.isAndroid) {
      final DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
      final androidInfo = await deviceInfo.androidInfo;
      return androidInfo.model;
    }
    if (Platform.isIOS) {
      final DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
      final iosInfo = await deviceInfo.iosInfo;
      return iosInfo.utsname.machine;
    }
    return '';
  }

  // 手机厂商
  Future<String> getDeviceManufacturer() async {
    if (Platform.isAndroid) {
      final DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
      final androidInfo = await deviceInfo.androidInfo;
      return androidInfo.manufacturer;
    }
    if (Platform.isIOS) {
      return 'Apple';
    }
    return '';
  }

  // 操作系统版本
  Future<String> getOsVersion() async {
    if (Platform.isAndroid) {
      final DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
      final androidInfo = await deviceInfo.androidInfo;
      return androidInfo.version.release;
    }
    if (Platform.isIOS) {
      final DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
      final iosInfo = await deviceInfo.iosInfo;
      return iosInfo.systemVersion;
    }
    return '';
  }

  Future<bool> isLimitAdTrackingEnabled() async {
    if (Platform.isIOS) {
      final attStatus = await AppTrackingTransparency.trackingAuthorizationStatus;
      return attStatus == TrackingStatus.authorized;
    } else if (Platform.isAndroid) {
      final isLimitAdTracking = await Adjust.isEnabled();
      return !isLimitAdTracking; // Android返回的是是否启用跟踪，取反得到是否限制
    }
    return false;
  }
}
