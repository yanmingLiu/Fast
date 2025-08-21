import 'package:fast_ai/component/f_button.dart';
import 'package:fast_ai/component/f_icon.dart';
import 'package:fast_ai/component/f_image.dart';
import 'package:fast_ai/gen/assets.gen.dart';
import 'package:fast_ai/generated/locales.g.dart';
import 'package:fast_ai/pages/chat/role_center_ctr.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

class RoleCenterPage extends StatefulWidget {
  const RoleCenterPage({super.key});

  @override
  State<RoleCenterPage> createState() => _RoleCenterPageState();
}

class _RoleCenterPageState extends State<RoleCenterPage> {
  final ScrollController _scrollController = ScrollController();
  double _appBarOpacity = 0.0;

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
    setState(() {
      _appBarOpacity = opacity;
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
    final imageWidth = MediaQuery.of(context).size.width - 80;

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
        ),
        body: Stack(
          children: [
            Positioned(top: 0, left: 0, right: 0, child: Assets.images.pageBgRole.image()),
            SafeArea(
              child: Stack(
                alignment: AlignmentDirectional.topCenter,
                children: [
                  Positioned(top: 0, right: 0, left: 0, child: Assets.images.roleAvatarBg.image()),
                  Positioned(
                    left: 0,
                    right: 0,
                    child: Center(
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
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [
                                        Colors.transparent,
                                        Colors.black.withValues(alpha: 0.5),
                                        Colors.black.withValues(alpha: 0.7),
                                      ],
                                      begin: Alignment.topCenter,
                                      end: Alignment.bottomCenter,
                                      stops: const [0.5, 0.8, 1.0],
                                    ),
                                  ),
                                ),
                              ),
                              Column(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  Text(
                                    ctr.role.name ?? '',
                                    style: GoogleFonts.openSans(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.white,
                                    ),
                                  ),
                                  if (ctr.role.age != null)
                                    Text(
                                      LocaleKeys.age_years_olds.trParams({
                                        'age': ctr.role.age.toString(),
                                      }),
                                      style: GoogleFonts.openSans(
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
                                          color: Colors.white.withValues(alpha: 0.1),
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
                                                style: GoogleFonts.openSans(
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.w700,
                                                  color: isCollect
                                                      ? Color(0xFFFF4ACF)
                                                      : Colors.white,
                                                ),
                                              ),
                                            ],
                                          ),
                                        );
                                      }),
                                      FButton(
                                        color: Colors.white.withValues(alpha: 0.1),
                                        height: 26,
                                        padding: EdgeInsets.symmetric(horizontal: 12),
                                        child: Row(
                                          spacing: 2,
                                          children: [
                                            FIcon(
                                              assetName: Assets.svg.chat,
                                              width: 20,
                                              color: Colors.white,
                                            ),
                                            Text(
                                              ctr.role.sessionCount ?? '0',
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              style: GoogleFonts.openSans(
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
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
