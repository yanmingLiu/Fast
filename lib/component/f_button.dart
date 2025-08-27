import 'package:flutter/material.dart';

// 性能优化：预定义常量，避免重复创建对象
const _shadowColor = Color(0x4D77AFFF);
const _shadowOffset = Offset(0, 4);
const _shadowBlurRadius = 4.0;
const _shadowSpreadRadius = 0.0;

class FButton extends StatelessWidget {
  const FButton({
    super.key,
    this.child,
    this.borderRadius,
    this.focusColor,
    this.hoverColor,
    this.highlightColor,
    this.height = 48.0,
    this.width,
    this.constraints,
    this.onTap,
    this.padding,
    this.margin,
    this.color = const Color(0x33FFFFFF),
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
  // 新增阴影开关参数（可选）
  final bool hasShadow;

  @override
  Widget build(BuildContext context) {
    final br = borderRadius ?? BorderRadius.circular((height ?? 48.0) / 2);

    // 预计算颜色，避免在InkWell中重复计算
    final interactionColor = color.withValues(alpha: 0.5);

    // 预定义阴影效果，避免每次build时创建
    final boxShadow = hasShadow
        ? [
            const BoxShadow(
              color: _shadowColor,
              offset: _shadowOffset,
              blurRadius: _shadowBlurRadius,
              spreadRadius: _shadowSpreadRadius,
            ),
          ]
        : null;

    Widget buttonChild = Container(
      height: height,
      width: width,
      constraints: constraints,
      padding: padding,
      decoration: BoxDecoration(color: color, borderRadius: br, boxShadow: boxShadow),
      child: child ?? const SizedBox.shrink(),
    );

    // 如果没有点击事件，直接返回容器，避免InkWell开销
    if (onTap == null) {
      return margin != null ? Padding(padding: margin!, child: buttonChild) : buttonChild;
    }

    buttonChild = InkWell(
      onTap: onTap,
      focusColor: focusColor ?? interactionColor,
      hoverColor: hoverColor ?? interactionColor,
      highlightColor: highlightColor ?? interactionColor,
      borderRadius: br,
      child: buttonChild,
    );

    return margin != null ? Padding(padding: margin!, child: buttonChild) : buttonChild;
  }
}
