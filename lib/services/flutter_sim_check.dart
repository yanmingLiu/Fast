import 'package:flutter/services.dart';

import 'f_service.dart';

class FlutterSimCheck {
  static const MethodChannel _channel = MethodChannel('sim_check');

  static Future<bool> hasSimCard() async {
    try {
      final bool result = await _channel.invokeMethod('hasSimCard');
      return result;
    } on PlatformException catch (e) {
      log.e("Failed to get sim card status: '${e.message}'.");
      return false;
    }
  }
}
