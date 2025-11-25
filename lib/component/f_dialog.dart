import 'dart:async';
import 'dart:ui';

import 'package:fast_ai/component/f_button.dart';
import 'package:fast_ai/component/f_icon.dart';
import 'package:fast_ai/component/f_login_reward_dialog.dart';
import 'package:fast_ai/component/f_rate.dart';
import 'package:fast_ai/gen/assets.gen.dart';
import 'package:fast_ai/generated/locales.g.dart';
import 'package:fast_ai/pages/chat/gift_loading.dart';
import 'package:fast_ai/pages/chat/level_dialog.dart';
import 'package:fast_ai/pages/vip/recharge_dialog.dart';
import 'package:fast_ai/values/theme_colors.dart';
import 'package:fast_ai/values/theme_style.dart';
import 'package:flutter/material.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:get/get.dart';

const String loginRewardTag = '325dfa161253f036fg';
const String giftLoadingTag = '549816514tfhgerq';
const String rateUsTag = 'afasdf524151';
const String rechargeSuccTag = 'gas154hgjet61wes';
const String chatLevelUpTag = 'hfkjetrthw454651';

class FDialog {
  static Future<void> dismiss({String? tag}) {
    return SmartDialog.dismiss(status: SmartStatus.dialog, tag: tag);
  }

