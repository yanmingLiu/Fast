import 'package:fast_ai/component/f_button.dart';
import 'package:fast_ai/gen/assets.gen.dart';
import 'package:fast_ai/generated/locales.g.dart';
import 'package:fast_ai/pages/router/app_router.dart';
import 'package:fast_ai/values/app_values.dart';
import 'package:flutter/material.dart';
import 'package:get/get_utils/src/extensions/export.dart';
import 'package:google_fonts/google_fonts.dart';

class MeNotVip extends StatelessWidget {
  const MeNotVip({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 250,
      child: Stack(
        children: [
          PositionedDirectional(
            start: 0,
            end: 0,
            top: 40,
            bottom: 0,
            child: Assets.images.meVipBg0.image(fit: BoxFit.fill),
          ),
          PositionedDirectional(
            start: 16,
            end: 160,
            bottom: 26,
            top: 60,
            child: Container(
              height: 174,
              padding: const EdgeInsets.all(16),
              child: Column(
                spacing: 12,
                crossAxisAlignment: CrossAxisAlignment.start,
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
                  const Spacer(),
                ],
              ),
            ),
          ),
          PositionedDirectional(
            top: 0,
            end: 0,
            child: Assets.images.meVipPerson.image(width: 158, height: 194),
          ),
          PositionedDirectional(
            end: 30,
            bottom: 26,
            child: FButton(
              onTap: () => AppRouter.pushVip(VipFrom.mevip),
              height: 44,
              constraints: BoxConstraints(minWidth: 108),
              padding: EdgeInsetsDirectional.symmetric(horizontal: 12),
              borderRadius: BorderRadius.circular(22),
              color: Colors.white,
              child: Center(
                child: Text(
                  LocaleKeys.explore.tr,
                  style: GoogleFonts.openSans(
                    color: Color(0xFF3F8DFD),
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
