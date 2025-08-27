import 'package:fast_ai/component/f_button.dart';
import 'package:fast_ai/gen/assets.gen.dart';
import 'package:fast_ai/generated/locales.g.dart';
import 'package:fast_ai/main.dart';
import 'package:fast_ai/pages/router/app_router.dart';
import 'package:fast_ai/values/app_colors.dart'; // 引入统一颜色管理
import 'package:fast_ai/values/app_values.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

class MeNotVip extends StatelessWidget {
  const MeNotVip({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        // 文本内容区域（无背景）
        Container(
          width: double.infinity,
          constraints: const BoxConstraints(minHeight: 200),
          child: Stack(
            children: [
              // 背景图片（独立控件）
              Positioned.fill(
                child: Transform.flip(
                  flipX: isArabic, // 仅在阿拉伯语时水平翻转
                  child: Container(
                    width: double.infinity,
                    margin: EdgeInsets.only(top: 40),
                    child: Assets.images.meVipBg0.image(fit: BoxFit.fill),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsetsDirectional.only(start: 32, end: 140, top: 70, bottom: 46),
                child: Column(
                  spacing: 12,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      LocaleKeys.up_to_vip.tr,
                      style: GoogleFonts.openSans(
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      LocaleKeys.vip_get.tr,
                      style: GoogleFonts.openSans(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        // 右侧人物图片
        PositionedDirectional(
          top: 0,
          end: 0,
          child: Assets.images.meVipPerson.image(width: 158, height: 180),
        ),
        // 探索按钮
        PositionedDirectional(
          end: 30,
          top: 160,
          child: FButton(
            onTap: () => AppRouter.pushVip(VipFrom.mevip),
            height: 44,
            constraints: const BoxConstraints(minWidth: 108),
            padding: const EdgeInsetsDirectional.symmetric(horizontal: 12),
            borderRadius: BorderRadius.circular(22),
            color: Colors.white,
            child: Center(
              child: Text(
                LocaleKeys.explore.tr,
                style: GoogleFonts.openSans(
                  color: AppColors.primary,
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
