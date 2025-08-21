import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';

String? _msg;

class FToast {
  static Future<void> toast(String msg) async {
    if (_msg == msg) return Future.value();
    _msg = msg;
    await SmartDialog.showToast(msg);
    _msg = null;
  }
}
