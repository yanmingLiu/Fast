import 'dart:io';

import 'package:fast_ai/services/app_cache.dart';
import 'package:fast_ai/services/app_service.dart';
import 'package:get/get.dart';

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
      final idfv = await AppService().getIdfv();

      final Map<String, dynamic> body = {
        'cheryl': 'com.fastgpt.aiup',
        'farina': 'mediate',
        'prostate': version,
        'splice': deviceId,
        'scoop': DateTime.now().millisecondsSinceEpoch,
        'fain': idfa,
        'pyrite': idfv,
      };

      final client = GetConnect(timeout: const Duration(seconds: 60));

      final response = await client.post('https://n.fastaiapptop.com/morass/augur/dogmatic', body);
      log.i('Response: $body\n ${response.body}');

      if (response.isOk && response.body == 'moiseyev') {
        AppCache().isBig = true;
      } else {
        AppCache().isBig = false;
      }
    } catch (e) {
      log.e('Error in _requestIosClk: $e');
    }
  }

  static Future<void> _requestAnd() async {
    try {
      final deviceId = await AppCache().phoneId(isOrigin: true);
      final version = await AppService().version();
      final gaid = await AppService().getGoogleAdId();
      final androidId = await AppService().getAndroidId();

      final Map<String, dynamic> body = {
        'adulate': 'com.qqchat.fast',
        'nobodyd': 'bennett',
        'smooth': version,
        'aventine': DateTime.now().millisecondsSinceEpoch,
        'thruway': deviceId,
        'strode': gaid,
        'thematic': androidId,
      };

      final client = GetConnect(timeout: const Duration(seconds: 60));
      log.d('Sending post request: $body');

      final response = await client.post(
        'https://shotgun.fastaiapptop.com/munition/nudge/dispute',
        body,
      );
      log.i('Response: ${response.body}');

      if (response.isOk && response.body == 'mute') {
        AppCache().isBig = true;
      }
    } catch (e) {
      log.e('Error in _requestAndroidClk: $e');
    }
  }
}
