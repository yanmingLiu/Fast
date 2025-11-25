import 'package:cached_network_image/cached_network_image.dart';
import 'package:fast_ai/gen/assets.gen.dart';
import 'package:flutter/material.dart';

class FImage extends StatelessWidget {
  const FImage({
    super.key,
    this.url,
    this.width,
    this.height,
    this.shape,
    this.border,
    this.borderRadius,
    this.color,
    this.fit,
    this.cacheWidth,
    this.cacheHeight,
  });

  final String? url;
  final double? width;
  final double? height;
  final int? cacheWidth;
  final int? cacheHeight;
  final BoxShape? shape;
  final BoxBorder? border;
  final BorderRadius? borderRadius;
  final Color? color;
  final BoxFit? fit;

  String get urlSuffix => '?x-oss-process=image/resize,p_50';

  @override
  Widget build(BuildContext context) {
    if (url == null || url!.isEmpty) {
      return placeholder();
    }

    var imageUrl = url!;

    if ((cacheHeight != null || cacheWidth != null) &&
        !imageUrl.contains('.gif') &&
        !imageUrl.contains('.webp')) {
      imageUrl += urlSuffix;
    }

    Widget imageWidget = CachedNetworkImage(
      imageUrl: imageUrl,
      width: width,
      height: height,
      fit: fit ?? BoxFit.cover,
      cacheKey: imageUrl,
      placeholder: (context, url) => placeholder(),
      errorWidget: (context, url, error) => placeholder(),
      color: color,
    );

    // Apply shape and border
    if (border != null || shape != null) {
      imageWidget = Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          shape: shape ?? BoxShape.rectangle,
          border: border,
          borderRadius: shape == BoxShape.circle ? null : borderRadius,
        ),
        child: ClipRRect(
          borderRadius: shape == BoxShape.circle
              ? BorderRadius.circular((width ?? height ?? 0) / 2)
              : (borderRadius ?? BorderRadius.zero),
          child: imageWidget,
        ),
      );
    } else {
      imageWidget = ClipRRect(
        borderRadius: borderRadius ?? BorderRadius.zero,
        child: imageWidget,
      );
    }

    return imageWidget;
  }

  Widget placeholder() {
    return Container(
      width: width,
      height: height,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: Color(0x1AFFFFFF),
        borderRadius: borderRadius,
        border: border,
      ),
      child: Assets.images.imagePlace.image(width: 24),
    );
  }
}
