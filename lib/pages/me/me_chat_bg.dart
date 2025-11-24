import 'package:fast_ai/component/f_button.dart';
import 'package:fast_ai/gen/assets.gen.dart';
import 'package:fast_ai/values/theme_colors.dart'; // 统一颜色管理
import 'package:fast_ai/values/theme_style.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../generated/locales.g.dart';

class MeChatBg extends StatelessWidget {
  const MeChatBg({
    super.key,
    required this.onTapUpload,
    required this.onTapUseChat,
    required this.isUseChater,
  });

  final VoidCallback onTapUpload;
  final VoidCallback onTapUseChat;
  final bool isUseChater;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(24),
      margin: EdgeInsets.symmetric(horizontal: 24),
      decoration: BoxDecoration(
        color: const Color(0xFF333333),
        borderRadius: BorderRadius.circular(32),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        spacing: 20,
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            spacing: 20,
            children: [
              Text(
                LocaleKeys.set_chat_background.tr,
                textAlign: TextAlign.center,
                style: ThemeStyle.openSans(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
              isUseChater
                  ? _buildButton(LocaleKeys.upload_a_photo.tr, onTapUpload)
                  : _buildSelectButton(LocaleKeys.upload_a_photo.tr),
              isUseChater
                  ? _buildSelectButton(LocaleKeys.use_avatar.tr)
                  : _buildButton(LocaleKeys.use_avatar.tr, onTapUseChat),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildButton(String title, VoidCallback onTap) {
    return FButton(
      onTap: onTap,
      height: 48,
      borderRadius: BorderRadius.circular(24),
      color: ThemeColors.primary,
      child: Center(
        child: Text(
          title,
          style: ThemeStyle.openSans(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }

  Widget _buildSelectButton(String title) {
    return Container(
      height: 48,
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.all(Radius.circular(24)),
        border: Border.all(color: const Color(0xFF727374), width: 1.0),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        spacing: 8,
        children: [
          Text(
            title,
            style: ThemeStyle.openSans(
              color: Color(0xFF727374),
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
          Assets.images.selected.image(width: 20),
        ],
      ),
    );
  }
}
