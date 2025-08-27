import 'dart:ui';

import 'package:fast_ai/component/f_button.dart';
import 'package:fast_ai/component/f_icon.dart';
import 'package:fast_ai/component/gradient_text.dart';
import 'package:fast_ai/component/rich_text_placeholder.dart';
import 'package:fast_ai/data/sku_data.dart';
import 'package:fast_ai/gen/assets.gen.dart';
import 'package:fast_ai/generated/locales.g.dart';
import 'package:fast_ai/pages/vip/f_vip_timer.dart';
import 'package:fast_ai/pages/vip/privacy_view.dart';
import 'package:fast_ai/services/app_cache.dart';
import 'package:fast_ai/services/app_log_event.dart';
import 'package:fast_ai/services/app_service.dart';
import 'package:fast_ai/tools/ext.dart';
import 'package:fast_ai/tools/iap_tool.dart';
import 'package:fast_ai/values/app_colors.dart';
import 'package:fast_ai/values/app_values.dart';
import 'package:flutter/material.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

class VipPage extends StatefulWidget {
  const VipPage({super.key});

  @override
  State<VipPage> createState() => _VipPageState();
}

class _VipPageState extends State<VipPage> {
  List<SkuData> get list => IAPTool().subscriptionList;
  SkuData? chooseProduct;
  String _contentText = '';

  late VipFrom from;

  bool showBack = false;

  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    from = Get.arguments;

    _changeContentText();

    _loadData();

    logEvent(AppCache().isBig ? 't_vipb' : 't_vipa');

    if (AppCache().isBig) {
      Future.delayed(const Duration(seconds: 3), () {
        showBack = true;
        setState(() {});
      });
    } else {
      showBack = true;
    }

    // 初始化后需要延迟执行滚动，确保布局已完成
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToSelectedItemWithoutAnimation();
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  // 初始化时使用无动画滚动
  void _scrollToSelectedItemWithoutAnimation() {
    if (chooseProduct == null) return;
    if (!_scrollController.hasClients) return;

    final index = list.indexWhere((element) => element.sku == chooseProduct?.sku);
    if (index == -1) return;

    // 计算滚动位置
    if (index == 0) {
      // 如果是第一个，滚动到最左边
      _scrollController.jumpTo(0);
    } else if (index == list.length - 1) {
      // 如果是最后一个，滚动到最右边
      _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
    } else {
      try {
        // 计算单个项目的宽度（包括分隔符）
        final itemWidth = (MediaQuery.of(context).size.width - 32 - 40) / 2 + 8;
        // 计算目标偏移量，使选中项尽量居中
        final offset =
            index * itemWidth - (_scrollController.position.viewportDimension - itemWidth) / 2;
        // 确保偏移量在有效范围内
        final clampedOffset = offset.clamp(0.0, _scrollController.position.maxScrollExtent);
        _scrollController.jumpTo(clampedOffset);
      } catch (e) {
        // 出错时使用简单定位
        final itemWidth = (MediaQuery.of(context).size.width - 32 - 40) / 2 + 8;
        final estimatedOffset = index * itemWidth;
        final safeOffset = estimatedOffset.clamp(0.0, _scrollController.position.maxScrollExtent);
        _scrollController.jumpTo(safeOffset);
      }
    }
  }

