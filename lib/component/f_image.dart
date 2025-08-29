import 'package:extended_image/extended_image.dart';
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

    return ExtendedImage.network(
      url!,
      width: width,
      height: height,
      fit: BoxFit.cover,
      borderRadius: borderRadius,
      shape: shape ?? BoxShape.rectangle,
      border: border,
      color: color,
      cache: true, // 启用缓存
      loadStateChanged: (state) {
        switch (state.extendedImageLoadState) {
          case LoadState.loading:
          case LoadState.failed:
            return _buildPlaceholder();
          case LoadState.completed:
            return null;
        }
      },
    );
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
