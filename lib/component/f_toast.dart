import 'package:flutter/material.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';

class FToast {
  static Future<void> toast(String msg) async {
    await SmartDialog.showToast(
      '',
      displayType: SmartToastType.onlyRefresh,
      debounce: true,
      alignment: Alignment.center,
      builder: (_) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          decoration: BoxDecoration(
            color: Color(0xD9404040),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Text(msg, style: TextStyle(color: Colors.white, fontSize: 14)),
        );
      },
    );
  }
}
