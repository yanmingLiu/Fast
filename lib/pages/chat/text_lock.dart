import 'dart:ui';

import 'package:fast_ai/gen/assets.gen.dart';
import 'package:fast_ai/generated/locales.g.dart';
import 'package:fast_ai/services/app_cache.dart';
import 'package:fast_ai/services/app_log_event.dart';
import 'package:fast_ai/services/app_user.dart';
import 'package:fast_ai/tools/app_router.dart';
import 'package:fast_ai/values/app_values.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

class TextLock extends StatelessWidget {
  const TextLock({super.key, this.onTap});

  final void Function()? onTap;

  void _unLockTextGems() async {
    logEvent('c_news_locktext');
    if (!AppUser().isVip.value) {
      AppRouter.pushVip(VipFrom.locktext);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsetsDirectional.only(bottom: 16, end: 80),
      child: GestureDetector(
        onTap: _unLockTextGems,
        child: Stack(
          alignment: Alignment.topLeft,
          children: [
            Padding(padding: const EdgeInsets.only(top: 10.0), child: _buildContainer()),
            _buildLabel(),
          ],
        ),
      ),
    );
  }

  Widget _buildContainer() {
    return Container(
      height: 82,
      decoration: const BoxDecoration(
        color: Color(0x1A1C1C1C),
        borderRadius: BorderRadiusDirectional.only(
          topEnd: Radius.circular(16),
          bottomEnd: Radius.circular(16),
          bottomStart: Radius.circular(16),
        ),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 12.0),
            child: Text(
              'This is a introductionThis is ais a This is a This is aintroductionThis is ais a aintroductionThis is ais This is ais a ... ',
              style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w500),
            ),
          ),
          Positioned.fill(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 4, sigmaY: 4),
                child: Container(
                  height: double.infinity,
                  width: double.infinity,
                  color: Colors.black.withOpacity(0.9),
                ),
              ),
            ),
          ),
          Positioned.fill(child: _buildLock()),
        ],
      ),
    );
  }

  Widget _buildLock() {
    return Column(
      children: [
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              LocaleKeys.tap_to_see_messages.tr,
              style: GoogleFonts.openSans(
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
                style: GoogleFonts.openSans(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
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
                      color: Color(0xff1C1C1C),
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
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
            style: GoogleFonts.openSans(
              color: Colors.black,
              fontSize: 10,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }
}
