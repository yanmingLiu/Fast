import 'package:fast_ai/component/f_button.dart';
import 'package:fast_ai/component/f_dialog.dart';
import 'package:fast_ai/component/f_grad_text.dart';
import 'package:fast_ai/gen/assets.gen.dart';
import 'package:fast_ai/generated/locales.g.dart';
import 'package:fast_ai/pages/router/n_t_n.dart';
import 'package:fast_ai/services/f_api.dart';
import 'package:fast_ai/services/m_y.dart';
import 'package:fast_ai/values/theme_colors.dart';
import 'package:fast_ai/values/theme_style.dart';
import 'package:fast_ai/values/values.dart';
import 'package:flutter/material.dart';
import 'package:get/get_utils/get_utils.dart';

class FLoginRewardDialog extends StatelessWidget {
  const FLoginRewardDialog({super.key});

  void onTopCollect() async {
    await FApi.getDailyReward();
    MY().getUserInfo();
    FDialog.dismiss(tag: loginRewardTag);
  }

  void onTapVip() {
    NTN.pushVip(ProFrom.dailyrd);
  }

  @override
  Widget build(BuildContext context) {
    var isVip = MY().isVip.value;

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
                style: ThemeStyle.openSans(
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                  color: Colors.white,
                ),
              ),
              FGradText(
                textAlign: TextAlign.center,
                data: isVip ? '+50' : '+20',
                gradient: const LinearGradient(
                  colors: [Color(0xFFF4FCFF), Color(0xFF49AAFF)],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  stops: [0.0, 1.0],
                ),
                style: ThemeStyle.openSans(
                    fontSize: 16, fontWeight: FontWeight.w700),
              ),
            ],
          ),
          SizedBox(height: 20),
          isVip
              ? Column(
                  children: [
                    FButton(
                      onTap: onTopCollect,
                      color: ThemeColors.primary,
                      hasShadow: true,
                      child: Center(
                        child: Text(
                          LocaleKeys.collect.tr,
                          style: ThemeStyle.openSans(
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
                          style: ThemeStyle.openSans(
                            fontSize: 16,
                            fontWeight: FontWeight.w400,
                            color: Colors.white,
                          ),
                        ),
                        FGradText(
                          textAlign: TextAlign.center,
                          data: "+50",
                          gradient: const LinearGradient(
                            colors: [Color(0xFFF4FCFF), Color(0xFF49AAFF)],
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            stops: [0.0, 1.0],
                          ),
                          style: ThemeStyle.openSans(
                              fontSize: 16, fontWeight: FontWeight.w700),
                        ),
                        Assets.images.gems.image(width: 24),
                        Text(
                          LocaleKeys.every_day.tr,
                          style: ThemeStyle.openSans(
                            fontSize: 16,
                            fontWeight: FontWeight.w400,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                    FButton(
                      onTap: onTapVip,
                      color: ThemeColors.primary,
                      hasShadow: true,
                      child: Center(
                        child: Text(
                          LocaleKeys.got_to_pro.tr,
                          style: ThemeStyle.openSans(
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
                      color: ThemeColors.white10,
                      child: Center(
                        child: Text(
                          LocaleKeys.collect.tr,
                          style: ThemeStyle.openSans(
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
