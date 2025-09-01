import 'package:fast_ai/gen/assets.gen.dart';
import 'package:fast_ai/generated/locales.g.dart';
import 'package:fast_ai/main.dart';
import 'package:fast_ai/services/app_user.dart';
import 'package:fast_ai/tools/ext.dart';
import 'package:fast_ai/values/app_text_style.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class MeVip extends StatelessWidget {
  const MeVip({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Stack(
        children: [
          Transform.flip(
            flipX: isArabic, // 仅在阿拉伯语时水平翻转
            child: Container(
              width: double.infinity,
              constraints: const BoxConstraints(minHeight: 100),
              child: Assets.images.meVipBg1.image(fit: BoxFit.fill),
            ),
          ),
          Positioned(
            left: 16,
            right: 16,
            bottom: 0,
            top: 8,
            child: Container(
              height: 98,
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Text(
                    LocaleKeys.vip_member.tr,
                    style: AppTextStyle.openSans(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                  Obx(() {
                    AppUser().isVip.value;
                    final timer =
                        AppUser().user?.subscriptionEnd ?? DateTime.now().millisecondsSinceEpoch;
                    final date = formatTimestamp(timer);
                    return Text(
                      LocaleKeys.deadline.trParams({'date': date}),
                      style: AppTextStyle.openSans(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: const Color(0xB3FFFFFF),
                      ),
                    );
                  }),
                ],
              ),
            ),
          ),
          PositionedDirectional(
            top: 0,
            end: 24,
            child: Assets.images.meVipIcon.image(width: 100, height: 100),
          ),
        ],
      ),
    );
  }
}
