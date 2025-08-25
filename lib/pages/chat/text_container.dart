import 'package:fast_ai/component/f_button.dart';
import 'package:fast_ai/component/f_icon.dart';
import 'package:fast_ai/data/msg_data.dart';
import 'package:fast_ai/gen/assets.gen.dart';
import 'package:fast_ai/pages/chat/msg_ctr.dart';
import 'package:fast_ai/pages/chat/msg_edit_page.dart';
import 'package:fast_ai/pages/chat/text_lock.dart';
import 'package:fast_ai/pages/chat/typing_rich_text.dart';
import 'package:fast_ai/pages/router/app_router.dart';
import 'package:fast_ai/services/app_cache.dart';
import 'package:fast_ai/services/app_user.dart';
import 'package:fast_ai/values/app_values.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

class TextContainer extends StatefulWidget {
  const TextContainer({super.key, required this.msg, this.title});

  final MsgData msg;
  final String? title;

  @override
  State<TextContainer> createState() => _TextContainerState();
}

class _TextContainerState extends State<TextContainer> {
  Color bgColor = Color(0x801C1C1C);
  final borderRadius = BorderRadius.circular(16);
  final ctr = Get.find<MsgCtr>();

  @override
  Widget build(BuildContext context) {
    var msg = widget.msg;
    final sendText = msg.question;
    final receivText = msg.answer;

    bool showSend = false;

    if (msg.source == MsgSource.sendText || sendText != null && (msg.onAnswer == false)) {
      showSend = true;
    }
    if (msg.source == MsgSource.clothe) {
      showSend = false;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (showSend)
          Padding(padding: const EdgeInsets.only(bottom: 16.0), child: _buildSendText()),
        if (receivText != null)
          Align(
            alignment: Alignment.centerLeft,
            child: Obx(() {
              final isVip = AppUser().isVip.value;
              final lock = widget.msg.textLock == LockLevel.private.value;
              if (!isVip && lock) {
                return TextLock();
              }

              return _buildText(context);
            }),
          ),
      ],
    );
  }

  Widget _buildSendText() {
    final msg = widget.msg;
    final sendText = msg.question ?? '';

    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(color: Color(0xFF3F8DFD), borderRadius: borderRadius),
              constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.8),
              child: TypingRichText(text: sendText, isSend: false, isTypingAnimation: false),
            ),
          ],
        ),
        if (msg.onAnswer == true)
          Row(
            children: [
              Container(
                width: 64,
                height: 44,
                margin: const EdgeInsets.only(top: 16),
                decoration: BoxDecoration(
                  color: bgColor,
                  borderRadius: BorderRadius.all(Radius.circular(16)),
                ),
                child: Center(
                  child: LoadingAnimationWidget.progressiveDots(color: Color(0xFF3F8DFD), size: 30),
                ),
              ),
            ],
          ),
      ],
    );
  }

  Widget _buildText(BuildContext context) {
    final msg = widget.msg;

    var showTranslate = (msg.showTranslate == true && msg.translateAnswer != null);

    String content = showTranslate ? msg.translateAnswer ?? '' : msg.answer ?? '';

    var showTransBtn = true;

    if (AppUser().user?.autoTranslate == true) {
      showTransBtn = false;
      if (msg.translateAnswer == null || msg.translateAnswer!.isEmpty) {
        showTranslate = false;
      } else {
        showTranslate = true;
      }
    } else {
      if (Get.deviceLocale?.languageCode == 'en') {
        showTransBtn = false;
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 8,
      children: [
        Container(
          padding: EdgeInsets.all(12),
          decoration: BoxDecoration(color: bgColor, borderRadius: borderRadius),
          constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.8),
          child: Column(
            spacing: 4,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (widget.title != null)
                Text(
                  widget.title!,
                  style: GoogleFonts.openSans(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF3F8DFD),
                  ),
                ),
              TypingRichText(
                text: content,
                isSend: false,
                isTypingAnimation: msg.typewriterAnimated,
                onAnimationComplete: () {
                  // 打字动画完成后的回调
                  if (msg.typewriterAnimated) {
                    setState(() {
                      msg.typewriterAnimated = false;
                      ctr.list.refresh();
                    });
                  }
                },
              ),
            ],
          ),
        ),
        if (!msg.typewriterAnimated)
          Row(
            spacing: 16,
            children: [
              // 只有最后一条消息才显示这3个按钮 并且判断 msg.source
              if (widget.msg == ctr.list.lastOrNull) _buildMsgActions(msg),
              if (!AppCache().isBig)
                FButton(
                  width: 24,
                  height: 24,
                  onTap: AppRouter.report,
                  child: FIcon(assetName: Assets.svg.report, width: 24),
                ),
              if (showTransBtn)
                FButton(
                  onTap: () => ctr.translateMsg(widget.msg),
                  width: 24,
                  height: 24,
                  child: FIcon(
                    assetName: Assets.svg.trans,
                    width: 24,
                    color: showTranslate ? Color(0xFF3F8DFD) : Colors.white,
                  ),
                ),
            ],
          ),
      ],
    );
  }

  Row _buildMsgActions(MsgData msg) {
    /// 有编辑和刷新的消息类型
    /// - text('TEXT_GEN'): 文本消息
    /// - video('VIDEO'): 视频消息
    /// - audio('AUDIO'): 音频消息
    /// - photo('PHOTO'): 图片消息

    final hasEditAndRefresh =
        msg.source == MsgSource.text ||
        msg.source == MsgSource.video ||
        msg.source == MsgSource.audio ||
        msg.source == MsgSource.photo;

    return Row(
      spacing: 16,
      children: [
        // 续写
        InkWell(
          splashColor: Colors.transparent,
          child: Assets.images.msgContine.image(width: 48, height: 24),
          onTap: () => ctr.continueWriting(),
        ),
        if (hasEditAndRefresh) ...[
          InkWell(
            splashColor: Colors.transparent,
            child: Assets.images.edit.image(width: 24, height: 24),
            onTap: () {
              Get.bottomSheet(
                MsgEditPage(
                  content: msg.answer ?? '',
                  onInputTextFinish: (v) {
                    Get.back();
                    ctr.editMsg(v, msg);
                  },
                ),
                enableDrag: false, // 禁用底部表单拖拽，避免与文本选择冲突
                isScrollControlled: true,
                isDismissible: true,
                ignoreSafeArea: false,
              );
            },
          ),
          InkWell(
            splashColor: Colors.transparent,
            child: Assets.images.refresh.image(width: 24, height: 24),
            onTap: () {
              ctr.resendMsg(msg);
            },
          ),
        ],
      ],
    );
  }
}
