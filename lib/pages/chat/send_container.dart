import 'package:fast_ai/data/msg_data.dart';
import 'package:fast_ai/pages/chat/typing_rich_text.dart';
import 'package:fast_ai/values/theme_colors.dart';
import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

// 布局和样式常量
class _SendContainerConstants {
  static const double maxWidthRatio = 0.8;
  static const double loadingContainerWidth = 64.0;
  static const double loadingContainerHeight = 44.0;
  static const double borderRadius = 16.0;
  static const double loadingAnimationSize = 60.0;

  // 颜色常量
  static const Color loadingBgColor = Color(0x801C1C1C);

  // 边距常量
  static const EdgeInsets sendTextPadding = EdgeInsets.all(12.0);
  static const EdgeInsets loadingMargin = EdgeInsets.only(top: 16.0);

  // 圆角常量
  static const BorderRadius messageBorderRadius =
      BorderRadius.all(Radius.circular(borderRadius));
  static const BorderRadius loadingBorderRadius =
      BorderRadius.all(Radius.circular(borderRadius));

  // 约束常量
  static BoxConstraints getMaxWidthConstraints(double screenWidth) =>
      BoxConstraints(maxWidth: screenWidth * maxWidthRatio);
}

class SendContainer extends StatelessWidget {
  const SendContainer({super.key, required this.msg});

  final MsgData msg;

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final sendText = msg.question ?? '';
    final showLoading = _shouldShowLoadingIndicator();
    final isRTL = Directionality.of(context) == TextDirection.rtl;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment:
          isRTL ? CrossAxisAlignment.start : CrossAxisAlignment.end,
      children: [
        _buildMessageContainer(sendText, screenWidth, context),
        if (showLoading) _buildLoadingIndicator(context),
      ],
    );
  }

  /// 构建消息容器
  Widget _buildMessageContainer(
      String text, double screenWidth, BuildContext context) {
    final isRTL = Directionality.of(context) == TextDirection.rtl;

    return Align(
      alignment: isRTL ? Alignment.centerLeft : Alignment.centerRight,
      child: Container(
        padding: _SendContainerConstants.sendTextPadding,
        decoration: const BoxDecoration(
          color: ThemeColors.primary,
          borderRadius: _SendContainerConstants.messageBorderRadius,
        ),
        constraints:
            _SendContainerConstants.getMaxWidthConstraints(screenWidth),
        child: RepaintBoundary(
          child: TypingRichText(
              text: text, isSend: false, isTypingAnimation: false),
        ),
      ),
    );
  }

  /// 判断是否显示加载指示器
  bool _shouldShowLoadingIndicator() {
    try {
      return msg.onAnswer == true;
    } catch (e) {
      debugPrint('[SendContainer] 检查加载状态失败: $e');
      return false;
    }
  }

  /// 构建加载指示器
  Widget _buildLoadingIndicator(BuildContext context) {
    final isRTL = Directionality.of(context) == TextDirection.rtl;

    return Align(
      alignment: isRTL ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        width: _SendContainerConstants.loadingContainerWidth,
        height: _SendContainerConstants.loadingContainerHeight,
        margin: _SendContainerConstants.loadingMargin,
        decoration: const BoxDecoration(
          color: _SendContainerConstants.loadingBgColor,
          borderRadius: _SendContainerConstants.loadingBorderRadius,
        ),
        child: Center(
          child: RepaintBoundary(
            child: LoadingAnimationWidget.newtonCradle(
              color: ThemeColors.primary,
              size: _SendContainerConstants.loadingAnimationSize,
            ),
          ),
        ),
      ),
    );
  }
}
