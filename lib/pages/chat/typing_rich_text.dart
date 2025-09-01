import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:fast_ai/values/app_text_style.dart';
import 'package:flutter/material.dart';

class TypingRichText extends StatelessWidget {
  const TypingRichText({
    super.key,
    required this.text,
    required this.isSend,
    this.isTypingAnimation = false, // 是否需要打字动画
    this.onAnimationComplete, // 动画完成的回调
  });

  final String text;
  final bool isSend;
  final bool isTypingAnimation; // 控制是否启用打字动画
  final VoidCallback? onAnimationComplete; // 动画完成后的回调

  @override
  Widget build(BuildContext context) {
    final nomarlStyel = AppTextStyle.openSans(
      color: Colors.white,
      fontSize: 14,
      fontWeight: FontWeight.w400,
      height: 1.3,
    );

    final highlightSetyle = AppTextStyle.openSans(
      color: Colors.white,
      fontSize: 14,
      fontWeight: FontWeight.bold,
      height: 1.3,
      fontStyle: FontStyle.italic,
    );

    List<TextSpan> spans = [];
    RegExp exp = RegExp(r'\*(.*?)\*');
    int lastMatchEnd = 0;

    exp.allMatches(text).forEach((match) {
      if (match.start > lastMatchEnd) {
        spans.add(TextSpan(text: text.substring(lastMatchEnd, match.start), style: nomarlStyel));
      }
      spans.add(TextSpan(text: ' *${match.group(1)!}* ', style: highlightSetyle));
      lastMatchEnd = match.end;
    });

    if (lastMatchEnd < text.length) {
      spans.add(TextSpan(text: text.substring(lastMatchEnd), style: nomarlStyel));
    }

    // 如果不需要动画，直接返回RichText
    if (!isTypingAnimation) {
      return RichText(text: TextSpan(children: spans));
    }

    // 使用打字机动画
    return AnimatedTextKit(
      animatedTexts: [
        TypewriterAnimatedText(
          text,
          cursor: '',
          textStyle: nomarlStyel,
          speed: const Duration(milliseconds: 30), // 打字速度（更快）
        ),
      ],
      totalRepeatCount: 1, // 打字动画只播放一次
      pause: const Duration(milliseconds: 20), // 暂停时间（更短）
      displayFullTextOnTap: true, // 点击文本显示完整内容
      onNext: (index, isLast) {
        // 在动画播放的每个字符后调用此方法
        if (isLast) {
          // 如果当前字符是最后一个字符，调用动画完成的回调
          if (onAnimationComplete != null) {
            onAnimationComplete!();
          }
        }
      },
    );
  }
}
