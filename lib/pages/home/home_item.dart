import 'package:fast_ai/component/f_button.dart';
import 'package:fast_ai/component/f_icon.dart';
import 'package:fast_ai/component/f_image.dart';
import 'package:fast_ai/data/a_pop.dart';
import 'package:fast_ai/gen/assets.gen.dart';
import 'package:fast_ai/generated/locales.g.dart';
import 'package:fast_ai/pages/home/home_ctr.dart';
import 'package:fast_ai/pages/router/n_t_n.dart';
import 'package:fast_ai/services/f_cache.dart';
import 'package:fast_ai/values/theme_colors.dart';
import 'package:fast_ai/values/theme_style.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

const kNSFW = 'NSFW';
const kBDSM = 'BDSM';

class HomeItem extends StatelessWidget {
  const HomeItem({
    super.key,
    required this.role,
    required this.onCollect,
    required this.cate,
    required this.width,
    required this.height,
  });

  final APop role;
  final void Function(APop role) onCollect;
  final HomeCate cate;

  final double width;
  final double height;

  void _onTap() {
    FocusManager.instance.primaryFocus?.unfocus();

    final id = role.id;
    if (id == null) {
      return;
    }

    if (cate == HomeCate.video) {
      NTN.pushPhoneGuide(role: role);
    } else {
      NTN.pushChat(id);
    }
  }

  @override
  Widget build(BuildContext context) {
    // 缓存条件判断结果，避免重复计算
    final isCollect = role.collect ?? false;
    final isVip = role.vip == true;
    final isBigScreen = FCache().isBig;

    // 优化标签处理逻辑
    final displayTags = _buildDisplayTags();
    final shouldShowTags = displayTags.isNotEmpty && isBigScreen;

    final intro = role.intro ?? '';

    return GestureDetector(
      onTap: _onTap,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          borderRadius: const BorderRadius.all(Radius.circular(16)),
        ),
        child: Stack(
          children: [
            // 背景图片
            FImage(
              url: role.avatar,
              width: width,
              height: height,
              cacheWidth: 1080,
              cacheHeight: 1080,
              borderRadius: BorderRadius.circular(16),
              shape: BoxShape.rectangle,
            ),

            // 渐变遮罩
            Container(
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.all(Radius.circular(16)),
                border: isVip
                    ? const Border.fromBorderSide(
                        BorderSide(color: ThemeColors.primary, width: 4))
                    : null,
                gradient: const LinearGradient(
                  colors: [
                    Color(0xED101010),
                    Colors.transparent,
                    Colors.transparent,
                    Color(0xED101010),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  stops: [0.0, 0.15, 0.5, 1.0],
                ),
              ),
            ),

            // // 内容区域
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  // 名字和年龄
                  _buildNameAndAge(),
                  const SizedBox(height: 4),

                  // 标签
                  if (shouldShowTags) _buildTags(displayTags),
                  const SizedBox(height: 8),

                  if (intro.isNotEmpty) ...[
                    Text(
                      intro,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: ThemeStyle.openSans(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    const SizedBox(height: 8),
                  ],

                  // 聊天按钮
                  if (FCache().isBig) ...[
                    _buildChatButton(),
                    const SizedBox(height: 8),
                  ]
                ],
              ),
            ),

            // 收藏按钮
            _buildCollectButton(isCollect),
          ],
        ),
      ),
    );
  }

  // 拆分组件，减少 build 方法复杂度
  Widget _buildNameAndAge() {
    return Row(
      children: [
        Expanded(
          child: Text(
            role.name ?? '',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: ThemeStyle.openSans(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
          child: Text(
            '${role.age ?? 0}',
            style: ThemeStyle.openSans(
              color: Colors.white,
              fontSize: 10,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildChatButton() {
    return FButton(
      onTap: _onTap,
      color: ThemeColors.primary,
      height: 32,
      margin: const EdgeInsetsDirectional.only(end: 40),
      constraints: const BoxConstraints(minWidth: 90),
      borderRadius: const BorderRadius.all(Radius.circular(16)),
      child: Center(
        child: Text(
          LocaleKeys.chat.tr,
          style: const TextStyle(
              fontSize: 16, fontWeight: FontWeight.w500, color: Colors.white),
        ),
      ),
    );
  }

  Widget _buildCollectButton(bool isCollected) {
    return PositionedDirectional(
      top: 0,
      end: 0,
      child: GestureDetector(
        onTap: () => onCollect(role),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          child: Container(
            decoration: BoxDecoration(
              color: ThemeColors.white10,
              borderRadius: const BorderRadius.all(Radius.circular(10)),
            ),
            height: 20,
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                FIcon(
                  assetName: Assets.svg.like,
                  width: 20,
                  color: isCollected ? ThemeColors.secondary : Colors.white,
                ),
                const SizedBox(width: 2),
                Text(
                  '${role.likes ?? 0}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: ThemeStyle.openSans(
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                    color: isCollected ? ThemeColors.secondary : Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // 提取标签构建逻辑，避免build方法中重复计算
  List<String> _buildDisplayTags() {
    final tags = role.tags;
    List<String> result =
        (tags != null && tags.length > 3) ? tags.take(3).toList() : tags ?? [];

    final tagType = role.tagType;
    if (tagType != null) {
      if (tagType.contains(kNSFW) && !result.contains(kNSFW)) {
        result.insert(0, kNSFW);
      }
      if (tagType.contains(kBDSM) && !result.contains(kBDSM)) {
        result.insert(0, kBDSM);
      }
    }

    return result.take(3).toList(); // 确保最多3个标签
  }

  Widget _buildTags(List<String> displayTags) {
    return Wrap(
      spacing: 4,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        for (int i = 0; i < displayTags.length; i++) ...[
          Text(
            displayTags[i],
            style: ThemeStyle.openSans(
              fontSize: 10,
              fontWeight: FontWeight.w500,
              color: _getTagColor(displayTags[i]),
            ),
          ),
          if (i < displayTags.length - 1)
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 2),
              child: SizedBox(
                  width: 1,
                  height: 4,
                  child: ColoredBox(color: ThemeColors.separator)),
            ),
        ],
      ],
    );
  }

  Color _getTagColor(String text) {
    return (text == kNSFW || text == kBDSM)
        ? ThemeColors.secondary
        : ThemeColors.success;
  }
}
