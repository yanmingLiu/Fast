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

    int cacheWidth = width != null ? (width! * 2).toInt() : 1080;
    int cacheHeight = height != null ? (height! * 2).toInt() : 1920;

    return ExtendedImage.network(
      url!,
      cacheWidth: cacheWidth,
      cacheHeight: cacheHeight,
      fit: BoxFit.cover,
      border: border,
      shape: shape ?? BoxShape.rectangle,
      color: color,
      width: width,
      height: height,
      maxBytes: 1024 * 1024 * 5,
      borderRadius: borderRadius,
      loadStateChanged: (state) {
        switch (state.extendedImageLoadState) {
          case LoadState.loading:
            return _buildPlaceholder();
          case LoadState.completed:
            return state.completedWidget;
          case LoadState.failed:
            return _buildPlaceholder();
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
        color: Color(0x1AFFFFFF),
        borderRadius: borderRadius,
        border: border,
      ),
      child: Assets.images.imagePlace.image(width: 24),
    );
  }
}
