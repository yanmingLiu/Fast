import 'dart:io';

import 'package:fast_ai/services/f_service.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/services.dart';

class FBSDKTool {
  static const MethodChannel _channel = MethodChannel('facebook_sdk_channel');

  /// 统一的日志输出方法
  static void _log(String message) {
    log.d('[fbtool] $message');
  }

  // 记录Facebook SDK是否已经初始化
  static bool _isInitialized = false;
  static String? _cachedAppId;
  static String? _cachedClientToken;

  /// 获取初始化状态
  static bool get isInitialized => _isInitialized;

  /// 从远程配置获取Facebook SDK配置
  static Future<Map<String, String>?> _getConfigFromRemote() async {
    try {
      final String facebookAppIdKey = Platform.isAndroid
          ? 'facebook_app_id_android'
          : 'facebook_app_id_ios';
      final String facebookClientTokenKey = Platform.isAndroid
          ? 'facebook_client_token_android'
          : 'facebook_client_token_ios';

      final remoteConfig = FirebaseRemoteConfig.instance;

      final String facebookAppId = remoteConfig.getString(facebookAppIdKey);
      final String facebookClientToken =
          remoteConfig.getString(facebookClientTokenKey);

      _log(
          '获取到Facebook SDK配置: appId=$facebookAppId, clientToken=$facebookClientToken');

      // 验证配置是否有效
      if (facebookAppId.isEmpty || facebookClientToken.isEmpty) {
        _log('facebookAppId.isEmpty');
        return null;
      }

      return {'appId': facebookAppId, 'clientToken': facebookClientToken};
    } catch (e) {
      _log('获取Facebook SDK配置失败: $e');
      return null;
    }
  }

  /// 初始化Facebook SDK（自动获取配置）
  static Future<void> initializeWithRemoteConfig() async {
    try {
      final config = await _getConfigFromRemote();
      if (config != null) {
        await initializeFacebookSDK(
            appId: config['appId']!, clientToken: config['clientToken']!);
      } else {
        _log('facebookAppId.isEmpty');
        // 不抛出异常，只是记录日志，避免阻塞应用启动
        return;
      }
    } catch (e) {
      _log('Facebook error: $e');
      // 不重新抛出异常，避免阻塞应用启动
      return;
    }
  }

  /// 检查Facebook SDK是否已初始化（原生端状态）
  static Future<bool> checkNativeInitializationStatus() async {
    try {
      final result = await _channel.invokeMethod('isFacebookSDKInitialized');
      return result as bool? ?? false;
    } catch (e) {
      _log('Facebook check error: $e');
      return false;
    }
  }

  /// 初始化Facebook SDK
  /// [appId] Facebook应用ID
  /// [clientToken] Facebook客户端令牌
  static Future<void> initializeFacebookSDK({
    required String appId,
    required String clientToken,
  }) async {
    try {
      // 缓存配置信息
      _cachedAppId = appId;
      _cachedClientToken = clientToken;

      // 检查参数有效性
      if (appId.isEmpty || clientToken.isEmpty) {
        throw PlatformException(
          code: 'INVALID_ARGUMENTS',
          message: 'App ID and Client Token cannot be empty',
        );
      }

      final result = await _channel.invokeMethod('initializeFacebookSDK', {
        'appId': appId,
        'clientToken': clientToken,
      });
      _log('Facebook SDK  result: $result');
    } on PlatformException catch (e) {
      _log('Facebook SDK error: ${e.message}');
      _isInitialized = false;
      rethrow;
    }
  }

  /// 网络恢复后重新初始化（如果之前未成功初始化）
  static Future<void> retryInitializationIfNeeded() async {
    try {
      if (!_isInitialized) {
        // 如果有缓存配置，直接使用
        if (_cachedAppId != null && _cachedClientToken != null) {
          await initializeFacebookSDK(
              appId: _cachedAppId!, clientToken: _cachedClientToken!);
        } else {
          // 如果没有缓存配置，重新从远程获取
          await initializeWithRemoteConfig();
        }
      }
    } catch (e) {
      _log('Facebook SDK retry error: $e');
    }
  }
}
