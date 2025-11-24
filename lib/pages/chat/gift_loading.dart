import 'package:fast_ai/generated/locales.g.dart';
import 'package:fast_ai/values/theme_style.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';

class GiftLoading extends StatelessWidget {
  const GiftLoading({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 24),
        margin: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: Color(0xFF333333),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Lottie.asset('assets/lottie/hourglass.json', width: 44),
            const SizedBox(height: 16),
            Text(
              LocaleKeys.sara_received_your_gift.tr,
              textAlign: TextAlign.center,
              style: ThemeStyle.openSans(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              LocaleKeys.give_her_a_moment.tr,
              style: ThemeStyle.openSans(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w400,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Container(height: 1, color: Color(0x1AFFFFFF)),
            const SizedBox(height: 16),
            Text(
              LocaleKeys.wait_30_seconds.tr,
              style: ThemeStyle.openSans(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w400,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
