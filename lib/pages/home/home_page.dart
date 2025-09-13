import 'package:fast_ai/component/f_button.dart';
import 'package:fast_ai/component/f_empty.dart';
import 'package:fast_ai/component/f_icon.dart';
import 'package:fast_ai/component/f_loading.dart';
import 'package:fast_ai/component/linked_tab_page_controller.dart';
import 'package:fast_ai/gen/assets.gen.dart';
import 'package:fast_ai/pages/home/home_call_ctr.dart';
import 'package:fast_ai/pages/home/home_ctr.dart';
import 'package:fast_ai/pages/router/app_router.dart';
import 'package:fast_ai/services/app_user.dart';
import 'package:fast_ai/values/app_colors.dart'; // 统一颜色管理
import 'package:fast_ai/values/app_values.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../services/app_service.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with SingleTickerProviderStateMixin {
  final ctr = Get.put(HomeCtr());

  late LinkedTabPageController _linkedController;

  @override
  void initState() {
    super.initState();
    Get.put(HomeCallCtr());
  }

  @override
  void dispose() {
    // 确保控制器被正确销毁
    _linkedController.dispose();
    // 清理 GetX 控制器
    Get.delete<HomeCtr>();
    Get.delete<HomeCallCtr>();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned(top: 0, left: 0, right: 0, child: Assets.images.pageBg.image()),
        Scaffold(
          backgroundColor: Colors.transparent,
          appBar: buildAppBar(),
          body: GetBuilder<HomeCtr>(
            builder: (_) {
              if (ctr.categroyList.isEmpty || ctr.pages.isEmpty) {
                return FEmpty(type: EmptyType.loading);
              }

              _linkedController = LinkedTabPageController(
                items: ctr.categroyList,
                onIndexChanged: (index) => log.d("当前选中 index: $index"),
                onItemsChanged: (items) => log.d("数据源更新: $items"),
              );

              return AnimatedBuilder(
                animation: _linkedController,
                builder: (_, v) {
                  if (_linkedController.items.isEmpty) {
                    return FLoading.loadingWidget();
                  }
                  return Column(
                    children: [
                      buildCategory(),
                      Expanded(
                        child: PageView(
                          controller: _linkedController.pageController,
                          pageSnapping: true,
                          onPageChanged: (index) {
                            _linkedController.handlePageChanged(index);
                            ctr.categroy.value = ctr.categroyList[index];
                          },
                          physics: BouncingScrollPhysics(),
                          children: ctr.pages,
                        ),
                      ),
                    ],
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget buildCategory() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        spacing: 12,
        children: [
          FButton(
            onTap: ctr.onTapFilter,
            width: 44,
            height: 44,
            borderRadius: BorderRadius.all(Radius.circular(22)),
            child: Center(
              child: Obx(
                () => FIcon(
                  assetName: Assets.svg.filter,
                  width: 24,
                  color: ctr.selectTags.isEmpty ? Colors.white : AppColors.primary,
                ),
              ),
            ),
          ),
          Expanded(
            child: Container(
              height: 44,
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.white10,
                border: BoxBorder.all(color: AppColors.white20, width: 1),
                borderRadius: BorderRadius.circular(22),
              ),
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: ctr.categroyList.length,
                controller: _linkedController.scrollController,
                separatorBuilder: (context, index) => SizedBox(width: 16),
                itemBuilder: (context, index) {
                  final data = ctr.categroyList[index];
                  return GestureDetector(
                    child: AnimatedBuilder(
                      animation: _linkedController,
                      builder: (_, v) {
                        final isActive = _linkedController.index == index;
                        return buildTabItem(
                          key: _linkedController.getTabKey(index),
                          title: data.title,
                          isActive: isActive,
                          onTap: () {
                            ctr.onTapCate(data);
                            _linkedController.select(index);
                          },
                        );
                      },
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildTabItem({
    Key? key,
    required String title,
    required bool isActive,
    void Function()? onTap,
  }) {
    return FButton(
      key: key,
      borderRadius: BorderRadius.circular(16),
      color: isActive ? AppColors.primary : Colors.transparent,
      onTap: onTap,
      padding: EdgeInsets.symmetric(horizontal: 8),
      constraints: BoxConstraints(minWidth: 50),
      child: Center(
        child: Text(
          title,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: Colors.white,
            fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
            fontSize: 14,
          ),
        ),
      ),
    );
  }

  AppBar buildAppBar() {
    return AppBar(
      backgroundColor: Colors.transparent,
      leadingWidth: 200,
      leading: Container(
        padding: EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          children: [
            Obx(() {
              final isVip = AppUser().isVip.value;
              if (isVip) {
                return SizedBox();
              }
              return FButton(
                onTap: () {
                  AppRouter.pushVip(VipFrom.homevip);
                },
                width: 44,
                height: 44,
                margin: EdgeInsetsDirectional.only(end: 8),
                borderRadius: BorderRadius.all(Radius.circular(22)),
                child: Center(child: Assets.images.member.image(width: 24)),
              );
            }),
            FButton(
              height: 44,
              borderRadius: BorderRadius.circular(22),
              constraints: BoxConstraints(minWidth: 44),
              padding: EdgeInsets.symmetric(horizontal: 12),
              onTap: () {
                AppRouter.pushGem(ConsumeFrom.home);
              },
              child: Center(
                child: Row(
                  spacing: 4,
                  children: [
                    Assets.images.gems.image(width: 24),
                    Obx(
                      () => Text(
                        AppUser().balance.toString(),
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Spacer(),
          ],
        ),
      ),
      actions: [
        FButton(
          onTap: () {
            AppRouter.pushSearch();
          },
          width: 44,
          height: 44,
          borderRadius: BorderRadius.all(Radius.circular(22)),
          child: Center(child: FIcon(assetName: Assets.svg.search)),
        ),
        SizedBox(width: 16),
      ],
    );
  }
}
