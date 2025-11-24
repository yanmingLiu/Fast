import 'package:fast_ai/component/f_dialog.dart';
import 'package:fast_ai/data/a_pop.dart';
import 'package:fast_ai/generated/locales.g.dart';
import 'package:fast_ai/pages/chat/msg_ctr.dart';
import 'package:fast_ai/pages/home/home_ctr.dart';
import 'package:fast_ai/services/f_api.dart';
import 'package:fast_ai/values/values.dart';
import 'package:get/get.dart';

class RoleCenterCtr extends GetxController {
  var images = <APopImage>[].obs;
  var changeCount = 0.obs;
  late APop role;

  var isLoading = false.obs;

  var collect = false.obs;

  final msgCtr = Get.find<MsgCtr>();

  @override
  void onInit() {
    super.onInit();

    final arguments = Get.arguments;
    if (arguments != null && arguments is APop) {
      role = arguments;
    }

    images.value = role.images ?? [];

    collect.value = role.collect ?? false;

    ever(msgCtr.roleImagesChaned, (_) {
      images.value = msgCtr.role.images ?? [];
      changeCount.value++;
    });
  }

  void deleteChat() async {
    FDialog.alert(
      message: LocaleKeys.delete_chat_confirmation.tr,
      cancelText: LocaleKeys.cancel.tr,
      onConfirm: () async {
        FDialog.dismiss();
        var res = await Get.find<MsgCtr>().deleteConv();
        if (res) {
          Get.until((route) => route.isFirst);
        }
      },
    );
  }

  void clearHistory() async {
    FDialog.alert(
      message: LocaleKeys.clear_history_confirmation.tr,
      cancelText: LocaleKeys.cancel.tr,
      onConfirm: () async {
        FDialog.dismiss();
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
      final res = await FApi.cancelCollectRole(id);
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
      final res = await FApi.collectRole(id);
      if (res) {
        role.collect = true;
        collect.value = true;
        Get.find<HomeCtr>().followEvent.value = (
          FollowEvent.follow,
          id,
          DateTime.now().millisecondsSinceEpoch,
        );

        if (FDialog.rateCollectShowd == false) {
          FDialog.showRateUs(LocaleKeys.rate_us_like.tr);
          FDialog.rateCollectShowd = true;
        }
      }
      isLoading.value = false;
    }
  }
}
