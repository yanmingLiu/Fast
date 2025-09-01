import 'package:fast_ai/component/f_button.dart';
import 'package:fast_ai/data/sku_data.dart';
import 'package:fast_ai/generated/locales.g.dart';
import 'package:fast_ai/pages/vip/f_vip_timer.dart';
import 'package:fast_ai/pages/vip/sku_item_widget.dart';
import 'package:fast_ai/pages/vip/vip_controller.dart';
import 'package:fast_ai/services/app_cache.dart';
import 'package:fast_ai/values/app_colors.dart';
import 'package:fast_ai/values/app_text_style.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SkuListWidget extends StatelessWidget {
  const SkuListWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = VipController.to;

    return Obx(() {
      final skuList = controller.skuList;

      if (skuList.isEmpty) {
        return _buildEmptyState();
      }

      return Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          _buildSkuList(controller, skuList),
          const SizedBox(height: 28),
          if (AppCache().isBig) const VipTimer(),
          const SizedBox(height: 8),
          if (!AppCache().isBig) _buildSubscriptionInfo(controller),
          const SizedBox(height: 8),
          _buildPurchaseButton(controller),
        ],
      );
    });
  }

  /// 构建空状态
  Widget _buildEmptyState() {
    return Center(
      child: SizedBox(
        height: 100,
        child: Text(
          LocaleKeys.no_subscription_available.tr,
          textAlign: TextAlign.center,
          style: const TextStyle(color: Colors.white),
        ),
      ),
    );
  }

  /// 构建SKU列表
  Widget _buildSkuList(VipController controller, List<SkuData> skuList) {
    return SizedBox(
      height: 110,
      child: ListView.separated(
        controller: controller.scrollController,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(), // 更好的滚动体验
        clipBehavior: Clip.none, // 允许内容超出边界显示
        itemBuilder: (_, index) {
          final sku = skuList[index];

          return _ResponsiveSkuItem(controller: controller, skuData: sku);
        },
        separatorBuilder: (_, index) => const SizedBox(width: 8),
        itemCount: skuList.length,
      ),
    );
  }

  /// 构建订阅信息（小版本）
  Widget _buildSubscriptionInfo(VipController controller) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Obx(
        () => Text(
          controller.subscriptionDescription,
          style: TextStyle(
            color: Colors.white.withOpacity(0.85),
            fontSize: 10,
            fontWeight: FontWeight.w300,
          ),
        ),
      ),
    );
  }

  /// 构建购买按钮
  Widget _buildPurchaseButton(VipController controller) {
    return FButton(
      onTap: controller.purchaseSelectedProduct,
      margin: const EdgeInsets.symmetric(horizontal: 60),
      hasShadow: true,
      color: AppColors.primary,
      child: Center(
        child: Text(
          AppCache().isBig ? LocaleKeys.btn_continue.tr : LocaleKeys.subscribe.tr,
          style: AppTextStyle.openSans(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}

/// 响应式SKU项组件，仅在选中状态变化时重建
class _ResponsiveSkuItem extends StatelessWidget {
  final VipController controller;
  final SkuData skuData;

  const _ResponsiveSkuItem({required this.controller, required this.skuData});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final isSelected = controller.selectedProduct.value?.sku == skuData.sku;

      return SkuItemWidget(
        skuData: skuData,
        isSelected: isSelected,
        onTap: () => controller.selectProduct(skuData),
      );
    });
  }
}
