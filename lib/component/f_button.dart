import 'package:flutter/material.dart';

class FButton extends StatelessWidget {
  const FButton({
    super.key,
    this.child,
    this.borderRadius,
    this.focusColor,
    this.hoverColor,
    this.highlightColor,
    this.height,
    this.width,
    this.constraints,
    this.onTap,
    this.padding,
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
  final Color color;
  // 新增阴影开关参数（可选）
  final bool hasShadow;

  @override
  Widget build(BuildContext context) {
    final BorderRadius br = borderRadius ?? BorderRadius.circular(8);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        focusColor: focusColor ?? color.withValues(alpha: 0.5),
        hoverColor: hoverColor ?? color.withValues(alpha: 0.5),
        highlightColor: highlightColor ?? color.withValues(alpha: 0.5),
        borderRadius: br,
        child: Container(
          height: height,
          width: width,
          constraints: constraints,
          padding: padding,
          decoration: BoxDecoration(
            color: color,
            borderRadius: br, // 添加阴影
            boxShadow: hasShadow
                ? [
                    BoxShadow(
                      color: const Color(0xff4d77afff), // 阴影颜色（#4d77afff转ARGB）
                      offset: const Offset(0, 4), // 水平偏移0，垂直偏移4
                      blurRadius: 4, // 模糊半径4
                      spreadRadius: 0, // 扩散半径0
                    ),
                  ]
                : null,
          ),
          child: child ?? const SizedBox.shrink(),
        ),
      ),
    );
  }
}
