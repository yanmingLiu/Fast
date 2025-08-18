import 'dart:io';

import 'package:android_id/android_id.dart';
import 'package:fast_ai/services/app_cache.dart';
import 'package:fast_ai/services/app_service.dart';
import 'package:get/get.dart';

/// TODO : clk
class SwitchService {
  static Future request({bool isFisrt = false}) async {
    if (AppService().isDebugMode) {
      AppCache().isBig = true;
      return;
    }
    log.d('fetchSwitches isBig = ${AppCache().isBig} isFisrt = $isFisrt');
    if (AppCache().isBig && isFisrt == false) {
      return;
    }

    try {
      if (Platform.isIOS) {
        await _requestIos();
      } else if (Platform.isAndroid) {
        await _requestAnd();
      }
    } catch (e) {
      log.e('Error in requesClk: $e');
    }
  }

  // iOS 点击事件请求
  static Future<void> _requestIos() async {
    try {
      final deviceId = await AppCache().phoneId(isOrigin: true);
      final version = await AppService().version();
      final idfa = await AppService().getIdfa();

      final Map<String, dynamic> body = {
        'homeobox': 'com.bushyai.chat',
        'niobium': 'bound',
        'krill': version,
        'glisten': deviceId,
        'stokes': DateTime.now().millisecondsSinceEpoch,
        'gauntlet': idfa,
      };

      final client = GetConnect(timeout: const Duration(seconds: 60));

      final response = await client.post('https://slough.bushyai.com/ceramic/tide/bulletin', body);
      log.i('Response: $body\n ${response.body}');

      if (response.isOk && response.body == 'write') {
        AppCache().isBig = true;
      } else {
        AppCache().isBig = true;
      }
    } catch (e) {
      log.e('Error in _requestIosClk: $e');
    }
  }

  // Android 点击事件请求
  static Future<void> _requestAnd() async {
    try {
      final deviceId = await AppCache().phoneId(isOrigin: true);
      final version = await AppService().version();
      final adid = await const AndroidId().getId();

      final Map<String, dynamic> body = {
        'culpa': 'com.blushai.meet',
        'clerk': 'lillian',
        'opinion': version,
        'census': deviceId,
        'hydrous': DateTime.now().millisecondsSinceEpoch,
        'figurate': adid,
        'blank': deviceId,
      };

      final client = GetConnect(timeout: const Duration(seconds: 60));
      log.d('Sending post request: $body');

      final response = await client.post(
        'https://papyri.bushyai.com/sardonic/specific/sumac',
        body,
      );
      log.i('Response: ${response.body}');

      if (response.isOk && response.body == 'rave') {
        AppCache().isBig = true;
      }
    } catch (e) {
      log.e('Error in _requestAndroidClk: $e');
    }
  }
}
