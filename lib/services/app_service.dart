import 'dart:io';

import 'package:adjust_sdk/adjust.dart';
import 'package:adjust_sdk/adjust_config.dart';
import 'package:app_tracking_transparency/app_tracking_transparency.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:fast_ai/services/api_service.dart';
import 'package:fast_ai/services/app_cache.dart';
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

  static const Map<Environment, Map<String, dynamic>> _envConfig = {
    Environment.dev: {
      'baseUrl': 'https://liuhaipeng3.powerfulclean.net',
      'isDebugMode': true,
      'bundleId': 'com.dev.fast',
    },
    // TODO: !
    Environment.prod: {
      'baseUrl': 'https://www.openchatbotapi.com',
      'isDebugMode': false,
      'bundleId': 'com.dev.fast',
    },
  };

  // 平台
  String get platform => Platform.isIOS ? 'fast' : 'fast-android';
  String bundleId = '';

  // TODO: url
  static const String privacy = 'https://boomai.cc/privacy/';
  static const terms = 'https://boomai.cc/terms/';
  static const email = 'mailto:boomai@proton.me';

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

    // await initAdjust();
    // await initFirebase();
  }

  // Adjust 初始化
  Future<void> initAdjust() async {
    try {
      String deviceId = await AppCache().phoneId(isOrigin: true);
      // TODO: ---
      String appToken = '';
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
      FirebaseAnalytics.instance.setAnalyticsCollectionEnabled(true);
      FirebaseRemoteConfig.instance.setConfigSettings(
        RemoteConfigSettings(
          fetchTimeout: const Duration(minutes: 1),
          minimumFetchInterval: const Duration(minutes: 1),
        ),
      );

      FirebaseRemoteConfig.instance.fetchAndActivate();
      listenRemoteConfig();
    } catch (e) {
      log.e('[Firebase]: catch : $e');
    }
  }

  // 监听 Firebase 配置更新
  Future<void> listenRemoteConfig() async {
    FirebaseRemoteConfig.instance.onConfigUpdated.listen((_) async {
      await FirebaseRemoteConfig.instance.activate();
      _refreshRemoteConfig();
    });
  }

  // 拉取并更新 Firebase 配置
  Future<void> fetchConfig() async {
    try {
      // 确保Firebase已初始化
      if (Firebase.apps.isEmpty) {
        await initFirebase();
      }
      _refreshRemoteConfig();
    } catch (e) {
      log.e('Error fetching remote config: $e');
    }
  }

  // 更新配置
  Future<void> _refreshRemoteConfig() async {
    final remoteConfig = FirebaseRemoteConfig.instance;

    // TODO: configuration
    maxFreeChatCount = _getConfigValue('free_chat_count', remoteConfig.getInt, 50);
    showClothingCount = _getConfigValue('show_clothing_count', remoteConfig.getInt, 5);
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
    final status = await AppTrackingTransparency.trackingAuthorizationStatus;
    log.d('trackingAuthorizationStatus: $status');

    if (status == TrackingStatus.notDetermined) {
      await Future.delayed(const Duration(milliseconds: 200));
      await AppTrackingTransparency.requestTrackingAuthorization();
    }
    final uuid = await AppTrackingTransparency.getAdvertisingIdentifier();
    log.d('uuid: $uuid');
    return uuid;
  }

  // 获取idfv
  Future<String> getIdfv() async {
    if (!Platform.isIOS) {
      return '';
    }
    final DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    final iosInfo = await deviceInfo.iosInfo;
    return iosInfo.identifierForVendor ?? '';
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
      final attStatus = await Adjust.getAppTrackingAuthorizationStatus();
      return attStatus == 0 || attStatus == 1; // 0=未决定,1=限制跟踪
    } else if (Platform.isAndroid) {
      final isLimitAdTracking = await Adjust.isEnabled();
      return !isLimitAdTracking; // Android返回的是是否启用跟踪，取反得到是否限制
    }
    return false;
  }
}
