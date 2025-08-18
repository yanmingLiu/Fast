import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class FIcon extends StatelessWidget {
  const FIcon({
    super.key,
    required this.assetName,
    this.width,
    this.height,
    this.fit = BoxFit.contain,
    this.color,
  });

  final String assetName;
  final double? width;
  final double? height;
  final BoxFit? fit;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return SvgPicture.asset(
      assetName,
      width: width,
      height: height,
      fit: fit ?? BoxFit.cover,
      colorFilter: ColorFilter.mode(color ?? Colors.white, BlendMode.srcIn),
    );
  }
}
