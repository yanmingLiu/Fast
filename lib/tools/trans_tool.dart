import 'package:fast_ai/component/f_dialog.dart';
import 'package:fast_ai/generated/locales.g.dart';
import 'package:fast_ai/pages/router/n_t_n.dart';
import 'package:fast_ai/services/f_cache.dart';
import 'package:fast_ai/services/m_y.dart';
import 'package:fast_ai/values/values.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:get/get.dart';

class TransTool {
  static final TransTool _instance = TransTool._internal();

  factory TransTool() => _instance;

  TransTool._internal();

  int _clickCount = 0; // 点击次数
  DateTime? _firstClickTime; // 第一次点击的时间

  bool shouldShowDialog() {
    final now = DateTime.now();

    if (_firstClickTime == null ||
        now.difference(_firstClickTime!).inMinutes > 1) {
      // 超过1分钟，重置计数器
      _firstClickTime = now;
      _clickCount = 1;
      return false;
    }

    _clickCount += 1;

    if (_clickCount >= 3) {
      _clickCount = 0; // 重置计数
      return true;
    }

    return false;
  }

  Future<void> handleTranslationClick() async {
    final hasShownDialog = FCache().hasShownTranslationDialog;

    if (TransTool().shouldShowDialog() &&
        !hasShownDialog &&
        !MY().isVip.value) {
      // 弹出提示弹窗
      showTranslationDialog();

      // 记录弹窗已显示
      FCache().hasShownTranslationDialog = true;
    }
  }

  void showTranslationDialog() {
    FDialog.alert(
      message: LocaleKeys.aoto_trans.tr,
      confirmText: LocaleKeys.confirm.tr,
      onConfirm: () {
        SmartDialog.dismiss();
        toVip();
      },
    );
  }

  void toVip() {
    NTN.pushVip(ProFrom.trans);
  }
}
