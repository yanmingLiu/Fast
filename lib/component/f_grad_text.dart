import 'package:flutter/material.dart';

class FGradText extends StatelessWidget {
  const FGradText({
    super.key,
    required this.data,
    required this.gradient,
    required this.style,
    this.textAlign = TextAlign.left,
    this.maxLines,
    this.overflow = TextOverflow.ellipsis,
    this.softWrap = true,
    this.textScaler = const TextScaler.linear(1.0),
    this.semanticsLabel,
    this.strutStyle,
    this.textWidthBasis = TextWidthBasis.parent,
    this.textHeightBehavior,
  });

  final String data;
  final Gradient gradient;
  final TextStyle style;
  final TextAlign textAlign;
  final int? maxLines;
  final TextOverflow overflow;
  final bool softWrap;
  final TextScaler textScaler;
  final String? semanticsLabel;
  final StrutStyle? strutStyle;
  final TextWidthBasis textWidthBasis;
  final TextHeightBehavior? textHeightBehavior;

  // 性能优化：缓存常用对象，避免重复创建
  static const TextHeightBehavior _defaultTextHeightBehavior =
      TextHeightBehavior(
    applyHeightToFirstAscent: false,
    applyHeightToLastDescent: false,
  );

  static final StrutStyle _disabledStrutStyle = StrutStyle.disabled;

  @override
  Widget build(BuildContext context) {
    // 使用单一ShaderMask实现渐变效果，避免Stack的性能开销
    // BlendMode.srcIn确保只有文本形状显示渐变色
    return ShaderMask(
      shaderCallback: (Rect bounds) {
        return gradient.createShader(bounds);
      },
      blendMode: BlendMode.srcIn,
      child: Text(
        data,
        style: style,
        textAlign: textAlign,
        maxLines: maxLines,
        overflow: overflow,
        softWrap: softWrap,
        textScaler: textScaler,
        semanticsLabel: semanticsLabel,
        strutStyle: strutStyle ?? _disabledStrutStyle,
        textWidthBasis: textWidthBasis,
        textHeightBehavior: textHeightBehavior ?? _defaultTextHeightBehavior,
      ),
    );
  }

  /// 便捷工厂：线性渐变文本
  factory FGradText.linear(
    String text, {
    Key? key,
    required List<Color> colors,
    AlignmentGeometry begin = Alignment.centerLeft,
    AlignmentGeometry end = Alignment.centerRight,
    List<double>? stops,
    TextStyle? style,
    TextAlign textAlign = TextAlign.start,
    int? maxLines,
    TextOverflow overflow = TextOverflow.ellipsis,
  }) {
    return FGradText(
      key: key,
      data: text,
      gradient:
          LinearGradient(colors: colors, begin: begin, end: end, stops: stops),
      style: style ?? const TextStyle(),
      textAlign: textAlign,
      maxLines: maxLines,
      overflow: overflow,
    );
  }

  /// 便捷工厂：径向渐变文本
  factory FGradText.radial(
    String text, {
    Key? key,
    required List<Color> colors,
    AlignmentGeometry center = Alignment.center,
    double radius = 0.5,
    List<double>? stops,
    TextStyle? style,
    TextAlign textAlign = TextAlign.start,
    int? maxLines,
    TextOverflow overflow = TextOverflow.ellipsis,
  }) {
    return FGradText(
      key: key,
      data: text,
      gradient: RadialGradient(
          colors: colors, center: center, radius: radius, stops: stops),
      style: style ?? const TextStyle(),
      textAlign: textAlign,
      maxLines: maxLines,
      overflow: overflow,
    );
  }
}
