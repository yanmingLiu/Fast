import 'package:fast_ai/component/f_button.dart';
import 'package:fast_ai/component/f_icon.dart';
import 'package:fast_ai/data/msg_data.dart';
import 'package:fast_ai/gen/assets.gen.dart';
import 'package:fast_ai/pages/chat/msg_ctr.dart';
import 'package:fast_ai/pages/chat/msg_edit_page.dart';
import 'package:fast_ai/pages/chat/send_container.dart';
import 'package:fast_ai/pages/chat/text_lock.dart';
import 'package:fast_ai/pages/chat/typing_rich_text.dart';
import 'package:fast_ai/pages/router/app_router.dart';
import 'package:fast_ai/services/f_cache.dart';
import 'package:fast_ai/services/m_y.dart';
import 'package:fast_ai/values/theme_colors.dart';
import 'package:fast_ai/values/theme_style.dart';
import 'package:fast_ai/values/values.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

// 性能优化：预定义常量，避免重复创建对象
const double _maxWidthRatio = 0.8;
const double _containerPadding = 12.0;
const double _buttonSize = 24.0;
const double _continueButtonWidth = 48.0;
const double _continueButtonHeight = 24.0;
const double _borderRadius = 16.0;

// 性能优化：缓存样式对象，避免每次build重新创建
final TextStyle _titleStyle = ThemeStyle.openSans(
  fontSize: 14,
  fontWeight: FontWeight.w700,
  color: ThemeColors.primary,
);

// 静态组件常量，避免重复创建
class _Constants {
  // 预定义的边距和约束
  static const EdgeInsets sendTextPadding = EdgeInsets.all(_containerPadding);
  static const BorderRadius containerBorderRadius = BorderRadius.all(
    Radius.circular(_borderRadius),
  );
}

/// 文本消息容器组件
class TextContainer extends StatefulWidget {
  const TextContainer({super.key, required this.msg, this.title});

  final MsgData msg;
  final String? title;

  @override
  State<TextContainer> createState() => _TextContainerState();
}

class _TextContainerState extends State<TextContainer> {
  // 性能优化：使用AppColors统一颜色管理
  static const Color _bgColor = Color(0x801C1C1C);
  static const BorderRadius _borderRadius = _Constants.containerBorderRadius;

  // 控制器缓存，避免重复查找
  late final MsgCtr _ctr;

  // 缓存条件判断结果，避免重复调用
  late final bool _isBig;

  @override
  void initState() {
    super.initState();
    _ctr = Get.find<MsgCtr>();
    _isBig = FCache().isBig;
  }

