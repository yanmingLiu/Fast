import 'package:fast_ai/component/app_dialog.dart';
import 'package:fast_ai/data/role_data.dart';
import 'package:fast_ai/generated/locales.g.dart';
import 'package:fast_ai/pages/chat/msg_ctr.dart';
import 'package:fast_ai/pages/home/home_ctr.dart';
import 'package:fast_ai/services/api.dart';
import 'package:fast_ai/values/app_values.dart';
import 'package:get/get.dart';

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
