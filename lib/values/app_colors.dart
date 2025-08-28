import 'package:flutter/material.dart';

/// 应用颜色统一管理
///
/// 使用方式:
/// - AppColors.primary
/// - AppColors.primaryLight
/// - AppColors.primaryWithOpacity(0.5)
class AppColors {
  // 私有构造函数，防止实例化
  AppColors._();

  /// 主色调 - 蓝色 #3F8DFD
  static const Color primary = Color(0xFF3F8DFD);

  /// 主色调变体
  static const Color primaryLight = Color(0x1A3F8DFD); // 10% 透明度
  static const Color primaryMedium = Color(0x803F8DFD); // 50% 透明度
  static const Color primarySoft = Color(0x333F8DFD); // 20% 透明度

  /// 辅助颜色
  static const Color secondary = Color(0xFFFF4ACF); // 粉色 (NSFW标签色)
  static const Color success = Color(0xFF9CFC53); // 绿色 (默认标签色)
  static const Color warning = Color(0xFFED1010); // 红色 (警告色)
  static const Color separator = Color(0xFFCCCCCC); // 分隔符色
  static const Color hintText = Color(0xFFA8A8A8); // 提示文本色

  /// 常用的白色透明度变体
  static const Color white10 = Color(0x1AFFFFFF); // 10% 白色
  static const Color white20 = Color(0x33FFFFFF); // 20% 白色 (FButton默认色)
  static const Color white50 = Color(0x80FFFFFF); // 50% 白色

  /// 常用的黑色透明度变体
  static const Color black10 = Color(0x1A000000); // 10% 黑色
  static const Color black50 = Color(0x80000000); // 50% 黑色
  static const Color black70 = Color(0xB3000000); // 70% 黑色

  /// 阴影颜色
  static const Color shadow = Color(0x4D77AFFF); // 按钮阴影色

  /// 渐变色组合
  static const List<Color> primaryGradient = [primary, primary];
  static const List<Color> warningGradient = [
    Color(0x10ED1010), // 渐变起始色
    Color(0x29002929), // 渐变结束色
  ];
  static const List<Color> homeItemGradient = [
    Color(0xED101010),
    Colors.transparent,
    Colors.transparent,
    Color(0xED101010),
  ];
  static const List<Color> vipTagGradient = [Color(0xFFF4FCFF), primary];
}
