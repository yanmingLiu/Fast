import 'package:dotted_border/dotted_border.dart';
import 'package:easy_refresh/easy_refresh.dart';
import 'package:fast_ai/component/app_dialog.dart';
import 'package:fast_ai/component/f_button.dart';
import 'package:fast_ai/component/f_empty.dart';
import 'package:fast_ai/component/f_icon.dart';
import 'package:fast_ai/data/mask_data.dart';
import 'package:fast_ai/gen/assets.gen.dart';
import 'package:fast_ai/generated/locales.g.dart';
import 'package:fast_ai/pages/chat/mask_ctr.dart';
import 'package:fast_ai/values/app_text_style.dart';
import 'package:fast_ai/values/app_values.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class MaskPage extends GetView<MaskCtr> {
  const MaskPage({super.key});

  void _handleChangeMask() async {
    if (controller.needConfirmChange) {
      AppDialog.alert(
        message: LocaleKeys.mask_already_loaded.tr,
        cancelText: LocaleKeys.cancel.tr,
        confirmText: LocaleKeys.confirm.tr,
        onConfirm: () async {
          AppDialog.dismiss();
          await controller.changeMask();
        },
      );
    } else {
      await controller.changeMask();
    }
  }

  @override
  Widget build(BuildContext context) {
    // 初始化控制器
    Get.put(MaskCtr());
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        titleSpacing: 0.0,
        leadingWidth: 48,
        leading: FButton(
          width: 44,
          height: 44,
          color: Colors.transparent,
          onTap: () => Get.back(),
          child: Center(child: FIcon(assetName: Assets.svg.back)),
        ),
        title: Text(
          LocaleKeys.select_profile_mask.tr,
          style: const TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: EasyRefresh.builder(
              controller: controller.refreshController,
              onRefresh: controller.onRefresh,
              onLoad: controller.onLoad,
              childBuilder: (context, physics) {
                return _buildContent(context, physics);
              },
            ),
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 68).copyWith(
                bottom: MediaQuery.of(context).padding.bottom > 0
                    ? MediaQuery.of(context).padding.bottom
                    : 16,
              ),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF111111), Color(0xFF111111)],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  stops: [0.1, 0.15],
                ),
              ),
              child: FButton(
                onTap: _handleChangeMask,
                color: const Color(0xFF3F8DFD),
                hasShadow: true,
                child: Center(
                  child: Text(
                    LocaleKeys.pick_it.tr,
                    style: AppTextStyle.openSans(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 构建主要内容
  Widget _buildContent(BuildContext context, ScrollPhysics physics) {
    final bottom = MediaQuery.of(context).padding.bottom + 44;
    return SingleChildScrollView(
      physics: physics,
      padding: const EdgeInsets.all(16).copyWith(bottom: bottom),
      child: Column(
        children: [
          Text(
            LocaleKeys.profile_mask_description.tr,
            style: const TextStyle(fontSize: 14, color: Colors.white, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 16),
          InkWell(
            onTap: () {
              controller.pushEditPage();
            },
            child: DottedBorder(
              options: const RoundedRectDottedBorderOptions(
                color: Color(0x803F8DFD),
                strokeWidth: 1,
                dashPattern: [6, 6],
                radius: Radius.circular(16),
              ),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                width: double.infinity,
                child: Column(
                  spacing: 4,
                  children: [
                    Assets.images.add.image(width: 24),
                    Text(
                      LocaleKeys.create.tr,
                      style: const TextStyle(
                        color: Color(0xFF3F8DFD),
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 22),
          Obx(() {
            if (controller.maskList.isEmpty && controller.emptyType.value != null) {
              return SizedBox(
                width: double.infinity,
                height: 400,
                child: FEmpty(
                  type: controller.emptyType.value!,
                  paddingTop: 20,
                  physics: const NeverScrollableScrollPhysics(),
                  onReload: controller.emptyType.value == EmptyType.noNetwork
                      ? () => controller.refreshController.callRefresh()
                      : null,
                ),
              );
            }
            if (controller.maskList.isNotEmpty) {
              return _buildGridItems();
            }
            return const SizedBox.shrink();
          }),
        ],
      ),
    );
  }

  /// 构建网格项目列表
  Widget _buildGridItems() {
    return Obx(
      () => ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemBuilder: (_, index) {
          return _buildItem(controller.maskList[index]);
        },
        separatorBuilder: (_, idx) => const SizedBox(height: 16),
        itemCount: controller.maskList.length,
      ),
    );
  }

  /// 构建Mask项目
  Widget _buildItem(MaskData mask) {
    return Obx(() {
      final isSelected = controller.selectedMask.value?.id == mask.id;
      return GestureDetector(
        onTap: () {
          controller.selectMask(mask);
        },
        child: Row(
          spacing: 8,
          children: [
            GestureDetector(
              onTap: () => controller.pushEditPage(mask: mask),
              child: Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Assets.images.editm.image(width: 24),
              ),
            ),
            Expanded(
              child: Stack(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    margin: const EdgeInsets.only(top: 12),
                    width: double.infinity,
                    constraints: const BoxConstraints(minHeight: 64),
                    decoration: BoxDecoration(
                      color: const Color(0x333F8DFD),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isSelected ? const Color(0xFF3F8DFD) : Colors.transparent,
                        width: 1,
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          mask.description ?? '',
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.start,
                          maxLines: 2,
                          style: AppTextStyle.openSans(
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Row(
                    children: [
                      const SizedBox(width: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          color: const Color(0xFF3F8DFD),
                          border: Border.all(color: const Color(0x33FFFFFF), width: 1),
                        ),
                        child: Row(
                          spacing: 4,
                          children: [
                            Gender.fromValue(mask.gender).icon,
                            Text(
                              mask.profileName ?? '',
                              style: const TextStyle(
                                fontSize: 10,
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    });
  }
}
