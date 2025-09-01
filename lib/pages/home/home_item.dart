import 'package:fast_ai/component/f_button.dart';
import 'package:fast_ai/component/f_icon.dart';
import 'package:fast_ai/component/f_image.dart';
import 'package:fast_ai/data/role_data.dart';
import 'package:fast_ai/gen/assets.gen.dart';
import 'package:fast_ai/generated/locales.g.dart';
import 'package:fast_ai/pages/home/home_ctr.dart';
import 'package:fast_ai/pages/router/app_router.dart';
import 'package:fast_ai/services/app_cache.dart';
import 'package:fast_ai/values/app_colors.dart';
import 'package:fast_ai/values/app_text_style.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

const kNSFW = 'NSFW';
const kBDSM = 'BDSM';

class HomeItem extends StatelessWidget {
  // 静态常量缓存 - 避免重复创建对象
  static const EdgeInsets _itemPadding = EdgeInsets.symmetric(horizontal: 8);
  static const EdgeInsets _buttonPadding = EdgeInsets.symmetric(horizontal: 10);
  static const EdgeInsets _separatorMargin = EdgeInsets.symmetric(horizontal: 2);
  static const BoxConstraints _buttonConstraints = BoxConstraints(minWidth: 90);
  static const BorderRadius _itemBorderRadius = BorderRadius.all(Radius.circular(16));
  static const BorderRadius _buttonBorderRadius = BorderRadius.all(Radius.circular(16));
  static const BorderRadius _collectBorderRadius = BorderRadius.all(Radius.circular(10));

  // 缓存常用的SizedBox
  static const SizedBox _spacing4 = SizedBox(height: 4);
  static const SizedBox _spacing8 = SizedBox(height: 8);

  // 缓存常用的分隔符Container
  static const Widget _separator = SizedBox(
    width: 1,
    height: 4,
    child: ColoredBox(color: AppColors.separator),
  );

  // 缓存GoogleFonts样式对象
  static final TextStyle _nameTextStyle = AppTextStyle.openSans(
    color: Colors.white,
    fontSize: 16,
    fontWeight: FontWeight.w700,
  );

  static final TextStyle _ageTextStyle = AppTextStyle.openSans(
    color: Colors.white,
    fontSize: 10,
    fontWeight: FontWeight.w500,
  );

  static final TextStyle _buttonTextStyle = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w500,
    color: Colors.white,
  );

  static final TextStyle _tagTextStyle = AppTextStyle.openSans(
    fontSize: 10,
    fontWeight: FontWeight.w500,
  );

  static final TextStyle _likesTextStyle = AppTextStyle.openSans(
    fontSize: 10,
    fontWeight: FontWeight.w500,
  );

  // 缓存渐变配置
  static const LinearGradient _backgroundGradient = LinearGradient(
    colors: AppColors.homeItemGradient,
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    stops: [0.0, 0.15, 0.6, 1.0],
  );

  // 缓存VIP边框
  static const Border _vipBorder = Border.fromBorderSide(
    BorderSide(color: AppColors.primary, width: 4),
  );
  const HomeItem({super.key, required this.role, required this.onCollect, required this.cate});

  final Role role;
  final void Function(Role role) onCollect;
  final HomeListCategroy cate;

  void _onTap() {
    FocusManager.instance.primaryFocus?.unfocus();

    final id = role.id;
    if (id == null) {
      return;
    }

    if (cate == HomeListCategroy.video) {
      AppRouter.pushPhoneGuide(role: role);
      return;
    }

    AppRouter.pushChat(id);
  }

  @override
  Widget build(BuildContext context) {
    // 缓存条件判断结果，避免重复计算
    final isCollect = role.collect ?? false;
    final isVip = role.vip == true;
    final isBigScreen = AppCache().isBig;

    // 优化标签处理逻辑
    final displayTags = _buildDisplayTags();
    final shouldShowTags = displayTags.isNotEmpty && isBigScreen;

    return GestureDetector(
      onTap: () {
        FocusManager.instance.primaryFocus?.unfocus();
      },
      child: ClipRRect(
        borderRadius: _itemBorderRadius,
        child: Stack(
          children: [
            Positioned.fill(child: FImage(url: role.avatar)),
            Container(
              decoration: BoxDecoration(
                borderRadius: _itemBorderRadius,
                border: isVip ? _vipBorder : null,
                gradient: _backgroundGradient,
              ),
            ),
            Padding(
              padding: _itemPadding,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Row(
                    spacing: 4,
                    children: [
                      Flexible(
                        child: Text(
                          role.name ?? '',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: _nameTextStyle,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                        child: Text('${role.age ?? 0}', style: _ageTextStyle),
                      ),
                    ],
                  ),
                  _spacing4,
                  if (shouldShowTags) _buildTags(displayTags),
                  _spacing8,
                  FButton(
                    onTap: _onTap,
                    color: AppColors.primary,
                    height: 32,
                    margin: EdgeInsetsDirectional.only(end: 40),
                    constraints: _buttonConstraints,
                    borderRadius: _buttonBorderRadius,
                    child: Center(child: Text(LocaleKeys.chat.tr, style: _buttonTextStyle)),
                  ),
                  _spacing8,
                ],
              ),
            ),
            PositionedDirectional(
              top: 8,
              end: 8,
              child: FButton(
                onTap: () => onCollect(role),
                color: AppColors.white10,
                height: 20,
                borderRadius: _collectBorderRadius,
                padding: _buttonPadding,
                child: Row(
                  spacing: 2,
                  children: [
                    FIcon(
                      assetName: Assets.svg.like,
                      width: 20,
                      color: isCollect ? AppColors.secondary : Colors.white,
                    ),
                    Text(
                      '${role.likes ?? 0}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: _likesTextStyle.copyWith(
                        color: isCollect ? AppColors.secondary : Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 提取标签构建逻辑，避免build方法中重复计算
  List<String> _buildDisplayTags() {
    final tags = role.tags;
    List<String> result = (tags != null && tags.length > 3) ? tags.take(3).toList() : tags ?? [];

    // 优化NSFW和BDSM标签插入逻辑
    // final tagType = role.tagType;
    // if (tagType != null) {
    //   if (tagType.contains(kNSFW) && !result.contains(kNSFW)) {
    //     result.insert(0, kNSFW);
    //   }
    //   if (tagType.contains(kBDSM) && !result.contains(kBDSM)) {
    //     result.insert(0, kBDSM);
    //   }
    // }

    return result.take(3).toList(); // 确保最多3个标签
  }

  Widget _buildTags(List<String> displayTags) {
    return Wrap(
      spacing: 4,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        for (int i = 0; i < displayTags.length; i++) ...[
          Text(displayTags[i], style: _tagTextStyle.copyWith(color: _getTagColor(displayTags[i]))),
          if (i < displayTags.length - 1) Padding(padding: _separatorMargin, child: _separator),
        ],
      ],
    );
  }

  Color _getTagColor(String text) {
    return (text == kNSFW || text == kBDSM) ? AppColors.secondary : AppColors.success;
  }
}
