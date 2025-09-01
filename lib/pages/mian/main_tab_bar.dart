import 'dart:ui';

import 'package:fast_ai/component/f_button.dart';
import 'package:fast_ai/component/f_icon.dart';
import 'package:fast_ai/gen/assets.gen.dart';
import 'package:fast_ai/generated/locales.g.dart';
import 'package:fast_ai/pages/mian/main_page.dart';
import 'package:fast_ai/values/app_colors.dart'; // 统一颜色管理
import 'package:flutter/material.dart';
import 'package:get/get_utils/src/extensions/internacionalization.dart';

class MainTabBar extends StatelessWidget {
  const MainTabBar({super.key, this.onTapItem});

  final void Function(MainTabBarIndex)? onTapItem;

  @override
  Widget build(BuildContext context) {
    final itemVertical = 10.0;
    final itemHorizontal = 10.0;
    final itemHeight = (kBottomNavigationBarHeight - itemVertical * 2);
    final itemRadius = itemHeight / 2;

    return SafeArea(
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: 25,
          vertical: MediaQuery.of(context).padding.bottom > 0 ? 0 : 12,
        ),
        child: Container(
          height: kBottomNavigationBarHeight,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.1),
            borderRadius: BorderRadiusGeometry.circular(kBottomNavigationBarHeight / 2),
          ),
          child: ClipRRect(
            borderRadius: BorderRadiusGeometry.circular(kBottomNavigationBarHeight / 2),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: itemHorizontal, vertical: itemVertical),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  spacing: 30,
                  children: [
                    _buildItem(
                      isActive: mainTabIndex == MainTabBarIndex.home,
                      label: LocaleKeys.home.tr,
                      assetName: Assets.svg.tabHome,
                      itemRadius: itemRadius,
                      itemHeight: itemHeight,
                      onTap: () => onTapItem?.call(MainTabBarIndex.home),
                    ),
                    _buildItem(
                      isActive: mainTabIndex == MainTabBarIndex.chat,
                      label: LocaleKeys.chat.tr,
                      assetName: Assets.svg.tabChat,
                      itemRadius: itemRadius,
                      itemHeight: itemHeight,
                      onTap: () => onTapItem?.call(MainTabBarIndex.chat),
                    ),
                    // if (AppCache().isBig)
                    //   _buildItem(
                    //     isActive: mainTabIndex == MainTabBarIndex.ai,
                    //     label: LocaleKeys.ai_photo.tr,
                    //     assetName: Assets.svg.tabCreat,
                    //     itemRadius: itemRadius,
                    //     itemHeight: itemHeight,
                    //     onTap: () => onTapItem?.call(MainTabBarIndex.ai),
                    //   ),
                    _buildItem(
                      isActive: mainTabIndex == MainTabBarIndex.me,
                      label: LocaleKeys.me.tr,
                      assetName: Assets.svg.tabMe,
                      itemRadius: itemRadius,
                      itemHeight: itemHeight,
                      onTap: () => onTapItem?.call(MainTabBarIndex.me),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildItem({
    required bool isActive,
    required String label,
    required String assetName,
    required double itemRadius,
    required double itemHeight,
    void Function()? onTap,
  }) {
    return isActive
        ? Expanded(
            child: _buildActiveItem(
              itemRadius: itemRadius,
              label: label,
              assetName: assetName,
              onTap: onTap,
            ),
          )
        : _buildNoActiveItem(
            label: label,
            assetName: assetName,
            itemRadius: itemRadius,
            itemHeight: itemHeight,
            onTap: onTap,
          );
  }

  Widget _buildNoActiveItem({
    required String label,
    required String assetName,
    required double itemRadius,
    required double itemHeight,
    void Function()? onTap,
  }) {
    return FButton(
      borderRadius: BorderRadius.circular(itemRadius),
      color: Colors.transparent,
      onTap: onTap,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: itemHeight,
            height: itemHeight,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(itemRadius),
              color: AppColors.white20,
            ),
            child: Center(
              child: AnimatedContainer(
                duration: Duration(milliseconds: 300),
                curve: Curves.easeInOut,
                child: FIcon(assetName: assetName, color: Colors.white, width: 24),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActiveItem({
    required String label,
    required String assetName,
    required double itemRadius,
    void Function()? onTap,
  }) {
    return FButton(
      borderRadius: BorderRadius.circular(itemRadius),
      color: Colors.white,
      onTap: onTap,
      padding: EdgeInsets.symmetric(horizontal: 4),
      child: Row(
        spacing: 4,
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          FIcon(assetName: assetName, color: Colors.black, width: 24),
          Flexible(
            child: Text(
              label,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(color: Color(0xFF333333), fontWeight: FontWeight.w600, fontSize: 11),
            ),
          ),
        ],
      ),
    );
  }
}