  @override
  Widget build(BuildContext context) {
    final msg = widget.msg;

    // 错误隔离设计：安全获取消息内容
    final sendText = _getSendTextSafely(msg);
    final receivText = _getReceiveTextSafely(msg);

    // 优化后的显示逻辑判断
    final shouldShowSend = _shouldShowSendMessage(msg, sendText);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (shouldShowSend)
          Padding(
            padding: const EdgeInsets.only(bottom: 16.0),
            child: SendContainer(msg: widget.msg),
          ),
        if (receivText != null) _buildReceiveText(context),
      ],
    );
  }

  /// 错误隔离设计：安全获取发送文本
  String? _getSendTextSafely(MsgData msg) {
    try {
      return msg.question;
    } catch (e) {
      debugPrint('[TextContainer] 获取发送文本失败: $e');
      return null;
    }
  }

  /// 错误隔离设计：安全获取接收文本
  String? _getReceiveTextSafely(MsgData msg) {
    try {
      return msg.answer;
    } catch (e) {
      debugPrint('[TextContainer] 获取接收文本失败: $e');
      return null;
    }
  }

  /// 优化后的发送消息显示判断逻辑
  bool _shouldShowSendMessage(MsgData msg, String? sendText) {
    try {
      // 特殊情况：服装类型消息不显示发送文本
      if (msg.source == MsgType.clothe) {
        return false;
      }

      // 显示条件：发送文本类型或有发送内容且未在等待回答
      return msg.source == MsgType.sendText ||
          (sendText != null && msg.onAnswer != true);
    } catch (e) {
      debugPrint('[TextContainer] 判断发送消息显示失败: $e');
      return false;
    }
  }

  /// 构建接收文本区域（包含VIP锁定检查）
  Widget _buildReceiveText(BuildContext context) {
    return Obx(() {
      // 错误隔离设计：安全获取VIP状态
      final isVip = _getVipStatusSafely();
      final isLocked = _isMessageLocked();

      if (!isVip && isLocked) {
        return TextLock(textContent: widget.msg.answer ?? '');
      }

      return _buildText(context);
    });
  }

  /// 错误隔离设计：安全获取VIP状态
  bool _getVipStatusSafely() {
    try {
      return MY().isVip.value;
    } catch (e) {
      debugPrint('[TextContainer] 获取VIP状态失败,使用默认值false: $e');
      return false;
    }
  }

  /// 错误隔离设计：安全检查消息锁定状态
  bool _isMessageLocked() {
    try {
      return widget.msg.textLock == LockType.private.value;
    } catch (e) {
      debugPrint('[TextContainer] 检查消息锁定状态失败,使用默认值false: $e');
      return false;
    }
  }

  /// 翻译显示逻辑配置
  ///
  /// 根据用户设置和语言环境决定翻译相关的显示状态
  /// 返回 (shouldShowTranslate, shouldShowTransBtn, displayContent)
  (bool, bool, String) _calculateTranslationState(MsgData msg) {
    final hasTranslation =
        msg.translateAnswer != null && msg.translateAnswer!.isNotEmpty;
    final isAutoTranslateEnabled = MY().user?.autoTranslate == true;
    final isEnglishLocale = Get.deviceLocale?.languageCode == 'en';
    final userRequestedTranslation = msg.showTranslate == true;

    // 错误隔离设计：安全获取原始内容
    final originalContent = msg.answer ?? '';
    final translatedContent = msg.translateAnswer ?? '';

    bool shouldShowTranslate = false;
    bool shouldShowTransBtn = true;
    String displayContent = originalContent;

    if (isAutoTranslateEnabled) {
      // 自动翻译模式
      shouldShowTransBtn = false;
      if (hasTranslation) {
        shouldShowTranslate = true;
        displayContent = translatedContent;
      } else {
        shouldShowTranslate = false;
        displayContent = originalContent;
      }
    } else {
      // 手动翻译模式
      if (isEnglishLocale) {
        // 英语环境下不显示翻译按钮
        shouldShowTransBtn = false;
      }

      if (userRequestedTranslation && hasTranslation) {
        shouldShowTranslate = true;
        displayContent = translatedContent;
      } else {
        shouldShowTranslate = false;
        displayContent = originalContent;
      }
    }

    return (shouldShowTranslate, shouldShowTransBtn, displayContent);
  }

  Widget _buildText(BuildContext context) {
    final msg = widget.msg;

    // 使用优化后的翻译状态计算逻辑
    final (showTranslate, showTransBtn, content) =
        _calculateTranslationState(msg);

    // 性能优化：预计算屏幕宽度约束
    final maxWidth = MediaQuery.of(context).size.width * _maxWidthRatio;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: _Constants.sendTextPadding,
          decoration:
              BoxDecoration(color: _bgColor, borderRadius: _borderRadius),
          constraints: BoxConstraints(maxWidth: maxWidth),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (widget.title != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Text(
                    widget.title!,
                    style: _titleStyle,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              RepaintBoundary(
                child: TypingRichText(
                  text: content,
                  isSend: false,
                  isTypingAnimation: msg.typewriterAnimated == true,
                  onAnimationComplete: () => _handleAnimationComplete(msg),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        if (!_isTypingAnimationActive(msg))
          _buildActionButtons(msg, showTranslate, showTransBtn),
      ],
    );
  }

  /// 处理打字动画完成事件
  void _handleAnimationComplete(MsgData msg) {
    try {
      if (msg.typewriterAnimated == true) {
        setState(() {
          msg.typewriterAnimated = false;
          _ctr.list.refresh();
        });
      }
    } catch (e) {
      debugPrint('[TextContainer] 处理动画完成失败: $e');
    }
  }

  /// 检查打字动画是否激活
  bool _isTypingAnimationActive(MsgData msg) {
    try {
      return msg.typewriterAnimated == true;
    } catch (e) {
      debugPrint('[TextContainer] 检查动画状态失败: $e');
      return false;
    }
  }

  /// 构建操作按钮行
  Widget _buildActionButtons(
      MsgData msg, bool showTranslate, bool showTransBtn) {
    return Wrap(
      spacing: 16,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        // 只有最后一条消息才显示消息操作按钮
        if (_isLastMessage(msg)) ..._buildMsgActions(msg),

        // 举报按钮（非大屏模式下显示）
        if (!_isBig) _buildReportButton(),

        // 翻译按钮
        if (showTransBtn) _buildTranslateButton(showTranslate),
      ],
    );
  }

  /// 检查是否为最后一条消息
  bool _isLastMessage(MsgData msg) {
    try {
      return widget.msg == _ctr.list.lastOrNull;
    } catch (e) {
      debugPrint('[TextContainer] 检查最后消息失败: $e');
      return false;
    }
  }

  /// 构建举报按钮
  Widget _buildReportButton() {
    return RepaintBoundary(
      child: FButton(
        width: _buttonSize,
        height: _buttonSize,
        onTap: AppRouter.report,
        child: FIcon(assetName: Assets.svg.report, width: _buttonSize),
      ),
    );
  }

  /// 构建翻译按钮
  Widget _buildTranslateButton(bool showTranslate) {
    return RepaintBoundary(
      child: FButton(
        onTap: () => _handleTranslateMessage(),
        width: _buttonSize,
        height: _buttonSize,
        child: FIcon(
          assetName: Assets.svg.trans,
          width: _buttonSize,
          color: showTranslate ? ThemeColors.primary : Colors.white,
        ),
      ),
    );
  }

  /// 处理翻译消息事件
  void _handleTranslateMessage() {
    try {
      _ctr.translateMsg(widget.msg);
    } catch (e) {
      debugPrint('[TextContainer] 翻译消息失败: $e');
    }
  }

  /// 构建消息操作按钮组
  List<Widget> _buildMsgActions(MsgData msg) {
    final hasEditAndRefresh = _hasEditAndRefreshActions(msg);

    return [
      // 续写按钮
      _buildContinueButton(),

      // 编辑和刷新按钮（仅特定消息类型）
      if (hasEditAndRefresh) ...[
        _buildEditButton(msg),
        _buildRefreshButton(msg)
      ],
    ];
  }

  /// 判断消息是否支持编辑和刷新操作
  bool _hasEditAndRefreshActions(MsgData msg) {
    try {
      return msg.source == MsgType.text ||
          msg.source == MsgType.video ||
          msg.source == MsgType.audio ||
          msg.source == MsgType.photo;
    } catch (e) {
      debugPrint('[TextContainer] 检查编辑刷新权限失败: $e');
      return false;
    }
  }

  /// 构建续写按钮
  Widget _buildContinueButton() {
    return RepaintBoundary(
      child: InkWell(
        splashColor: Colors.transparent,
        onTap: () => _handleContinueWriting(),
        child: Assets.images.msgContine.image(
          width: _continueButtonWidth,
          height: _continueButtonHeight,
        ),
      ),
    );
  }

  /// 处理续写事件
  void _handleContinueWriting() {
    try {
      _ctr.continueWriting();
    } catch (e) {
      debugPrint('[TextContainer] 续写失败: $e');
    }
  }

  /// 构建编辑按钮
  Widget _buildEditButton(MsgData msg) {
    return RepaintBoundary(
      child: InkWell(
        splashColor: Colors.transparent,
        onTap: () => _handleEditMessage(msg),
        child:
            Assets.images.edit.image(width: _buttonSize, height: _buttonSize),
      ),
    );
  }

  /// 处理编辑消息事件
  void _handleEditMessage(MsgData msg) {
    try {
      Get.bottomSheet(
        MsgEditPage(
          content: msg.answer ?? '',
          onInputTextFinish: (value) {
            Get.back();
            _ctr.editMsg(value, msg);
          },
        ),
        enableDrag: false, // 禁用底部表单拖拽，避免与文本选择冲突
        isScrollControlled: true,
        isDismissible: true,
        ignoreSafeArea: false,
      );
    } catch (e) {
      debugPrint('[TextContainer] 编辑消息失败: $e');
    }
  }

  /// 构建刷新按钮
  Widget _buildRefreshButton(MsgData msg) {
    return RepaintBoundary(
      child: InkWell(
        splashColor: Colors.transparent,
        onTap: () => _handleResendMessage(msg),
        child: Assets.images.refresh
            .image(width: _buttonSize, height: _buttonSize),
      ),
    );
  }

  /// 处理重发消息事件
  void _handleResendMessage(MsgData msg) {
    try {
      _ctr.resendMsg(msg);
    } catch (e) {
      debugPrint('[TextContainer] 重发消息失败: $e');
    }
  }
}
