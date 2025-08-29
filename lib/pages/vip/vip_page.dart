import 'package:fast_ai/component/f_button.dart';
import 'package:fast_ai/component/f_icon.dart';
import 'package:fast_ai/gen/assets.gen.dart';
import 'package:fast_ai/generated/locales.g.dart';
import 'package:fast_ai/pages/vip/privacy_view.dart';
import 'package:fast_ai/pages/vip/sku_list_widget.dart';
import 'package:fast_ai/pages/vip/vip_content_widget.dart';
import 'package:fast_ai/pages/vip/vip_controller.dart';
import 'package:fast_ai/services/app_cache.dart';
import 'package:fast_ai/tools/iap_tool.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class VipPage extends GetView<VipController> {
  const VipPage({super.key});

  @override
  Widget build(BuildContext context) {
    // 初始化控制器
    Get.put(VipController());

    return Scaffold(extendBodyBehindAppBar: true, appBar: _buildAppBar(), body: _buildBody());
  }

  /// 构建应用栏
  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      elevation: 0,
      scrolledUnderElevation: 0.0,
      backgroundColor: Colors.transparent,
      leadingWidth: 100,
      leading: Obx(
        () => controller.showBackButton.value
            ? Row(
                children: [
                  const SizedBox(width: 16),
                  FButton(
                    width: 44,
                    height: 44,
                    color: const Color(0x33FFFFFF),
                    borderRadius: BorderRadius.circular(22),
                    onTap: () => Get.back(),
                    child: Center(child: FIcon(assetName: Assets.svg.close)),
                  ),
                ],
              )
            : const SizedBox(),
      ),
      actions: [_buildRestoreButton()],
    );
  }

  /// 构建恢复购买按钮
  Widget _buildRestoreButton() {
    return GestureDetector(
      onTap: () => IAPTool().restore(),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            height: 26,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            alignment: Alignment.centerLeft,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(13),
              border: Border.all(width: 1, color: const Color(0x80FFFFFF)),
            ),
            child: Text(
              LocaleKeys.restore.tr,
              style: const TextStyle(
                fontSize: 12,
                color: Color(0xB3FFFFFF),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const SizedBox(width: 20),
        ],
      ),
    );
  }

  /// 构建页面主体
  Widget _buildBody() {
    return Stack(children: [_buildBackground(), _buildContent()]);
  }

  /// 构建背景
  Widget _buildBackground() {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: AppCache().isBig
          ? Assets.images.vipPageBg2.image(fit: BoxFit.cover)
          : Assets.images.vipPageBg1.image(fit: BoxFit.cover),
    );
  }

  /// 构建内容
  Widget _buildContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.only(top: 150),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Obx(() => VipContentWidget(contentText: controller.contentText.value)),
          ),
          const SkuListWidget(),
          const SizedBox(height: 8),
          PrivacyView(type: AppCache().isBig ? PolicyBottomType.vip2 : PolicyBottomType.vip1),
          const SizedBox(height: 12),
        ],
      ),
    );
  }
}
