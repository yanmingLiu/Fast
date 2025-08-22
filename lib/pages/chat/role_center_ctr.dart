import 'package:fast_ai/component/app_dialog.dart';
import 'package:fast_ai/component/f_loading.dart';
import 'package:fast_ai/component/f_toast.dart';
import 'package:fast_ai/data/role_data.dart';
import 'package:fast_ai/generated/locales.g.dart';
import 'package:fast_ai/pages/chat/msg_ctr.dart';
import 'package:fast_ai/pages/home/home_ctr.dart';
import 'package:fast_ai/services/api.dart';
import 'package:fast_ai/values/app_values.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

class RoleCenterCtr extends GetxController {
  var images = <RoleImage>[].obs;
  late Role role;

  var isLoading = false.obs;

  var collect = false.obs;

  final msgCtr = Get.find<MsgCtr>();

  @override
  void onInit() {
    super.onInit();

    final arguments = Get.arguments;
    if (arguments != null && arguments is Role) {
      role = arguments;
    }

    images.value = role.images ?? [];

    collect.value = role.collect ?? false;

    ever(msgCtr.roleImagesChaned, (_) {
      images.value = msgCtr.role.images ?? [];
    });
  }

  void deleteChat() async {
    AppDialog.alert(
      message: LocaleKeys.delete_chat_confirmation.tr,
      cancelText: LocaleKeys.cancel.tr,
      onConfirm: () async {
        AppDialog.dismiss();
        var res = await Get.find<MsgCtr>().deleteConv();
        if (res) {
          Get.until((route) => route.isFirst);
        }
      },
    );
  }

  void clearHistory() async {
    AppDialog.alert(
      message: LocaleKeys.clear_history_confirmation.tr,
      cancelText: LocaleKeys.cancel.tr,
      onConfirm: () async {
        AppDialog.dismiss();
        await msgCtr.resetConv();
      },
    );
  }

  void report() {
    void request() async {
      FLoading.showLoading();
      await Future.delayed(const Duration(seconds: 1));
      FLoading.dismiss();
      FToast.toast(LocaleKeys.report_successful.tr);

      AppDialog.dismiss();
    }

    Map<String, Function> actsion = {
      LocaleKeys.spam.tr: request,
      LocaleKeys.violence.tr: request,
      LocaleKeys.child_abuse.tr: request,
      LocaleKeys.copyright.tr: request,
      LocaleKeys.personal_details.tr: request,
      LocaleKeys.illegal_drugs.tr: request,
    };

    AppDialog.show(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 20),
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: Color(0xFF333333),
        ),
        child: ListView.separated(
          padding: EdgeInsets.zero,
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          itemCount: actsion.keys.length,
          itemBuilder: (_, index) {
            final fn = actsion.values.toList()[index];
            return InkWell(
              onTap: () {
                fn.call();
              },
              child: SizedBox(
                height: 54,
                child: Center(
                  child: Text(
                    actsion.keys.toList()[index],
                    textAlign: TextAlign.center,
                    style: GoogleFonts.openSans(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ),
              ),
            );
          },
          separatorBuilder: (context, index) {
            return Container(height: 1, color: const Color(0x1AFFFFFF));
          },
        ),
      ),
      clickMaskDismiss: false,
    );
  }

  void onCollect() async {
    final id = role.id;
    if (id == null) {
      return;
    }
    if (isLoading.value) {
      return;
    }

    if (collect.value) {
      final res = await Api.cancelCollectRole(id);
      if (res) {
        role.collect = false;
        collect.value = false;
        Get.find<HomeCtr>().followEvent.value = (
          FollowEvent.unfollow,
          id,
          DateTime.now().millisecondsSinceEpoch,
        );
      }
      isLoading.value = false;
    } else {
      final res = await Api.collectRole(id);
      if (res) {
        role.collect = true;
        collect.value = true;
        Get.find<HomeCtr>().followEvent.value = (
          FollowEvent.follow,
          id,
          DateTime.now().millisecondsSinceEpoch,
        );

        if (AppDialog.rateCollectShowd == false) {
          AppDialog.showRateUs(LocaleKeys.rate_us_like.tr);
          AppDialog.rateCollectShowd = true;
        }
      }
      isLoading.value = false;
    }
  }
}
