import 'package:fast_ai/gen/fonts.gen.dart';
import 'package:flutter/material.dart';

class AppTextStyle {
  AppTextStyle._();

  static TextStyle openSans({
    double? fontSize,
    double? height,
    FontWeight? fontWeight,
    Color? color,
    FontStyle? fontStyle,
  }) => TextStyle(
    fontSize: fontSize,
    fontWeight: fontWeight,
    color: color,
    fontStyle: fontStyle,
    fontFamily: FontFamily.openSans,
    height: height,
  );
}
