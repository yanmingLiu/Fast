import 'package:fast_ai/component/app_dialog.dart';
import 'package:fast_ai/component/f_empty.dart';
import 'package:fast_ai/data/role_data.dart';
import 'package:fast_ai/generated/locales.g.dart';
import 'package:fast_ai/pages/home/home_ctr.dart';
import 'package:fast_ai/services/api.dart';
import 'package:fast_ai/values/app_values.dart';
import 'package:get/get.dart';

class SearchCtr extends GetxController {
  int page = 1;
  int size = 1000;

  var list = <Role>[].obs;
  var type = Rx<EmptyType?>(EmptyType.noData);

  var searchQuery = ''.obs;
  var currentRequestId = 0.obs; // 当前请求的 ID

  @override
  void onInit() {
    super.onInit();

    debounce(searchQuery, (_) {
      // 生成一个唯一的请求 ID
      var requestId = DateTime.now().millisecondsSinceEpoch;
      currentRequestId.value = requestId;

      // API 请求
      search(searchQuery.value, requestId);
    }, time: const Duration(milliseconds: 500));
  }

  Future<void> search(String searchText, int requestId) async {
    try {
      if (searchText.isEmpty) {
        list.clear();
        type.value = EmptyType.noData;
        return;
      }

      final res = await Api.homeList(page: page, size: size, name: searchText);

      // 如果当前的请求 ID 不是最新的，就忽略它
      if (requestId != currentRequestId.value) {
        return;
      }

      if (page == 1) {
        list.clear();
      }
      type.value = null;
      list.addAll(res?.records ?? []);

      type.value = list.isEmpty ? EmptyType.noData : null;
    } catch (e) {
      type.value = list.isEmpty ? EmptyType.noData : null;
    }
  }

  void onCollect(int index, Role role) async {
    final role = list[index];
    final chatId = role.id;
    if (chatId == null) {
      return;
    }
    if (role.collect == true) {
      final res = await Api.cancelCollectRole(chatId);
      if (res) {
        role.collect = false;
        list.refresh();

        Get.find<HomeCtr>().followEvent.value = (
          FollowEvent.unfollow,
          chatId,
          DateTime.now().millisecondsSinceEpoch,
        );
      }
    } else {
      final res = await Api.collectRole(chatId);
      if (res) {
        role.collect = true;
        list.refresh();

        Get.find<HomeCtr>().followEvent.value = (
          FollowEvent.follow,
          chatId,
          DateTime.now().millisecondsSinceEpoch,
        );

        if (AppDialog.rateCollectShowd == false) {
          AppDialog.showRateUs(LocaleKeys.rate_us_like.tr);
          AppDialog.rateCollectShowd = true;
        }
      }
    }
    // try {
    //   if (Get.isRegistered<ChatFollowController>()) {
    //     Get.find<ChatFollowController>().onRefresh();
    //   }
    // } catch (e) {}
  }
}