  static Future<void> show({
    required Widget child,
    bool? clickMaskDismiss = true,
    String? tag,
    bool? showCloseButton = true,
    void Function()? onCancel,
  }) async {
    final completer = Completer<void>();

    SmartDialog.show(
      clickMaskDismiss: clickMaskDismiss,
      keepSingle: true,
      debounce: true,
      tag: tag,
      maskWidget: ClipPath(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
          child: Container(color: Color(0xCC000000)),
        ),
      ),
      builder: (context) {
        if (showCloseButton == true) {
          return Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            spacing: 20,
            children: [
              child,
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildCloseButton(
                    onTap: onCancel,
                  )
                ],
              ),
            ],
          );
        } else {
          return child;
        }
      },
      onDismiss: () {
        completer.complete();
      },
    );

    await completer.future;
  }

  static Future<void> alert({
    String? title,
    String? message,
    Widget? messageWidget,
    bool? clickMaskDismiss = false,
    String? cancelText,
    String? confirmText,
    void Function()? onCancel,
    void Function()? onConfirm,
  }) async {
    return show(
      clickMaskDismiss: false,
      onCancel: onCancel,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 20),
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: const Color(0xFF333333), // 对话框背景色
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          spacing: 12,
          children: [
            _buildText(title ?? LocaleKeys.tips.tr, 20, FontWeight.w700),
            if (title?.isNotEmpty == true) const SizedBox(height: 16),
            _buildText(message, 14, FontWeight.w500),
            if (messageWidget != null) messageWidget,
            FButton(
              onTap: onConfirm,
              margin: EdgeInsets.only(top: 8),
              color: ThemeColors.primary,
              hasShadow: true,
              height: 48,
              child: Center(
                child: Text(
                  confirmText ?? LocaleKeys.confirm.tr,
                  style: ThemeStyle.openSans(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
            if (cancelText?.isNotEmpty == true)
              FButton(
                onTap: () {
                  onCancel ?? SmartDialog.dismiss();
                },
                height: 48,
                color: ThemeColors.white10,
                child: Center(
                  child: Text(
                    LocaleKeys.cancel.tr,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  static Future input({
    String? title,
    String? message,
    String? hintText,
    Widget? messageWidget,
    bool? clickMaskDismiss = false,
    String? cancelText,
    String? confirmText,
    void Function()? onCancel,
    void Function()? onConfirm,
    FocusNode? focusNode, // FocusNode 参数
    TextEditingController? textEditingController, // TextEditingController 参数
  }) async {
    final focusNode1 = focusNode ?? FocusNode();
    final textController1 = textEditingController ?? TextEditingController();

    return SmartDialog.show(
      clickMaskDismiss: clickMaskDismiss,
      useAnimation: false, // 关闭动画
      maskWidget: ClipPath(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
          child: Container(color: Color(0xCC000000)),
        ),
      ),
      builder: (context) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          // 在渲染完成之后调用焦点请求，确保键盘弹出
          focusNode1.requestFocus();
        });

        double keyboardHeight = MediaQuery.of(context).viewInsets.bottom;

        return AnimatedPadding(
          duration: const Duration(milliseconds: 150),
          curve: Curves.easeOut,
          padding: EdgeInsets.only(bottom: keyboardHeight),
          child: Material(
            type: MaterialType.transparency,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Stack(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 36),
                        decoration: BoxDecoration(
                          color: const Color(0xFF333333), // 对话框背景色
                          borderRadius: BorderRadius.circular(32),
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            _buildText(title, 18, FontWeight.w700),
                            if (title?.isNotEmpty == true)
                              const SizedBox(height: 16),
                            _buildText(message, 14, FontWeight.w500),
                            if (messageWidget != null) messageWidget,
                            const SizedBox(height: 16),
                            Container(
                              height: 40,
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 16),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Center(
                                child: TextField(
                                  autofocus: true,
                                  textInputAction: TextInputAction.done,
                                  onEditingComplete: () {},
                                  minLines: 1,
                                  maxLength: 20,
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    height: 1,
                                    color: Colors.black,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                  ),
                                  controller: textController1,
                                  decoration: InputDecoration(
                                    hintText: hintText ?? 'input',
                                    counterText: '', // 去掉字数显示
                                    hintStyle: const TextStyle(
                                        color: Color(0xFFB3B3B3)),
                                    fillColor: Colors.transparent,
                                    border: InputBorder.none,
                                    filled: true,
                                    isDense: true,
                                  ),
                                  focusNode: focusNode1,
                                ),
                              ),
                            ),
                            const SizedBox(height: 32),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 20),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Expanded(
                                    child: FButton(
                                      onTap: onConfirm,
                                      height: 48,
                                      borderRadius: BorderRadius.circular(24),
                                      color: ThemeColors.primary,
                                      child: Center(
                                        child: Text(
                                          LocaleKeys.confirm.tr,
                                          style: ThemeStyle.openSans(
                                            color: Colors.white,
                                            fontSize: 16,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [_buildCloseButton()]),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  static Widget _buildCloseButton({void Function()? onTap}) {
    return FButton(
      onTap: () {
        SmartDialog.dismiss();
        onTap?.call();
      },
      width: 44,
      height: 44,
      borderRadius: BorderRadius.all(Radius.circular(22)),
      child: Center(child: FIcon(assetName: Assets.svg.close, width: 24)),
    );
  }

  static Widget _buildText(
      String? text, double fontSize, FontWeight fontWeight) {
    if (text?.isNotEmpty != true) return const SizedBox.shrink();
    return Text(
      text!,
      textAlign: TextAlign.center,
      style: ThemeStyle.openSans(
          color: Colors.white, fontSize: fontSize, fontWeight: fontWeight),
    );
  }

  static Future showChatLevel() async {
    return show(child: LevelDialog(), clickMaskDismiss: false);
  }

  static bool _isChatLevelDialogVisible = false;

  static Future<void> showChatLevelUp(int rewards) async {
    // 防止重复弹出
    if (_isChatLevelDialogVisible) return;

    // 设置标记为显示中
    _isChatLevelDialogVisible = true;

    try {
      await _showLevelUpToast(rewards);
    } finally {
      _isChatLevelDialogVisible = false;
    }
  }

  static Future<void> _showLevelUpToast(int rewards) async {
    final completer = Completer<void>();

    SmartDialog.show(
      displayTime: Duration(milliseconds: 1500),
      maskColor: Colors.transparent,
      clickMaskDismiss: false,
      onDismiss: () => completer.complete(),
      builder: (context) {
        return Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                decoration: BoxDecoration(
                  color: Color(0xCC000000),
                  borderRadius: BorderRadius.circular(16),
                ),
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  spacing: 8,
                  children: [
                    Assets.images.gems.image(width: 24),
                    Text(
                      '+ $rewards',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );

    await completer.future;

    await _showLevelUpDialog(rewards);
  }

  static Future<void> _showLevelUpDialog(int rewards) async {
    await SmartDialog.show(
      tag: chatLevelUpTag,
      clickMaskDismiss: false,
      maskColor: Colors.transparent,
      keepSingle: true,
      builder: (context) {
        return ChatLevelUpDialog(rewards: rewards);
      },
    );
  }

  static Future showLoginReward() async {
    if (checkExist(loginRewardTag)) {
      return;
    }
    return show(
        tag: loginRewardTag,
        clickMaskDismiss: false,
        child: FLoginRewardDialog());
  }

  static Future showGiftLoading() {
    return show(
        clickMaskDismiss: false, tag: giftLoadingTag, child: GiftLoading());
  }

  static Future hiddenGiftLoading() {
    return SmartDialog.dismiss(tag: giftLoadingTag);
  }

  static bool rateLevel3Shoed = false;

  static bool rateCollectShowd = false;

  static void showRateUs(String msg) async {
    FDialog.show(
      clickMaskDismiss: false,
      child: FRate(msg: msg),
      tag: rateUsTag,
    );
  }

  static bool checkExist(String tag) {
    return SmartDialog.checkExist(tag: tag);
  }

  static Future<void> showRechargeSuccess(int number) async {
    return FDialog.show(
      child: RechargeDialog(number: number),
      clickMaskDismiss: false,
      tag: rechargeSuccTag,
    );
  }
}
