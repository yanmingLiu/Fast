import 'package:fast_ai/component/f_button.dart';
import 'package:fast_ai/component/f_icon.dart';
import 'package:fast_ai/component/f_image.dart';
import 'package:fast_ai/data/role_data.dart';
import 'package:fast_ai/gen/assets.gen.dart';
import 'package:fast_ai/generated/locales.g.dart';
import 'package:fast_ai/pages/home/home_ctr.dart';
import 'package:fast_ai/services/app_cache.dart';
import 'package:fast_ai/tools/app_router.dart';
import 'package:flutter/material.dart';
import 'package:get/get_utils/src/extensions/export.dart';
import 'package:google_fonts/google_fonts.dart';

const kNSFW = 'NSFW';
const kBDSM = 'BDSM';

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
    bool isCollect = role.collect ?? false;

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
                    ? Border.all(color: Color(0xFF3F8DFD), width: 4, style: BorderStyle.solid)
                    : null,
              ),
            ),
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.transparent, Colors.black.withValues(alpha: 0.7)],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    stops: const [0.5, 1.0],
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
                  if (result.isNotEmpty && AppCache().isBig) _buildTags(result),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      FButton(
                        onTap: _onTap,
                        color: Color(0xFF3F8DFD),
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
                color: Colors.white.withValues(alpha: 0.1),
                height: 20,
                borderRadius: BorderRadius.circular(10),
                padding: EdgeInsets.symmetric(horizontal: 12),
                child: Row(
                  spacing: 2,
                  children: [
                    FIcon(
                      assetName: Assets.svg.like,
                      width: 20,
                      color: isCollect ? Color(0xFFFF4ACF) : Colors.white,
                    ),
                    Text(
                      '${role.likes ?? 0}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.openSans(
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                        color: isCollect ? Color(0xFFFF4ACF) : Colors.white,
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
    return SizedBox(
      height: 16,
      child: ListView.separated(
        padding: EdgeInsets.all(0),
        scrollDirection: Axis.horizontal,
        itemBuilder: (context, index) {
          final text = result[index];
          var textColor = Color(0xFF9CFC53);
          if (text == kNSFW || text == kBDSM) {
            textColor = Color(0xFFFF4ACF);
          }
          return Text(
            text,
            style: GoogleFonts.openSans(
              color: textColor,
              fontSize: 10,
              fontWeight: FontWeight.w500,
            ),
          );
        },
        separatorBuilder: (_, _) {
          return Center(
            child: Container(
              width: 1,
              height: 4,
              color: Color(0xffC9C9C9),
              margin: EdgeInsets.symmetric(horizontal: 4),
            ),
          );
        },
        itemCount: result.length,
      ),
    );
  }
}
