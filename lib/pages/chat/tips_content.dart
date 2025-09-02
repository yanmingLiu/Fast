import 'package:fast_ai/data/msg_data.dart';
import 'package:fast_ai/values/app_text_style.dart';
import 'package:flutter/material.dart';

/// Tips样式相关的静态常量，遵循项目性能优化规范
class _TipsStyle {
  _TipsStyle._(); // 私有构造函数

  static const double fontSize = 10.0;
  static const double borderRadius = 16.0;
  static const EdgeInsets padding = EdgeInsets.symmetric(horizontal: 12, vertical: 8);
  static const Color backgroundColor = Color(0x801C1C1C);
  static const FontWeight fontWeight = FontWeight.w400;
  static const Color textColor = Colors.white;

  // 缓存样式对象，避免每次build时重新创建
  static final TextStyle textStyle = AppTextStyle.openSans(
    color: textColor,
    fontSize: fontSize,
    fontWeight: fontWeight,
  );

  static const BorderRadius borderRadiusGeometry = BorderRadius.all(Radius.circular(borderRadius));
}

/// Tips内容组件
class TipsContent extends StatelessWidget {
  const TipsContent({super.key, required this.msg});

  final MsgData msg;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        padding: _TipsStyle.padding,
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.8),
        decoration: const BoxDecoration(
          color: _TipsStyle.backgroundColor,
          borderRadius: _TipsStyle.borderRadiusGeometry,
        ),

        child: Text(
          msg.answer ?? '',
          textAlign: TextAlign.center,
          style: _TipsStyle.textStyle, // 使用缓存的样式对象
        ),
      ),
    );
  }
}
