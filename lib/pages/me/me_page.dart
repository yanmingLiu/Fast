import 'package:fast_ai/component/f_switch.dart';
import 'package:fast_ai/gen/assets.gen.dart';
import 'package:fast_ai/generated/locales.g.dart';
import 'package:fast_ai/pages/me/me_ctr.dart';
import 'package:fast_ai/pages/me/me_item.dart';
import 'package:fast_ai/pages/me/me_not_vip.dart';
import 'package:fast_ai/pages/me/me_vip.dart';
import 'package:fast_ai/pages/router/n_t_n.dart';
import 'package:fast_ai/services/f_log_event.dart';
import 'package:fast_ai/services/m_y.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class MePage extends StatelessWidget {
  const MePage({super.key});

  @override
  Widget build(BuildContext context) {
    final ctr = Get.put(MeCtr());

    return Scaffold(
      body: Stack(
        children: [
          Positioned(
              top: 0, left: 0, right: 0, child: Assets.images.pagePgMe.image()),
          SafeArea(
            bottom: false,
            child: SingleChildScrollView(
              child: Column(
                children: [
                  SizedBox(height: 8),
                  Obx(() {
                    final isVip = MY().isVip.value;
                    return isVip ? const MeVip() : const MeNotVip();
                  }),
                  Obx(() {
                    return MeItem(
                      sectionTitle: LocaleKeys.nickname.tr,
                      title: ctr.nickname.value,
                      onTap: ctr.changeNickName,
                      showTopRadius: true,
                      showBottomRadius: true,
                      top: 20,
                    );
                  }),
                  Obx(() {
                    var isAuto = MY().autoTranslate.value;
                    return MeItem(
                      sectionTitle: LocaleKeys.support.tr,
                      title: LocaleKeys.auto_trans.tr,
                      subWidget: FSwitch(
                          value: isAuto, onChanged: ctr.autoTranslation),
                      top: 20,
                    );
                  }),
                  MeItem(
                      title: LocaleKeys.feedback.tr,
                      onTap: () => NTN.toEmail()),
                  MeItem(
                    title: LocaleKeys.set_chat_background.tr,
                    onTap: () {
                      ctr.changeChatBackground();
                    },
                  ),
                  Obx(
                    () => MeItem(
                      title: LocaleKeys.app_version.tr,
                      subtitle: ctr.version.value,
                      onTap: () => NTN.openAppStore(),
                    ),
                  ),
                  MeItem(
                    sectionTitle: LocaleKeys.legal.tr,
                    title: LocaleKeys.privacy_policy.tr,
                    onTap: () => NTN.toPrivacy(),
                    onTapSection: () {
                      Get.to(LogPage());
                    },
                    top: 20,
                  ),
                  MeItem(
                      title: LocaleKeys.terms_of_use.tr,
                      onTap: () => NTN.toTerms()),
                  const SizedBox(height: kBottomNavigationBarHeight + 60),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
