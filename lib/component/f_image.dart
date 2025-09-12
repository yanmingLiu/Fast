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
  });

  final String? url;
  final double? width;
  final double? height;
  final BoxShape? shape;
  final BoxBorder? border;
  final BorderRadius? borderRadius;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    if (url == null || url!.isEmpty) {
      return _buildPlaceholder();
    }

    int w = width?.toInt() ?? 1920;
    int h = height?.toInt() ?? 1080;

    Widget imageWidget = CachedNetworkImage(
      imageUrl: url!,
      width: width,
      height: height,
      fit: BoxFit.cover,
      fadeInDuration: Duration.zero,
      maxWidthDiskCache: 250,
      maxHeightDiskCache: 400,
      placeholder: (context, url) => _buildPlaceholder(),
      errorWidget: (context, url, error) => _buildPlaceholder(),
    );

    // 应用装饰效果
    if (borderRadius != null || border != null || color != null) {
      return Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          borderRadius: borderRadius,
          border: border,
          color: color,
          shape: shape ?? BoxShape.rectangle,
        ),
        clipBehavior: borderRadius != null ? Clip.hardEdge : Clip.none,
        child: imageWidget,
      );
    }

    return imageWidget;
  }

  Container _buildPlaceholder() {
    return Container(
      width: width,
      height: height,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.1),
        borderRadius: borderRadius,
        border: border,
      ),
      child: Assets.images.imagePlace.image(width: 24),
    );
  }
}
