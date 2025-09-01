import 'package:fast_ai/data/sku_data.dart';
import 'package:fast_ai/gen/assets.gen.dart';
import 'package:fast_ai/generated/locales.g.dart';
import 'package:fast_ai/services/app_cache.dart';
import 'package:fast_ai/tools/ext.dart';
import 'package:fast_ai/values/app_colors.dart';
import 'package:fast_ai/values/app_text_style.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SkuItemWidget extends StatelessWidget {
  final SkuData skuData;
  final bool isSelected;
  final VoidCallback onTap;
  final double? minWidth; // 改为可选的最小宽度

  const SkuItemWidget({
    super.key,
    required this.skuData,
    required this.isSelected,
    required this.onTap,
    this.minWidth, // 可选参数
  });

  @override
  Widget build(BuildContext context) {
    // 缓存计算结果以提高性能
    final isBest = (skuData.defaultSku ?? false) && AppCache().isBig;
    final isLifetime = skuData.lifetime ?? false;
    final price = skuData.productDetails?.price ?? '';
    final skuType = skuData.skuType;

    return Stack(
      children: [
        GestureDetector(
          onTap: onTap,
          child: IntrinsicWidth(
            child: Container(
              padding: const EdgeInsets.all(12),
              margin: const EdgeInsets.only(top: 12),
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.all(Radius.circular(16)),
                border: Border.all(color: const Color(0X1AFFFFFF), width: 1.0),
                color: isSelected ? AppColors.primary : const Color(0x333F8DFD),
              ),
              child: AppCache().isBig
                  ? _buildBigVersionContent(price, isLifetime, skuType)
                  : _buildSmallVersionContent(price),
            ),
          ),
        ),
        if (isBest) _buildBestOfferTag(),
      ],
    );
  }

  /// 构建大版本内容
  Widget _buildBigVersionContent(String price, bool isLifetime, int? skuType) {
    if (isLifetime) {
      return _buildLifetimeContent(price);
    } else {
      return _buildSubscriptionContent(price);
    }
  }

  /// 构建小版本内容
  Widget _buildSmallVersionContent(String price) {
    final title = _getSkuTitle();

    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        Flexible(
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              title,
              textAlign: TextAlign.center,
              style: AppTextStyle.openSans(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
        Container(height: 1, color: const Color(0x33FFFFFF)),
        Flexible(
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              price,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyle.openSans(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
      ],
    );
  }

  /// 构建终身版内容
  Widget _buildLifetimeContent(String price) {
    final rawPrice = skuData.productDetails?.rawPrice ?? 0;
    final symbol = skuData.productDetails?.currencySymbol ?? '';
    final originalPrice = '$symbol${numFixed(rawPrice * 6, position: 2)}';
    final title = _getSkuTitle();

    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        Flexible(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Flexible(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    price,
                    textAlign: TextAlign.center,
                    style: AppTextStyle.openSans(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 2),
              Flexible(
                child: Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      originalPrice,
                      textAlign: TextAlign.center,
                      style: AppTextStyle.openSans(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        Container(height: 1, color: const Color(0x33FFFFFF)),
        Flexible(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Flexible(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    title,
                    textAlign: TextAlign.center,
                    style: AppTextStyle.openSans(
                      color: isSelected ? Colors.white : const Color(0xFFA8A8A8),
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 2),
              Assets.images.gems.image(width: 24),
              const SizedBox(width: 2),
              Flexible(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    skuData.number.toString(),
                    textAlign: TextAlign.center,
                    style: AppTextStyle.openSans(
                      color: isSelected ? Colors.white : const Color(0xFFA8A8A8),
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// 构建订阅版内容
  Widget _buildSubscriptionContent(String price) {
    final rawPrice = skuData.productDetails?.rawPrice ?? 0;
    final symbol = skuData.productDetails?.currencySymbol ?? '';
    final title = _getSkuTitle();

    String originalPrice;
    if (skuData.skuType == 2) {
      final weekPrice = numFixed(rawPrice / 4, position: 2);
      originalPrice = '$symbol$weekPrice';
    } else {
      final weekPrice = numFixed(rawPrice / 48, position: 2);
      originalPrice = '$symbol$weekPrice';
    }

    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        Flexible(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Flexible(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    originalPrice,
                    textAlign: TextAlign.center,
                    style: AppTextStyle.openSans(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 2),
              Flexible(
                child: Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      '/${LocaleKeys.week.tr}',
                      textAlign: TextAlign.center,
                      style: AppTextStyle.openSans(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        Container(height: 1, color: const Color(0x33FFFFFF)),
        Flexible(
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              '$title $price',
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyle.openSans(
                color: isSelected ? Colors.white : const Color(0xFFA8A8A8),
                fontSize: 12,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
        ),
      ],
    );
  }

  /// 构建最佳优惠标签
  Widget _buildBestOfferTag() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      height: 24,
      alignment: Alignment.center,
      decoration: BoxDecoration(
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
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.25),
            offset: Offset(0, 4),
            blurRadius: 4.0,
            spreadRadius: 4.0,
          ),
        ],
      ),
      child: Text(
        LocaleKeys.best_offer.tr,
        style: const TextStyle(color: Colors.black, fontSize: 9, fontWeight: FontWeight.w700),
      ),
    );
  }

  /// 获取SKU标题
  String _getSkuTitle() {
    final skuType = skuData.skuType;

    switch (skuType) {
      case 2:
        return LocaleKeys.monthly.tr;
      case 3:
        return LocaleKeys.yearly.tr;
      case 4:
        return LocaleKeys.lifetime.tr;
      default:
        return '';
    }
  }
}
