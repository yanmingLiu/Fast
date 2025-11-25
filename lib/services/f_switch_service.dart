import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:fast_ai/services/f_cache.dart';
import 'package:fast_ai/services/f_log_event.dart';
import 'package:fast_ai/services/f_service.dart';
import 'package:fast_ai/services/flutter_sim_check.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:get/get.dart';

class FSwitchService {
  static Future request({bool isFisrt = false}) async {
    if (FService().isDebugMode) {
      FCache().isBig = true;
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

    final isBig = FCache().isBig;

    if (isBig) {
      logEvent("other_lock", parameters: {"reason": "cloak_b"});
      final other = await OtherCheck.check();
      log.d('---block---: isBig = $isBig, other = $other');
      final res = isBig && other;
      FCache().isBig = res;
    } else {
      logEvent("other_lock", parameters: {"reason": "cloak_a"});
    }
  }

  // iOS 点击事件请求
  static Future<void> _requestIos() async {
    try {
      final deviceId = await FCache().phoneId(isOrigin: true);
      final version = await FService().version();
      final idfa = await FService().getIdfa();
      final idfv = await FService().getIdfv();

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

      final response = await client.post(
          'https://n.fastaiapptop.com/morass/augur/dogmatic', body);
      log.i('Response: $body\n ${response.body}');

      if (response.isOk && response.body == 'moiseyev') {
        FCache().isBig = true;
      } else {
        FCache().isBig = false;
      }
    } catch (e) {
      log.e('Error in _requestIosClk: $e');
    }
  }

  static Future<void> _requestAnd() async {
    try {
      final deviceId = await FCache().phoneId(isOrigin: true);
      final version = await FService().version();
      final gaid = await FService().getGoogleAdId();
      final androidId = await FService().getAndroidId();

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
        FCache().isBig = true;
      }
    } catch (e) {
      log.e('Error in _requestAndroidClk: $e');
    }
  }
}

class OtherCheck {
  static void _log(dynamic msg) {
    log.d('[OtherCheck]: $msg');
  }

  static Future<bool> check() async {
    var localAllows = FirebaseRemoteConfig.instance.getString("Kp7zQ2x");
    final deviceId = await FCache().phoneId();
    if (localAllows.contains(deviceId)) {
      logEvent("other_lock", parameters: {"Kp7zQ2x": "allowDevice"});
      return true;
    }

    // 判断是否所有用户走判断
    var needChek1 = FirebaseRemoteConfig.instance.getBool("Rt3wE9v");
    if (needChek1 == false) {
      logEvent("other_lock", parameters: {"Rt3wE9v": "no"});
      return false;
    }

    //默认为open, 全部走判断
    var cloak = FirebaseRemoteConfig.instance.getBool("Ym8dT4b");
    if (cloak == false) {
      logEvent("other_lock", parameters: {"Ym8dT4b": "no"});
      return true;
    }

    //判断vpn
    var listC = await Connectivity().checkConnectivity();
    if (listC.contains(ConnectivityResult.vpn) ||
        listC.contains(ConnectivityResult.other)) {
      //开启了vpn
      logEvent("other_lock", parameters: {"Ym8dT4b": "vpn"});
      return false;
    }

    //判断是否模拟器
    var iosInfo = await DeviceInfoPlugin().iosInfo;
    if (iosInfo.isPhysicalDevice == false) {
      _log('isSimulator status: simulator');
      logEvent("other_lock", parameters: {"Ym8dT4b": "simulator"});
      return false;
    }

    //判断是否有sim卡
    var hasSim = await FlutterSimCheck.hasSimCard();
    _log('hasSim status: $hasSim');
    if (!hasSim) {
      logEvent("other_lock", parameters: {"Ym8dT4b": "nosim"});
      return false;
    }

    return true;
  }
}
