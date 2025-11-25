import 'package:fast_ai/pages/router/n_t_n.dart';
import 'package:fast_ai/values/theme_colors.dart'; // 统一颜色管理
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../generated/locales.g.dart';

enum PolicyBottomType { gems, vip1, vip2 }

class PrivacyView extends StatelessWidget {
  const PrivacyView({super.key, required this.type});

  final PolicyBottomType type;

  @override
  Widget build(BuildContext context) {
    // 通过一个方法来简化不同 type 的渲染
    switch (type) {
      case PolicyBottomType.gems:
        return _buildGemsBottom();
      case PolicyBottomType.vip1:
        return _buildVipBottom(ThemeColors.hintText, true);
      case PolicyBottomType.vip2:
        return _buildVipBottom(ThemeColors.hintText, false);
    }
  }

  // 提取公共逻辑，减少重复
  Widget _buildVipBottom(Color buttonColor, bool showSubscriptionText) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildButton(LocaleKeys.privacy_policy.tr, () => NTN.toPrivacy(),
                buttonColor),
            _buildSeparator(),
            _buildButton(
                LocaleKeys.terms_of_use.tr, () => NTN.toTerms(), buttonColor),
          ],
        ),
        if (showSubscriptionText) ...[
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Text(
              LocaleKeys.subscription_auto_renew.tr,
              style: TextStyle(
                color: ThemeColors.hintText,
                fontSize: 10,
                fontWeight: FontWeight.w400,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildGemsBottom() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildButton(LocaleKeys.terms_of_use.tr, () => NTN.toTerms(), null),
        _buildSeparator(),
        _buildButton(LocaleKeys.privacy_policy.tr, () => NTN.toPrivacy(), null),
      ],
    );
  }

  // 提取分隔符部分
  Widget _buildSeparator() {
    return Container(
      width: 1,
      height: 12,
      margin: const EdgeInsets.symmetric(horizontal: 8),
      color: Color(0xFFC9C9C9),
    );
  }

  Widget _buildButton(String title, VoidCallback onTap, Color? color) {
    return GestureDetector(
      onTap: onTap,
      child: Text(
        title,
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 10,
          color: color ?? ThemeColors.hintText,
          fontWeight: FontWeight.w500,
          decoration: TextDecoration.underline,
          decorationColor: color ?? ThemeColors.hintText,
          decorationThickness: 1.0,
        ),
      ),
    );
  }
}
