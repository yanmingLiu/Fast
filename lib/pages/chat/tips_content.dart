import 'dart:ui';

import 'package:fast_ai/generated/locales.g.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

/// Tips样式相关的静态常量，遵循项目性能优化规范
class _TipsStyle {
  _TipsStyle._(); // 私有构造函数

  static const double blurRadius = 10.0;
  static const double fontSize = 10.0;
  static const double borderRadius = 16.0;
  static const EdgeInsets padding = EdgeInsets.symmetric(horizontal: 8, vertical: 8);
  static const Color backgroundColor = Color(0x801C1C1C);
  static const FontWeight fontWeight = FontWeight.w400;
  static const Color textColor = Colors.white;

  // 缓存样式对象，避免每次build时重新创建
  static final TextStyle textStyle = GoogleFonts.openSans(
    color: textColor,
    fontSize: fontSize,
    fontWeight: fontWeight,
  );

  static const BorderRadius borderRadiusGeometry = BorderRadius.all(Radius.circular(borderRadius));
}

/// Tips内容组件 - 企业级重构版本
///
/// 主要特性：
/// 1. 性能优化 - 使用StatelessWidget和RepaintBoundary
/// 2. 静态常量缓存 - 避免重复对象创建
/// 3. 独立组件 - 支持在其他地方复用
/// 4. 遵循项目规范 - 保持API向后兼容性
class TipsContent extends StatelessWidget {
  const TipsContent({super.key});

  @override
  Widget build(BuildContext context) {
    // 使用RepaintBoundary隔离重绘范围，遵循性能优化规范
    return RepaintBoundary(
      child: Center(
        child: ClipRRect(
          borderRadius: _TipsStyle.borderRadiusGeometry,
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: _TipsStyle.blurRadius, sigmaY: _TipsStyle.blurRadius),
            child: Container(
              padding: _TipsStyle.padding,
              decoration: const BoxDecoration(
                color: _TipsStyle.backgroundColor,
                borderRadius: _TipsStyle.borderRadiusGeometry,
              ),
              child: Text(
                LocaleKeys.msg_tips.tr,
                style: _TipsStyle.textStyle, // 使用缓存的样式对象
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
