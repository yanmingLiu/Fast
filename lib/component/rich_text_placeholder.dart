import 'package:flutter/material.dart';

class RichTextPlaceholder extends StatelessWidget {
  final String textKey;
  final Map<String, InlineSpan> placeholders;
  final TextStyle? style;

  const RichTextPlaceholder({
    super.key,
    required this.textKey,
    this.placeholders = const {},
    this.style,
  });

  @override
  Widget build(BuildContext context) {
    return RichText(text: _parse(textKey));
  }

  TextSpan _parse(String input) {
    final RegExp regex = RegExp(r'{{(.*?)}}');
    final List<InlineSpan> spans = [];
    int currentIndex = 0;

    for (final match in regex.allMatches(input)) {
      final start = match.start;
      final end = match.end;
      final key = match.group(1)!;

      // 前面的纯文字
      if (start > currentIndex) {
        spans.add(TextSpan(text: input.substring(currentIndex, start), style: style));
      }

      // 插入 Widget 或文字占位
      final span = placeholders[key];
      if (span != null) {
        spans.add(span);
      } else {
        spans.add(TextSpan(text: '{{$key}}', style: style)); // 占位未识别，原样显示
      }

      currentIndex = end;
    }

    // 最后尾部剩余文字
    if (currentIndex < input.length) {
      spans.add(TextSpan(text: input.substring(currentIndex), style: style));
    }

    return TextSpan(style: style, children: spans);
  }
}
