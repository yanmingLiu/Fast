import 'package:fast_ai/component/f_button.dart';
import 'package:fast_ai/component/f_icon.dart';
import 'package:fast_ai/component/f_image.dart';
import 'package:fast_ai/gen/assets.gen.dart';
import 'package:fast_ai/generated/locales.g.dart';
import 'package:fast_ai/pages/chat/photo_album.dart';
import 'package:fast_ai/pages/chat/role_center_ctr.dart';
import 'package:fast_ai/pages/home/home_item.dart';
import 'package:fast_ai/pages/router/app_router.dart';
import 'package:fast_ai/services/app_cache.dart';
import 'package:fast_ai/values/app_text_style.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

class RoleCenterPage extends StatefulWidget {
  const RoleCenterPage({super.key});

  @override
  State<RoleCenterPage> createState() => _RoleCenterPageState();
}

class _RoleCenterPageState extends State<RoleCenterPage> {
  final ScrollController _scrollController = ScrollController();
  double _appBarOpacity = 0.0;
  double _roleAvatarBgTop = 0.0;

  final ctr = Get.put(RoleCenterCtr());

  @override
  void initState() {
    super.initState();

    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    // 根据滚动的偏移量调整透明度（滚动 0 ~ 200）
    double offset = _scrollController.offset;
    final maxOffset = Get.width - kToolbarHeight;
    double opacity = (offset / maxOffset).clamp(0, 1); // 限制透明度在 0 到 1 的范围内

    // 计算roleAvatarBg的top值，使其跟随滚动
    // 使用负值，确保背景可以完全滚出屏幕
    double newTop = -offset; // 使用1:1的滚动比例，确保可以完全滚出

    setState(() {
      _appBarOpacity = opacity;
      _roleAvatarBgTop = newTop;
    });
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var height = MediaQuery.of(context).size.height;
    var top = MediaQuery.of(context).padding.top;
    var bottom = MediaQuery.of(context).padding.bottom;

    return AnnotatedRegion(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        extendBodyBehindAppBar: true,
        appBar: AppBar(
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
            ctr.role.name ?? '',
            overflow: TextOverflow.ellipsis,
            style: AppTextStyle.openSans(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Colors.white.withValues(alpha: _appBarOpacity),
            ),
          ),
        ),
        body: Stack(
          children: [
            Positioned(top: 0, left: 0, right: 0, child: Assets.images.pageBgRole.image()),
            Positioned(
              top: _roleAvatarBgTop,
              right: 0,
              left: 0,
              height: height - top - bottom,
              child: Assets.images.roleAvatarBg.image(),
            ),
            SafeArea(
              child: SingleChildScrollView(
                controller: _scrollController,
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildAvatar(),
                    _buildTags(),
                    _buildIntro(),
                    _buildImages(),
                    _buildActions(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAvatar() {
    final imageWidth = MediaQuery.of(context).size.width - 80;

    return Center(
      child: ClipRRect(
        borderRadius: BorderRadius.circular(imageWidth / 2),
        child: SizedBox(
          width: imageWidth,
          height: imageWidth,
          child: Stack(
            children: [
              Positioned.fill(child: FImage(url: ctr.role.avatar)),
              Positioned.fill(
                child: Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.transparent,
                        Color(0x80000000),
                        Color(0xB3000000),
                      ],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      stops: [0.5, 0.8, 1.0],
                    ),
                  ),
                ),
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    ctr.role.name ?? '',
                    style: AppTextStyle.openSans(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                  if (ctr.role.age != null)
                    Text(
                      LocaleKeys.age_years_olds.trParams({'age': ctr.role.age.toString()}),
                      style: AppTextStyle.openSans(
                        fontSize: 8,
                        fontWeight: FontWeight.w400,
                        color: Color(0xFFDEDEDE),
                      ),
                    ),
                  SizedBox(height: 8),
                  Row(
                    spacing: 8,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Obx(() {
                        final isCollect = ctr.collect.value;
                        return FButton(
                          onTap: ctr.onCollect,
                          color: Color(0x1AFFFFFF),
                          height: 26,
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
                                '${ctr.role.likes ?? 0}',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: AppTextStyle.openSans(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: isCollect ? Color(0xFFFF4ACF) : Colors.white,
                                ),
                              ),
                            ],
                          ),
                        );
                      }),
                      FButton(
                        color: Color(0x1AFFFFFF),
                        height: 26,
                        padding: EdgeInsets.symmetric(horizontal: 12),
                        child: Row(
                          spacing: 2,
                          children: [
                            FIcon(assetName: Assets.svg.chat, width: 20, color: Colors.white),
                            Text(
                              ctr.role.sessionCount ?? '0',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: AppTextStyle.openSans(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 40),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTags() {
    if (!AppCache().isBig) {
      return const SizedBox();
    }

    var tags = ctr.role.tags;
    if (tags == null || tags.isEmpty) {
      return const SizedBox();
    }

    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: tags.map((text) {
          Color textColor = Colors.white;
          if (text == kNSFW || text == kBDSM) {
            textColor = Color(0xFF3F8DFD);
          }

          return Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: const BoxDecoration(
                  color: Color(0x1AFFFFFF),
                  borderRadius: BorderRadius.all(Radius.circular(20)),
                ),
                alignment: Alignment.center,
                child: Text(
                  text,
                  style: AppTextStyle.openSans(
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                    color: textColor,
                  ),
                ),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }

  Widget _buildIntro() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 12,
      children: [
        SizedBox(height: 20),
        Text(
          LocaleKeys.intro_title.tr,
          style: AppTextStyle.openSans(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
        Text(
          ctr.role.aboutMe ?? '',
          style: AppTextStyle.openSans(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.w400,
          ),
        ),
      ],
    );
  }

  Widget _buildImages() {
    return Obx(() {
      final images = ctr.images;
      if (!AppCache().isBig || images.isEmpty) {
        return const SizedBox();
      }
      final imageCount = images.length;
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 20),
          Text(
            LocaleKeys.enticing_picture.tr,
            style: AppTextStyle.openSans(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 12),
          GridView.builder(
            physics: NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4,
              mainAxisSpacing: 4,
              crossAxisSpacing: 4,
              childAspectRatio: 1.0,
            ),
            itemBuilder: (_, idx) {
              final image = images[idx];
              final unlocked = image.unlocked ?? false;
              return PhotoAlbumItem(
                image: image,
                unlocked: unlocked,
                onTap: () {
                  if (unlocked) {
                    ctr.msgCtr.onTapImage(image);
                  } else {
                    ctr.msgCtr.onTapUnlockImage(image);
                  }
                },
              );
            },
            itemCount: imageCount,
          ),
        ],
      );
    });
  }

  Widget _buildActions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 20),
        Text(
          LocaleKeys.option_title.tr,
          style: AppTextStyle.openSans(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
        SizedBox(height: 12),
        Column(
          children: [
            FButton(
              height: 44,
              borderRadius: BorderRadius.circular(0),
              color: Colors.transparent,
              onTap: ctr.clearHistory,
              child: Row(
                spacing: 4,
                children: [
                  FIcon(assetName: Assets.svg.clear),
                  Text(
                    LocaleKeys.clear_history.tr,
                    style: AppTextStyle.openSans(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  const Spacer(),
                  const Icon(Icons.chevron_right, color: Color(0xFF9D9D9D)),
                ],
              ),
            ),
            Container(height: 1, color: const Color(0x1AFFFFFF)),
            FButton(
              onTap: () => AppRouter.report(),
              height: 44,
              borderRadius: BorderRadius.circular(0),
              color: Colors.transparent,
              child: Row(
                spacing: 4,
                children: [
                  FIcon(assetName: Assets.svg.report),
                  Text(
                    LocaleKeys.report.tr,
                    style: AppTextStyle.openSans(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  const Spacer(),
                  const Icon(Icons.chevron_right, color: Color(0xFF9D9D9D)),
                ],
              ),
            ),
          ],
        ),
        SizedBox(height: 20),
        FButton(
          onTap: ctr.deleteChat,
          margin: EdgeInsets.symmetric(horizontal: 54),
          color: Color(0x4DF31D1D),
          child: Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  LocaleKeys.delete_chat.tr,
                  style: AppTextStyle.openSans(
                    color: const Color(0xFFF04A4C),
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
