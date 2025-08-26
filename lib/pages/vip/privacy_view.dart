import 'package:fast_ai/pages/router/app_router.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

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
        return _buildVipBottom(const Color(0xFFA8A8A8), true);
      case PolicyBottomType.vip2:
        return _buildVipBottom(const Color(0xFFA8A8A8), false);
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
            _buildButton(LocaleKeys.privacy_policy.tr, () => AppRouter.toPrivacy(), buttonColor),
            _buildSeparator(),
            _buildButton(LocaleKeys.terms_of_use.tr, () => AppRouter.toTerms(), buttonColor),
          ],
        ),
        if (showSubscriptionText) ...[
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Text(
              LocaleKeys.subscription_auto_renew.tr,
              style: TextStyle(color: Color(0xFFA8A8A8), fontSize: 10, fontWeight: FontWeight.w400),
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
        _buildButton(LocaleKeys.terms_of_use.tr, () => AppRouter.toTerms(), null),
        _buildSeparator(),
        _buildButton(LocaleKeys.privacy_policy.tr, () => AppRouter.toPrivacy(), null),
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
        style: GoogleFonts.montserrat(
          fontSize: 10,
          color: color ?? const Color(0xFFA8A8A8),
          fontWeight: FontWeight.w500,
          decoration: TextDecoration.underline,
          decorationColor: color ?? const Color(0xFFA8A8A8),
          decorationThickness: 1.0,
        ),
      ),
    );
  }
}
