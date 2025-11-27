import 'dart:async';

import 'package:fast_ai/data/p_d_data.dart';
import 'package:fast_ai/generated/locales.g.dart';
import 'package:fast_ai/services/f_cache.dart';
import 'package:fast_ai/services/f_log_event.dart';
import 'package:fast_ai/services/f_service.dart';
import 'package:fast_ai/tools/iap_tool.dart';
import 'package:fast_ai/values/values.dart';
import 'package:flutter/material.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:get/get.dart';

class VipController extends GetxController {
  static VipController get to => Get.find();

  // 响应式状态变量
  final RxList<PDData> skuList = <PDData>[].obs;
  final Rx<PDData?> selectedProduct = Rx<PDData?>(null);
  final RxString contentText = ''.obs;
  final RxBool showBackButton = false.obs;
  final RxBool isLoading = false.obs;

  late ProFrom? vipFrom;
  final ScrollController scrollController = ScrollController();

  @override
  void onInit() {
    super.onInit();

    // 获取传入参数
    vipFrom = Get.arguments ?? ProFrom.homevip;

    // 初始化数据
    _initializeData();
  }

  @override
  void onReady() {
    super.onReady();

    // 页面渲染完成后执行
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToSelectedItemWithoutAnimation();
    });
  }

  @override
  void onClose() {
    scrollController.dispose();
    _scrollTimer?.cancel();
    super.onClose();
  }

  /// 初始化数据
  Future<void> _initializeData() async {
    _updateContentText();
    await _loadSubscriptionData();
    _logPageEvent();
    _setupBackButtonDisplay();
  }

  /// 加载订阅数据
  Future<void> _loadSubscriptionData() async {
    try {
      isLoading.value = true;

      await FService().getIdfa();
      SmartDialog.showLoading();

      await IAPTool().query();
      skuList.value = IAPTool().subscriptionList;

      // 选择默认商品
      selectedProduct.value =
          skuList.firstWhereOrNull((e) => e.defaultSku == true);
      _updateContentText();
    } catch (e) {
      debugPrint('加载订阅数据失败: $e');
    } finally {
      isLoading.value = false;
      SmartDialog.dismiss();
    }
  }

  /// 更新内容文本
  void _updateContentText() {
    if (FCache().isBig) {
      final gems = selectedProduct.value?.number ?? 150;
      contentText.value =
          LocaleKeys.vip_get_2.trParams({'gems': gems.toString()});
    } else {
      contentText.value = LocaleKeys.vip_get_1.tr;
    }
  }

  /// 记录页面事件
  void _logPageEvent() {
    logEvent(FCache().isBig ? 't_vipb' : 't_vipa');
  }

  /// 设置返回按钮显示
  void _setupBackButtonDisplay() {
    if (FCache().isBig) {
      Future.delayed(const Duration(seconds: 3), () {
        showBackButton.value = true;
      });
    } else {
      showBackButton.value = true;
    }
  }

  /// 选择商品
  void selectProduct(PDData product) {
    if (selectedProduct.value?.sku == product.sku) return; // 避免重复选择

    selectedProduct.value = product;
    _updateContentText();

    // 使用防抖动滚动
    _debounceScrollToSelected();
  }

  // 防抖动滚动定时器
  Timer? _scrollTimer;

  void _debounceScrollToSelected() {
    _scrollTimer?.cancel();
    _scrollTimer = Timer(const Duration(milliseconds: 100), () {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scrollToSelectedItem();
      });
    });
  }

  /// 购买商品
  void purchaseSelectedProduct() {
    final product = selectedProduct.value;
    if (product == null) return;

    logEvent(FCache().isBig ? 'c_vipb_subs' : 'c_vipa_subs');
    IAPTool().buy(product, vipFrom: vipFrom);
  }

  /// 恢复购买
  void restorePurchases() {
    IAPTool().restore();
  }

  /// 获取价格信息
  String get currentPrice =>
      selectedProduct.value?.productDetails?.price ?? '0.0';

  /// 获取单位信息
  String get currentUnit {
    final skuType = selectedProduct.value?.skuType;
    if (skuType == 2) return LocaleKeys.month.tr;
    if (skuType == 3) return LocaleKeys.year.tr;
    return '';
  }

  /// 获取订阅描述
  String get subscriptionDescription {
    final product = selectedProduct.value;
    if (product == null) return '';

    final price = currentPrice;
    final unit = currentUnit;
    final skuType = product.skuType;

    if (skuType == 4) {
      return LocaleKeys.vip_price_lt_desc.trParams({'price': price});
    } else {
      return LocaleKeys.subscription_info
          .trParams({'price': price, 'unit': unit});
    }
  }

  /// 无动画滚动到选中项
  void _scrollToSelectedItemWithoutAnimation() {
    final product = selectedProduct.value;
    if (product == null || !scrollController.hasClients) return;

    final index = skuList.indexWhere((element) => element.sku == product.sku);
    if (index == -1) return;

    _scrollToIndex(index, animated: false);
  }

  /// 滚动到选中项
  void _scrollToSelectedItem() {
    final product = selectedProduct.value;
    if (product == null || !scrollController.hasClients) return;

    final index = skuList.indexWhere((element) => element.sku == product.sku);
    if (index == -1) return;

    _scrollToIndex(index, animated: true);
  }

  /// 滚动到指定索引
  void _scrollToIndex(int index, {required bool animated}) {
    if (index == 0) {
      // 滚动到最左边
      if (animated) {
        scrollController.animateTo(
          0,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      } else {
        scrollController.jumpTo(0);
      }
    } else if (index == skuList.length - 1) {
      // 滚动到最右边
      final maxScrollExtent = scrollController.position.maxScrollExtent;
      if (animated) {
        scrollController.animateTo(
          maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      } else {
        scrollController.jumpTo(maxScrollExtent);
      }
    } else {
      // 居中显示
      try {
        final screenWidth = Get.width;
        final itemWidth = (screenWidth - 32 - 40) / 2 + 8;
        final offset = index * itemWidth -
            (scrollController.position.viewportDimension - itemWidth) / 2;
        final clampedOffset =
            offset.clamp(0.0, scrollController.position.maxScrollExtent);

        if (animated) {
          scrollController.animateTo(
            clampedOffset,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
          );
        } else {
          scrollController.jumpTo(clampedOffset);
        }
      } catch (e) {
        debugPrint('滚动计算错误: $e');
      }
    }
  }
}
