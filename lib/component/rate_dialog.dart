import 'package:fast_ai/component/app_dialog.dart';
import 'package:fast_ai/component/f_button.dart';
import 'package:fast_ai/gen/assets.gen.dart';
import 'package:fast_ai/generated/locales.g.dart';
import 'package:fast_ai/pages/router/app_router.dart';
import 'package:fast_ai/values/app_text_style.dart';
import 'package:flutter/material.dart';
import 'package:get/get_utils/src/extensions/internacionalization.dart';

class RateDialog extends StatelessWidget {
  const RateDialog({super.key, required this.msg});

  final String msg;

  void close() {
    AppDialog.dismiss(tag: 'afasdf524151');
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          padding: const EdgeInsets.all(24),
          margin: EdgeInsets.symmetric(horizontal: 24).copyWith(top: 28),
          decoration: BoxDecoration(
            color: Color(0xFF333333),
            borderRadius: BorderRadius.circular(32),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                spacing: 8,
                children: [
                  Text(
                    LocaleKeys.rate_us.tr,
                    style: AppTextStyle.openSans(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    msg,
                    textAlign: TextAlign.center,
                    style: AppTextStyle.openSans(
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      color: Colors.white,
                    ),
                  ),
                  FButton(
                    onTap: () {
                      AppRouter.openAppStoreReview();
                    },
                    color: Color(0xFFFFD170),
                    hasShadow: true,
                    boxShadows: [
                      BoxShadow(
                        color: Color(0x4DFFD170),
                        offset: Offset(0, 4),
                        blurRadius: 4,
                        spreadRadius: 0,
                      ),
                    ],
                    child: Center(
                      child: Text(
                        LocaleKeys.help_app.tr,
                        style: AppTextStyle.openSans(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF531903),
                        ),
                      ),
                    ),
                  ),
                  FButton(
                    onTap: close,
                    color: Color(0x1AFFFFFF),
                    child: Center(
                      child: Text(
                        LocaleKeys.nope.tr,
                        style: AppTextStyle.openSans(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        PositionedDirectional(end: 20, child: Assets.images.rateIcon.image(width: 90)),
      ],
    );
  }
}
