import 'dart:math' as math;

import 'package:fast_ai/component/app_dialog.dart';
import 'package:fast_ai/component/f_button.dart';
import 'package:fast_ai/component/f_icon.dart';
import 'package:fast_ai/component/f_loading.dart';
import 'package:fast_ai/data/sku_data.dart';
import 'package:fast_ai/gen/assets.gen.dart';
import 'package:fast_ai/generated/locales.g.dart';
import 'package:fast_ai/pages/vip/privacy_view.dart';
import 'package:fast_ai/services/app_cache.dart';
import 'package:fast_ai/services/app_log_event.dart';
import 'package:fast_ai/services/app_service.dart';
import 'package:fast_ai/tools/iap_tool.dart';
import 'package:fast_ai/values/app_values.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

class GemsPage extends StatefulWidget {
  const GemsPage({super.key});

  @override
  State<GemsPage> createState() => _GemsPageState();
}

class _GemsPageState extends State<GemsPage> {
  SkuData? _chooseProduct;

  late ConsumeFrom from;

  List<SkuData> list = [];

  @override
  void initState() {
    super.initState();

    AppService().getIdfa();

    _loadData();

    if (Get.arguments != null && Get.arguments is ConsumeFrom) {
      from = Get.arguments;
    }

    logEvent('t_paygems');
  }

  Future<void> _loadData() async {
    FLoading.showLoading();
    await IAPTool().query();
    setState(() {});
    FLoading.dismiss();

    list = IAPTool().consumableList;
    _chooseProduct = list.firstWhereOrNull((e) => e.defaultSku == true);
    setState(() {});
  }

  void _showHelp() {
    final str = AppCache().isBig
        ? LocaleKeys.text_message_cost.tr
        : LocaleKeys.text_message_call_cost.tr;
    List<String> strList = str.split('\n');

    AppDialog.show(
      clickMaskDismiss: false,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
        margin: const EdgeInsets.symmetric(horizontal: 24),
        decoration: BoxDecoration(
          color: Color(0xFF333333),
          borderRadius: BorderRadius.circular(32),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(strList.length, (index) {
            return Column(
              children: [
                Row(
                  children: [
                    Assets.images.gems.image(width: 24),
                    const SizedBox(width: 8),
                    Text(
                      strList[index],
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
              ],
            );
          }),
        ),
      ),
    );
  }

  void _buy() {
    if (_chooseProduct != null) {
      logEvent('c_paygems');
      IAPTool().buy(_chooseProduct!, consFrom: from);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        leadingWidth: 100,
        leading: Row(
          children: [
            SizedBox(width: 16),
            FButton(
              width: 44,
              height: 44,
              onTap: () => Get.back(),
              child: Center(child: FIcon(assetName: Assets.svg.close, width: 24)),
            ),
          ],
        ),
        actions: [
          FButton(
            width: 44,
            height: 44,
            onTap: _showHelp,
            child: Center(child: FIcon(assetName: Assets.svg.questing, width: 24)),
          ),
          SizedBox(width: 16),
        ],
      ),
      body: Stack(
        children: [
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Assets.images.gemsBg.image(fit: BoxFit.cover),
          ),
          Positioned.fill(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 57),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(height: kToolbarHeight + MediaQuery.paddingOf(context).top + 16),
                        Text(
                          AppCache().isBig
                              ? LocaleKeys.open_chats_unlock.tr
                              : LocaleKeys.buy_gems_open_chats.tr,
                          style: GoogleFonts.openSans(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  _buildList(),
                  const SizedBox(height: 180),
                ],
              ),
            ),
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              color: Color(0xFF111111),
              child: Column(
                children: [
                  const SizedBox(height: 16),
                  list.isEmpty == false
                      ? const SizedBox()
                      : Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 40),
                          child: Text(
                            LocaleKeys.one_time_purchase_note.trParams({
                              'price': _chooseProduct?.productDetails?.price ?? '',
                            }),
                            textAlign: TextAlign.center,
                            style: GoogleFonts.openSans(
                              color: Color(0xFF727374),
                              fontSize: 10,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ),
                  const SizedBox(height: 16),
                  FButton(
                    color: Color(0xFF3F8DFD),
                    onTap: _buy,
                    hasShadow: true,
                    margin: EdgeInsets.symmetric(horizontal: 65),
                    child: Center(
                      child: Text(
                        AppCache().isBig ? LocaleKeys.btn_continue.tr : LocaleKeys.buy.tr,
                        style: GoogleFonts.openSans(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  const PrivacyView(type: PolicyBottomType.gems),
                  SizedBox(height: context.mediaQueryPadding.bottom),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 根据折扣百分比获取对应的本地化字符串
  String getDiscount(int discountPercent) {
    try {
      return LocaleKeys.save_num.trParams({'num': discountPercent.toString()});
    } catch (e) {
      // 如果出错，返回硬编码的英文格式
      return 'Save $discountPercent%';
    }
  }

  Widget _buildList() {
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
    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemBuilder: (BuildContext context, int index) {
        final item = list[index];
        final bestChoice = item.tag == 1;
        final isSelected = _chooseProduct?.sku == item.sku;

        // 根据产品信息计算折扣百分比，从90%到0%以20%为步长递减
        // 使用算法计算：90 - (index * 20)，确保不小于0
        int discountPercent = math.max(0, 90 - (index * 20));

        String discount = getDiscount(discountPercent);
        String numericPart = item.number.toString();
        String price = item.productDetails?.price ?? '';

        return ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: InkWell(
            splashColor: Colors.transparent,
            highlightColor: Colors.transparent,
            onTap: () {
              _chooseProduct = item;
              setState(() {});
            },
            child: Stack(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 20),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    color: Color(0x333F8DFD),
                    border: Border.all(
                      color: isSelected ? Color(0xFF3F8DFD) : Colors.transparent,
                      width: 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Assets.images.gemls.image(width: 48),
                      Text(
                        numericPart,
                        style: GoogleFonts.openSans(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                      const Spacer(),
                      Column(
                        children: [
                          Text(
                            discount,
                            style: GoogleFonts.openSans(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                          Text(
                            price,
                            style: GoogleFonts.openSans(
                              fontSize: 14,
                              fontWeight: FontWeight.w400,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                if (bestChoice)
                  Row(
                    children: [
                      Container(
                        height: 20,
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: const BoxDecoration(
                          borderRadius: BorderRadiusDirectional.only(
                            topEnd: Radius.circular(16),
                            bottomStart: Radius.circular(16),
                          ),
                          color: Color(0xFF3F8DFD),
                        ),
                        child: Center(
                          child: Text(
                            LocaleKeys.best_choice.tr,
                            style: GoogleFonts.openSans(fontSize: 8, fontWeight: FontWeight.w400),
                          ),
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),
        );
      },
      itemCount: list.length,
      separatorBuilder: (c, i) => const SizedBox(height: 16),
    );
  }
}
