// ignore: depend_on_referenced_packages
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

  @override
  Widget build(BuildContext context) {
    if (url == null || url!.isEmpty) {
      return _buildPlaceholder();
    }

    // int targetWidth = cacheWidth ?? 1080;
    // int targetHeight = cacheHeight ?? 1080;

    return ExtendedImage.network(
      url!,
      cacheWidth: cacheWidth,
      cacheHeight: cacheHeight,
      clearMemoryCacheIfFailed: true,
      clearMemoryCacheWhenDispose: true,
      fit: fit ?? BoxFit.cover,
      border: border,
      shape: shape ?? BoxShape.rectangle,
      color: color,
      width: width,
      height: height,
      maxBytes: 1024 * 1024 * 4,
      cacheMaxAge: Duration(seconds: 60),
      retries: 0,
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
