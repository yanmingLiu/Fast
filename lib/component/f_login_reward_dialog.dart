import 'package:fast_ai/component/app_dialog.dart';
import 'package:fast_ai/component/f_button.dart';
import 'package:fast_ai/component/gradient_text.dart';
import 'package:fast_ai/gen/assets.gen.dart';
import 'package:fast_ai/gen/fonts.gen.dart';
import 'package:fast_ai/generated/locales.g.dart';
import 'package:fast_ai/pages/router/app_router.dart';
import 'package:fast_ai/services/api.dart';
import 'package:fast_ai/services/app_user.dart';
import 'package:fast_ai/values/app_colors.dart';
import 'package:fast_ai/values/app_text_style.dart';
import 'package:fast_ai/values/app_values.dart';
import 'package:flutter/material.dart';
import 'package:get/get_utils/get_utils.dart';

class FLoginRewardDialog extends StatelessWidget {
  const FLoginRewardDialog({super.key});

  void onTopCollect() async {
    await Api.getDailyReward();
    AppUser().getUserInfo();
    AppDialog.dismiss(tag: loginRewardTag);
  }

  void onTapVip() {
    AppRouter.pushVip(VipFrom.dailyrd);
  }

  @override
  Widget build(BuildContext context) {
    var isVip = AppUser().isVip.value;

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF333333),
        borderRadius: BorderRadius.circular(32),
      ),
      padding: EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      margin: EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          Assets.images.gem3s.image(width: 108, height: 82),
          SizedBox(height: 16),
          Row(
            spacing: 4,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Daily reward',
                style: AppTextStyle.openSans(
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                  color: Colors.white,
                ),
              ),
              GradientText(
                textAlign: TextAlign.center,
                data: isVip ? '+50' : '+20',
                gradient: const LinearGradient(
                  colors: [Color(0xFFF4FCFF), Color(0xFF49AAFF)],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  stops: [0.0, 1.0],
                ),
                style: AppTextStyle.openSans(fontSize: 16, fontWeight: FontWeight.w700),
              ),
            ],
          ),
          SizedBox(height: 20),
          isVip
              ? Column(
                  children: [
                    FButton(
                      onTap: onTopCollect,
                      color: AppColors.primary,
                      hasShadow: true,
                      child: Center(
                        child: Text(
                          LocaleKeys.collect.tr,
                          style: AppTextStyle.openSans(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                )
              : Column(
                  children: [
                    Row(
                      spacing: 2,
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text(
                          'Pro',
                          style: AppTextStyle.openSans(
                            fontSize: 16,
                            fontWeight: FontWeight.w400,
                            color: Colors.white,
                          ),
                        ),
                        GradientText(
                          textAlign: TextAlign.center,
                          data: "+50",
                          gradient: const LinearGradient(
                            colors: [Color(0xFFF4FCFF), Color(0xFF49AAFF)],
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            stops: [0.0, 1.0],
                          ),
                          style: AppTextStyle.openSans(fontSize: 16, fontWeight: FontWeight.w700),
                        ),
                        Assets.images.gems.image(width: 24),
                        Text(
                          LocaleKeys.every_day.tr,
                          style: AppTextStyle.openSans(
                            fontSize: 16,
                            fontWeight: FontWeight.w400,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                    FButton(
                      onTap: onTapVip,
                      color: AppColors.primary,
                      hasShadow: true,
                      child: Center(
                        child: Text(
                          LocaleKeys.got_to_pro.tr,
                          style: AppTextStyle.openSans(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 12),
                    FButton(
                      onTap: onTopCollect,
                      color: AppColors.white10,
                      child: Center(
                        child: Text(
                          LocaleKeys.collect.tr,
                          style: AppTextStyle.openSans(
                            fontSize: 16,
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
    );
  }
}
