import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

// 极致性能优化：静态常量和装饰对象缓存，减少重建和对象分配
const _shadowColor = Color(0x4D77AFFF);
const _shadowOffset = Offset(0, 4);
const _shadowBlurRadius = 4.0;
const _shadowSpreadRadius = 0.0;

const _defaultHeight = 48.0;
const _defaultColor = Color(0x33FFFFFF);
final _defaultBorderRadius = BorderRadius.circular(_defaultHeight / 2);
const _defaultBoxShadow = [
  BoxShadow(
    color: _shadowColor,
    offset: _shadowOffset,
    blurRadius: _shadowBlurRadius,
    spreadRadius: _shadowSpreadRadius,
  ),
];

class FButton extends StatelessWidget {
  const FButton({
    super.key,
    this.child,
    this.borderRadius,
    this.focusColor,
    this.hoverColor,
    this.highlightColor,
    this.height = _defaultHeight,
    this.width,
    this.constraints,
    this.onTap,
    this.padding,
    this.margin,
    this.color = _defaultColor,
    this.hasShadow = false,
  });

  final Widget? child;
  final BorderRadius? borderRadius;
  final Color? focusColor;
  final Color? hoverColor;
  final Color? highlightColor;
  final double? height;
  final double? width;
  final BoxConstraints? constraints;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final Color color;
  final bool hasShadow;

  @override
  Widget build(BuildContext context) {
    // 圆角和阴影静态缓存，减少对象分配
    final BorderRadius br = borderRadius ?? _defaultBorderRadius;
    final List<BoxShadow>? boxShadow = hasShadow ? _defaultBoxShadow : null;

    // 优化装饰对象缓存
    final BoxDecoration decoration = BoxDecoration(
      color: color,
      borderRadius: br,
      boxShadow: boxShadow,
    );

    final Widget content = child ?? const SizedBox.shrink();

    Widget buttonChild;
    if (onTap != null) {
      // 有点击事件时直接用 CupertinoButton，支持圆角、颜色、padding
      buttonChild = CupertinoButton(
        padding: padding ?? EdgeInsets.zero,
        borderRadius: br,
        color: color,
        onPressed: onTap,
        child: content,
      );
      // CupertinoButton 不支持阴影和尺寸，需外层 DecoratedBox+SizedBox
      if (hasShadow || height != null || width != null || constraints != null) {
        buttonChild = DecoratedBox(
          decoration: BoxDecoration(
            color: Colors.transparent,
            borderRadius: br,
            boxShadow: boxShadow,
          ),
          child: SizedBox(
            height: height,
            width: width,
            child: buttonChild,
          ),
        );
      }
    } else {
      // 无点击事件时用 DecoratedBox 实现静态样式
      buttonChild = DecoratedBox(
        decoration: decoration,
        child: SizedBox(
          height: height,
          width: width,
          child: Padding(
            padding: padding ?? EdgeInsets.zero,
            child: content,
          ),
        ),
      );
    }

    // margin 优化
    if (margin != null) {
      buttonChild = Padding(padding: margin!, child: buttonChild);
    }

    return buttonChild;
  }
}
