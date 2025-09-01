import 'package:blur/blur.dart';
import 'package:fast_ai/gen/assets.gen.dart';
import 'package:fast_ai/generated/locales.g.dart';
import 'package:fast_ai/pages/router/app_router.dart';
import 'package:fast_ai/services/app_cache.dart';
import 'package:fast_ai/services/app_log_event.dart';
import 'package:fast_ai/services/app_user.dart';
import 'package:fast_ai/values/app_text_style.dart';
import 'package:fast_ai/values/app_values.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class TextLock extends StatelessWidget {
  const TextLock({super.key, this.onTap, required this.textContent});

  final void Function()? onTap;
  final String textContent;

  void _unLockTextGems() async {
    logEvent('c_news_locktext');
    if (!AppUser().isVip.value) {
      AppRouter.pushVip(VipFrom.locktext);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 280,
      height: 120,
      child: GestureDetector(
        onTap: _unLockTextGems,
        child: Stack(
          alignment: AlignmentDirectional.topStart,
          children: [
            Positioned(top: 12, right: 0, bottom: 0, child: _buildContainer()),
            _buildLabel(),
            _buildLock(),
          ],
        ),
      ),
    );
  }

  Widget _buildContainer() {
    return Container(
      padding: EdgeInsets.all(16),
      alignment: Alignment.center,
      color: Color(0x1A1C1C1C),
      child: Text(
        textContent,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w500),
      ),
    ).blurred(
      borderRadius: BorderRadius.circular(16),
      colorOpacity: 0.9,
      blur: 100,
      blurColor: Color(0x1A1C1C1C),
    );
  }

  Widget _buildLock() {
    return Column(
      children: [
        const SizedBox(height: 26),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              LocaleKeys.tap_to_see_messages.tr,
              style: AppTextStyle.openSans(
                color: Colors.white,
                fontSize: 10,
                fontWeight: FontWeight.w400,
              ),
            ),
            const SizedBox(width: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
              decoration: BoxDecoration(
                color: const Color(0xffFFA942),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                LocaleKeys.message.tr,
                style: AppTextStyle.openSans(
                  color: Colors.black,
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
        Spacer(),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              height: 32,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                color: Color(0xFF3F8DFD),
              ),
              child: Row(
                children: [
                  Assets.images.banan.image(width: 24),
                  Text(
                    LocaleKeys.unlock.tr,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
      ],
    );
  }

  Widget _buildLabel() {
    if (!AppCache().isBig) {
      return const SizedBox(width: 22, height: 22);
    }
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          height: 20,
          padding: const EdgeInsets.symmetric(horizontal: 8),
          alignment: Alignment.centerLeft,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: const Color(0xffFFA942),
          ),
          child: Text(
            LocaleKeys.unlock_text_reply.tr,
            style: AppTextStyle.openSans(
              color: Colors.black,
              fontSize: 10,
              fontWeight: FontWeight.w400,
            ),
          ),
        ),
      ],
    );
  }
}
