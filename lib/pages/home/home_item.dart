import 'package:fast_ai/component/f_button.dart';
import 'package:fast_ai/component/f_icon.dart';
import 'package:fast_ai/component/f_image.dart';
import 'package:fast_ai/data/role_data.dart';
import 'package:fast_ai/gen/assets.gen.dart';
import 'package:fast_ai/generated/locales.g.dart';
import 'package:fast_ai/pages/home/home_ctr.dart';
import 'package:fast_ai/pages/router/app_router.dart';
import 'package:fast_ai/services/app_cache.dart';
import 'package:fast_ai/values/app_colors.dart'; // 引入统一颜色管理
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

const kNSFW = 'NSFW';
const kBDSM = 'BDSM';

// 使用统一的颜色管理，不再需要本地常量定义
// 改为使用 AppColors.xxx

class HomeItem extends StatelessWidget {
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
    final tags = role.tags;
    List<String> result = (tags != null && tags.length > 3) ? tags.take(3).toList() : tags ?? [];
    if ((role.tagType?.contains(kNSFW) ?? false) && !result.contains(kNSFW)) {
      result.insert(0, kNSFW);
    }
    if ((role.tagType?.contains(kBDSM) ?? false) && !result.contains(kBDSM)) {
      result.insert(0, kBDSM);
    }
    final isCollect = role.collect ?? false;
    final shouldShowTags = result.isNotEmpty && AppCache().isBig; // 缓存条件判断

    return InkWell(
      onTap: () {
        FocusManager.instance.primaryFocus?.unfocus();
      },
      borderRadius: BorderRadius.circular(16),
      child: Container(
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(16)),
        child: Stack(
          children: [
            Positioned.fill(
              child: FImage(
                url: role.avatar,
                borderRadius: BorderRadius.circular(16),
                border: role.vip == true
                    ? Border.all(color: AppColors.primary, width: 4, style: BorderStyle.solid)
                    : null,
              ),
            ),
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: AppColors.homeItemGradient,
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    stops: const [0.0, 0.15, 0.6, 1.0],
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
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
                          style: GoogleFonts.openSans(
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
                          style: GoogleFonts.openSans(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  if (shouldShowTags) _buildTags(result),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      FButton(
                        onTap: _onTap,
                        color: AppColors.primary,
                        height: 32,
                        hasShadow: true,
                        constraints: BoxConstraints(minWidth: 90),
                        borderRadius: BorderRadius.circular(16),
                        child: Center(
                          child: Text(
                            LocaleKeys.chat.tr,
                            style: GoogleFonts.montserrat(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                ],
              ),
            ),
            PositionedDirectional(
              top: 8,
              end: 8,
              child: FButton(
                onTap: () => onCollect(role),
                color: Color(0x1AFFFFFF),
                height: 20,
                borderRadius: BorderRadius.circular(10),
                padding: EdgeInsets.symmetric(horizontal: 10),
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
                      style: GoogleFonts.openSans(
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
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

  Widget _buildTags(List<String> result) {
    // 限制最多显示3个标签
    final displayTags = result.take(3).toList();

    return Wrap(
      spacing: 4,
      crossAxisAlignment: WrapCrossAlignment.center, // 垂直方向居中对齐
      children: [
        for (int i = 0; i < displayTags.length; i++) ...[
          Text(
            displayTags[i],
            style: GoogleFonts.openSans(
              color: _getTagColor(displayTags[i]),
              fontSize: 10,
              fontWeight: FontWeight.w500,
            ),
          ),
          if (i < displayTags.length - 1)
            Container(
              width: 1,
              height: 4,
              color: AppColors.separator,
              margin: const EdgeInsets.symmetric(horizontal: 2),
            ),
        ],
      ],
    );
  }

  Color _getTagColor(String text) {
    if (text == kNSFW || text == kBDSM) {
      return AppColors.secondary;
    }
    return AppColors.success;
  }
}
