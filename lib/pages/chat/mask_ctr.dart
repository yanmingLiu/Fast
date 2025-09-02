import 'package:easy_refresh/easy_refresh.dart';
import 'package:fast_ai/component/f_empty.dart';
import 'package:fast_ai/data/mask_data.dart';
import 'package:fast_ai/pages/chat/msg_ctr.dart';
import 'package:fast_ai/pages/router/routers.dart';
import 'package:fast_ai/services/api.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class MaskCtr extends GetxController {
  // 响应式状态变量
  final RxList<MaskData> maskList = <MaskData>[].obs;
  final Rx<MaskData?> selectedMask = Rx<MaskData?>(null);
  final RxBool hasMore = true.obs;
  final RxInt currentPage = 1.obs;
  final RxBool isLoading = false.obs;
  final Rx<EmptyType?> emptyType = Rx<EmptyType?>(null);

  // 常量
  static const int pageSize = 10;

  // 控制器
  late final EasyRefreshController refreshController;
  final msgCtr = Get.find<MsgCtr>();

  @override
  void onInit() {
    super.onInit();
    refreshController = EasyRefreshController(controlFinishRefresh: true, controlFinishLoad: true);

    // 延迟触发刷新
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Future.delayed(const Duration(milliseconds: 300)).then((_) {
        refreshController.callRefresh();
      });
    });
  }

  @override
  void onClose() {
    refreshController.dispose();
    super.onClose();
  }

  /// 下拉刷新
  Future<void> onRefresh() async {
    currentPage.value = 1;
    await _fetchData();
    refreshController.finishRefresh();
    refreshController.resetFooter();
  }

  /// 上拉加载更多
  Future<void> onLoad() async {
    currentPage.value += 1;
    await _fetchData();
    refreshController.finishLoad(hasMore.value ? IndicatorResult.none : IndicatorResult.noMore);
  }

  /// 获取数据
  Future<void> _fetchData() async {
    if (isLoading.value) {
      return;
    }

    try {
      isLoading.value = true;
      final response = await Api.getMaskList(page: currentPage.value, size: pageSize);

      hasMore.value = (response?.records?.length ?? 0) >= pageSize;

      if (currentPage.value == 1) {
        maskList.clear();
      }
      maskList.addAll(response?.records ?? []);

      // 自动选择当前会话的 mask
      if (selectedMask.value == null && maskList.isNotEmpty && msgCtr.session.profileId != null) {
        selectedMask.value = maskList.firstWhereOrNull(
          (element) => element.id == msgCtr.session.profileId,
        );
      }

      emptyType.value = maskList.isEmpty ? EmptyType.noData : null;
    } catch (e) {
      emptyType.value = maskList.isEmpty ? EmptyType.noNetwork : null;
      if (currentPage.value > 1) {
        currentPage.value -= 1;
      }
    } finally {
      isLoading.value = false;
    }
  }

  /// 选择 mask
  void selectMask(MaskData mask) {
    selectedMask.value = mask;
  }

  /// 推送编辑页面
  Future<void> pushEditPage({MaskData? mask}) async {
    await Get.toNamed(Routers.maskEdit, arguments: mask);
    onRefresh();
  }

  /// 更换 mask
  Future<void> changeMask() async {
    final maskId = selectedMask.value?.id;
    if (maskId == null) {
      return;
    }

    if (maskId == msgCtr.session.profileId) {
      Get.back();
      return;
    }

    final res = await msgCtr.changeMask(maskId);
    if (res) {
      Get.back();
    }
  }

  /// 检查是否需要确认更换 mask
  bool get needConfirmChange {
    final maskId = selectedMask.value?.id;
    return maskId != null && msgCtr.session.profileId != maskId;
  }
}
