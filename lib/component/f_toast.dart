import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';

class FToast {
  static Future<void> toast(String msg) {
    return SmartDialog.showToast(msg);
  }
}