  void _scrollToSelectedItem() {
    if (chooseProduct == null) return;
    if (!_scrollController.hasClients) return; // 确保ScrollController已附加到ScrollView

    final index = list.indexWhere((element) => element.sku == chooseProduct?.sku);
    if (index == -1) return;

    // 计算滚动位置
    if (index == 0) {
      // 如果是第一个，平滑滚动到最左边
      _scrollController.animateTo(
        0,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else if (index == list.length - 1) {
      // 如果是最后一个，平滑滚动到最右边
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      // 其他情况，尽量居中显示
      // 计算单个项目的宽度（包括分隔符）
      final itemWidth = (MediaQuery.of(context).size.width - 32 - 40) / 2 + 8; // 项宽度+分隔符
      // 计算目标偏移量，使选中项尽量居中
      double offset;
      try {
        offset = index * itemWidth - (_scrollController.position.viewportDimension - itemWidth) / 2;
        // 确保偏移量在有效范围内
        final clampedOffset = offset.clamp(0.0, _scrollController.position.maxScrollExtent);
        _scrollController.animateTo(
          clampedOffset,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      } catch (e) {
        // 如果计算过程中出错，回退到简单的定位方法
        final estimatedOffset = index * itemWidth;
        final safeOffset = estimatedOffset.clamp(0.0, _scrollController.position.maxScrollExtent);
        _scrollController.animateTo(
          safeOffset,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      }
    }
  }

  Future<void> _loadData() async {
    await AppService().getIdfa();

    SmartDialog.showLoading();
    await IAPTool().query();
    setState(() {});
    SmartDialog.dismiss();

    chooseProduct = IAPTool().subscriptionList.firstWhereOrNull((e) => e.defaultSku == true);
    _changeContentText();
  }

  void _changeContentText() {
    if (AppCache().isBig) {
      final gems = chooseProduct?.number ?? 150;
      _contentText = LocaleKeys.vip_get_2.trParams({'gems': gems.toString()});
    } else {
      _contentText = LocaleKeys.vip_get_1.tr;
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        return false;
      },
      child: Scaffold(
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          elevation: 0,
          scrolledUnderElevation: 0.0,
          backgroundColor: Colors.transparent,
          leadingWidth: 100,
          leading: showBack
              ? Row(
                  children: [
                    SizedBox(width: 16),
                    FButton(
                      width: 44,
                      height: 44,
                      color: Color(0x33FFFFFF),
                      borderRadius: BorderRadius.circular(22),
                      onTap: () {
                        Get.back();
                      },
                      child: Center(child: FIcon(assetName: Assets.svg.close)),
                    ),
                  ],
                )
              : const SizedBox(),
          actions: [
            GestureDetector(
              onTap: () {
                IAPTool().restore();
              },
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    height: 26,
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    alignment: Alignment.centerLeft,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(13),
                      border: Border.all(width: 1, color: const Color(0x80FFFFFF)),
                    ),
                    child: Text(
                      LocaleKeys.restore.tr,
                      style: TextStyle(
                        fontSize: 12,
                        color: const Color(0xB3FFFFFF),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  SizedBox(width: 20),
                ],
              ),
            ),
          ],
        ),
        body: Stack(
          children: [
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: AppCache().isBig
                  ? Assets.images.vipPageBg2.image(fit: BoxFit.cover)
                  : Assets.images.vipPageBg1.image(fit: BoxFit.cover),
            ),
            SingleChildScrollView(
              padding: EdgeInsets.only(top: 150),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        AppCache().isBig
                            ? Row(
                                spacing: 12,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  GradientText(
                                    textAlign: TextAlign.center,
                                    data: "50%",
                                    gradient: const LinearGradient(
                                      colors: [Color(0xFFF4FCFF), Color(0xFF49AAFF)],
                                      begin: Alignment.topCenter,
                                      end: Alignment.bottomCenter,
                                      stops: [0.0, 1.0],
                                    ),
                                    style: GoogleFonts.openSans(
                                      fontSize: 64,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(top: 38),
                                    child: GradientText(
                                      textAlign: TextAlign.center,
                                      data: "OFF",
                                      gradient: const LinearGradient(
                                        colors: [Color(0xFFF4FCFF), Color(0xFF49AAFF)],
                                        begin: Alignment.topCenter,
                                        end: Alignment.bottomCenter,
                                        stops: [0.0, 1.0],
                                      ),
                                      style: GoogleFonts.openSans(
                                        fontSize: 64,
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                  ),
                                ],
                              )
                            : GradientText(
                                data: LocaleKeys.up_to_vip.tr,
                                textAlign: TextAlign.center,
                                gradient: const LinearGradient(
                                  colors: [Color(0xFFF4FCFF), Color(0xFF49AAFF)],
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  stops: [0.0, 1.0],
                                ),
                                style: GoogleFonts.openSans(
                                  fontSize: 36,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                        SizedBox(height: 20),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(24),
                          child: BackdropFilter(
                            filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                            child: Container(
                              width: double.infinity,
                              padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                              decoration: BoxDecoration(
                                color: Color(0x801C1C1C),
                                borderRadius: BorderRadius.circular(24),
                                border: Border.all(color: const Color(0x33FFFFFF), width: 1),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                spacing: 16,
                                children: [
                                  if (AppCache().isBig)
                                    Text(
                                      LocaleKeys.best_chat_experience.tr,
                                      style: GoogleFonts.openSans(
                                        color: Colors.white,
                                        fontSize: 14,
                                        fontWeight: FontWeight.w400,
                                      ),
                                    ),
                                  RichTextPlaceholder(
                                    textKey: _contentText,
                                    placeholders: {
                                      'icon': WidgetSpan(
                                        alignment: PlaceholderAlignment.middle,
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(horizontal: 4),
                                          child: Assets.images.sure.image(width: 16),
                                        ),
                                      ),
                                    },
                                    style: GoogleFonts.openSans(
                                      color: Colors.white,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                      height: 1.8,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: 26),
                      ],
                    ),
                  ),
                  _buildSKU(),
                  SizedBox(height: 8),
                  PrivacyView(
                    type: AppCache().isBig ? PolicyBottomType.vip2 : PolicyBottomType.vip1,
                  ),
                  const SizedBox(height: 12),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSKU() {
    var list = IAPTool().subscriptionList;

    if (list.isEmpty) {
      return Center(
        child: SizedBox(
          height: 100,
          child: Text(
            LocaleKeys.no_subscription_available.tr,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.white),
          ),
        ),
      );
    }

    final price = chooseProduct?.productDetails?.price ?? '0.0';

    final skuType = chooseProduct?.skuType;
    String unit = '';
    if (skuType == 2) {
      unit = LocaleKeys.month.tr;
    } else if (skuType == 3) {
      unit = LocaleKeys.year.tr;
    }

    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        SizedBox(
          height: 110,
          child: ListView.separated(
            controller: _scrollController,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            scrollDirection: Axis.horizontal,
            itemBuilder: (_, index) {
              final sku = list[index];
              final isChoosed = sku.sku == chooseProduct?.sku;
              final isBest = (sku.defaultSku ?? false) && AppCache().isBig;

              double width = (MediaQuery.of(context).size.width - 32 - 40) / 2;

              final symbol = sku.productDetails?.currencySymbol;
              var title = '';
              bool isLifeTime = sku.lifetime ?? false;
              String orginalPrice = sku.productDetails?.price ?? '';
              final skuType = sku.skuType;
              final rawPrice = sku.productDetails?.rawPrice ?? 0;

              if (skuType == 2) {
                title = LocaleKeys.monthly.tr;
                final price = numFixed(rawPrice / 4, position: 2);
                orginalPrice = '$symbol$price';
              } else if (skuType == 3) {
                title = LocaleKeys.yearly.tr;
                final price = numFixed(rawPrice / 48, position: 2);
                orginalPrice = '$symbol$price';
              } else if (skuType == 4) {
                title = LocaleKeys.lifetime.tr;
                isLifeTime = true;
                var pric = numFixed(rawPrice * 6, position: 2);
                orginalPrice = '$symbol$pric';
                width += 30;
              }

              return Stack(
                children: [
                  GestureDetector(
                    onTap: () {
                      chooseProduct = sku;
                      setState(() {
                        // 在状态更新后滚动到选中的项
                        WidgetsBinding.instance.addPostFrameCallback((_) {
                          _scrollToSelectedItem();
                        });
                      });
                    },
                    child: Container(
                      width: width,
                      padding: EdgeInsets.all(12),
                      margin: EdgeInsets.only(top: 12),
                      decoration: BoxDecoration(
                        borderRadius: const BorderRadius.all(Radius.circular(16)),
                        border: Border.all(color: Color(0X1AFFFFFF), width: 1.0),
                        color: isChoosed ? AppColors.primary : const Color(0x333F8DFD),
                      ),
                      child: AppCache().isBig
                          ? isLifeTime
                                ? Column(
                                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                                    children: [
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        spacing: 2,
                                        children: [
                                          Text(
                                            price,
                                            textAlign: TextAlign.center,
                                            style: GoogleFonts.openSans(
                                              color: Colors.white,
                                              fontSize: 20,
                                              fontWeight: FontWeight.w700,
                                            ),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.only(top: 4),
                                            child: Text(
                                              orginalPrice,
                                              textAlign: TextAlign.center,
                                              style: GoogleFonts.openSans(
                                                color: Colors.white,
                                                fontSize: 12,
                                                fontWeight: FontWeight.w400,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      Container(height: 1, color: Color(0x33FFFFFF)),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        spacing: 2,
                                        children: [
                                          Text(
                                            title,
                                            textAlign: TextAlign.center,
                                            style: GoogleFonts.openSans(
                                              color: isChoosed ? Colors.white : Color(0xFFA8A8A8),
                                              fontSize: 12,
                                              fontWeight: FontWeight.w400,
                                            ),
                                          ),
                                          Assets.images.gems.image(width: 24),
                                          Text(
                                            sku.number.toString(),
                                            textAlign: TextAlign.center,
                                            style: GoogleFonts.openSans(
                                              color: isChoosed ? Colors.white : Color(0xFFA8A8A8),
                                              fontSize: 12,
                                              fontWeight: FontWeight.w700,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  )
                                : Column(
                                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                                    children: [
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        spacing: 2,
                                        children: [
                                          Text(
                                            orginalPrice,
                                            textAlign: TextAlign.center,
                                            style: GoogleFonts.openSans(
                                              color: Colors.white,
                                              fontSize: 20,
                                              fontWeight: FontWeight.w700,
                                            ),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.only(top: 4),
                                            child: Text(
                                              '/${LocaleKeys.week.tr}',
                                              textAlign: TextAlign.center,
                                              style: GoogleFonts.openSans(
                                                color: Colors.white,
                                                fontSize: 12,
                                                fontWeight: FontWeight.w400,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      Container(height: 1, color: Color(0x33FFFFFF)),
                                      Text(
                                        '$title $price',
                                        textAlign: TextAlign.center,
                                        style: GoogleFonts.openSans(
                                          color: isChoosed ? Colors.white : Color(0xFFA8A8A8),
                                          fontSize: 12,
                                          fontWeight: FontWeight.w400,
                                        ),
                                      ),
                                    ],
                                  )
                          : Column(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                Text(
                                  title,
                                  textAlign: TextAlign.center,
                                  style: GoogleFonts.openSans(
                                    color: Colors.white,
                                    fontSize: 20,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                Container(height: 1, color: Color(0x33FFFFFF)),
                                Text(
                                  price,
                                  textAlign: TextAlign.center,
                                  style: GoogleFonts.openSans(
                                    color: Colors.white,
                                    fontSize: 22,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                    ),
                  ),
                  if (isBest)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      height: 24,
                      alignment: Alignment.center,
                      decoration: const BoxDecoration(
                        borderRadius: BorderRadiusDirectional.only(
                          topStart: Radius.circular(12),
                          topEnd: Radius.circular(12),
                          bottomEnd: Radius.circular(12),
                        ),
                        gradient: LinearGradient(
                          colors: AppColors.vipTagGradient,
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                      ),
                      child: Text(
                        LocaleKeys.best_offer.tr,
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 9,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                ],
              );
            },
            separatorBuilder: (_, index) {
              return const SizedBox(width: 8);
            },
            itemCount: list.length,
          ),
        ),
        SizedBox(height: 28),
        if (AppCache().isBig) const VipTimer(),
        SizedBox(height: 8),
        if (!AppCache().isBig)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              skuType == 4
                  ? LocaleKeys.vip_price_lt_desc.trParams({'price': price})
                  : LocaleKeys.subscription_info.trParams({'price': price, 'unit': unit}),
              style: TextStyle(
                color: Colors.white.withOpacity(0.85),
                fontSize: 10,
                fontWeight: FontWeight.w300,
              ),
            ),
          ),
        SizedBox(height: 8),
        FButton(
          onTap: () {
            logEvent(AppCache().isBig ? 'c_vipb_subs' : 'c_vipa_subs');
            if (chooseProduct != null) {
              IAPTool().buy(chooseProduct!, vipFrom: from);
            }
          },
          margin: EdgeInsets.symmetric(horizontal: 60),
          hasShadow: true,
          color: AppColors.primary,
          child: Center(
            child: Text(
              AppCache().isBig ? LocaleKeys.btn_continue.tr : LocaleKeys.subscribe.tr,
              style: GoogleFonts.openSans(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
