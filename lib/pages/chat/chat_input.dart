import 'dart:ui';

import 'package:fast_ai/component/f_button.dart';
import 'package:fast_ai/component/f_dialog.dart';
import 'package:fast_ai/component/f_icon.dart';
import 'package:fast_ai/component/f_toast.dart';
import 'package:fast_ai/gen/assets.gen.dart';
import 'package:fast_ai/generated/locales.g.dart';
import 'package:fast_ai/pages/chat/gift_page.dart';
import 'package:fast_ai/pages/chat/mode_sheet.dart';
import 'package:fast_ai/pages/chat/msg_ctr.dart';
import 'package:fast_ai/pages/chat/msg_edit_page.dart';
import 'package:fast_ai/pages/router/app_router.dart';
import 'package:fast_ai/services/f_cache.dart';
import 'package:fast_ai/services/f_log_event.dart';
import 'package:fast_ai/services/m_y.dart';
import 'package:fast_ai/tools/ext.dart';
import 'package:fast_ai/values/theme_colors.dart'; // 统一颜色管理
import 'package:fast_ai/values/theme_style.dart';
import 'package:fast_ai/values/values.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ChatInput extends StatefulWidget {
  const ChatInput({super.key});

  @override
  State<ChatInput> createState() => _ChatInputState();
}

class _ChatInputState extends State<ChatInput> {
  late TextEditingController textEditingController;
  bool isSend = false;
  final FocusNode focusNode = FocusNode();
  final MsgCtr ctr = Get.find<MsgCtr>();

  @override
  void initState() {
    super.initState();
    textEditingController = TextEditingController();
    textEditingController.addListener(_onInputChange);
  }

  @override
  void dispose() {
    super.dispose();
    textEditingController.removeListener(_onInputChange);
    focusNode.dispose();
  }

  void firstClickChatInputBox() async {
    focusNode.unfocus();
    FCache().firstClickChatInputBox = false;
    setState(() {}); // 更新UI，移除覆盖层

    await FDialog.alert(
      message: LocaleKeys.create_mask_profile_description.tr,
      cancelText: LocaleKeys.cancel.tr,
      confirmText: LocaleKeys.confirm.tr,
      clickMaskDismiss: false,
      onConfirm: () {
        FDialog.dismiss();
        AppRouter.pushMask();
      },
    );
  }

  void _onInputChange() async {
    if (textEditingController.text.length > 500) {
      FToast.toast(LocaleKeys.max_input_length.tr);
      // 截断文本到500字符
      textEditingController.text = textEditingController.text.substring(0, 500);
      // 将光标移到文本末尾
      textEditingController.selection = TextSelection.fromPosition(
        TextPosition(offset: textEditingController.text.length),
      );
    }
    isSend = textEditingController.text.isNotEmpty;
    setState(() {});
  }

  // 0  tease, 1 undress, 2 gift, 3 mask, 100 screen, 101 sortlong
  void onTapTag(int index) {
    if (index == 100) {
      editScene();
    } else if (index == 101) {
      // 聊天模型 chat_model short / long
      showChatModel();
    } else {
      final item = ctr.inputTags[index];
      final id = item['id'];

      if (id == 0) {
        List<String> list = item['list'];
        textEditingController.text = list.randomOrNull ?? '';
        onSend();
      } else if (id == 1) {
        AppRouter.pushUndr(ctr.role);
      } else if (id == 2) {
        showGift();
      } else if (id == 3) {
        AppRouter.pushMask();
      } else {
        FToast.toast(LocaleKeys.not_support.tr);
      }
    }
  }

  void editScene() {
    Get.bottomSheet(
      MsgEditPage(
        content: ctr.session.scene ?? '',
        onInputTextFinish: (v) {
          if (v == ctr.session.scene) {
            Get.back();
            return;
          }
          if (!MY().isVip.value) {
            AppRouter.pushVip(ProFrom.scenario);
            return;
          }
          Get.back();
          ctr.editScene(v);
        },
        subtitle: Row(
          spacing: 4,
          children: [
            Text(
              LocaleKeys.edit_scenario.tr,
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w700),
            ),
          ],
        ),
      ),
      enableDrag: false, // 禁用底部表单拖拽，避免与文本选择冲突
      isScrollControlled: true,
      isDismissible: true,
      ignoreSafeArea: false,
    );
  }

  void showChatModel() {
    final isLong = ctr.session.chatModel == 'long';
    Get.bottomSheet(
      ModeSheet(
        isLong: isLong,
        onTap: (bool v) {
          ctr.editChatMode(v);
        },
      ),
    );
  }

  void showGift() {
    Get.bottomSheet(GiftPage(), isScrollControlled: true);
  }

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => Column(
        children: [
          ctr.inputTags.isEmpty
              ? const SizedBox()
              : MsgInputButtons(tags: ctr.inputTags.toList(), onTap: onTapTag),
          Container(
            padding: const EdgeInsets.only(bottom: 4),
            margin: EdgeInsets.symmetric(horizontal: 16),
            child: Stack(
              children: [
                SafeArea(
                  top: false,
                  left: false,
                  right: false,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                      child: Container(
                        color: Color(0xCC000000),
                        constraints: BoxConstraints(maxHeight: 80),
                        child: Row(
                          children: [
                            SizedBox(width: 12),
                            _buildSpecialButton(),
                            Flexible(child: _buildTextField()),
                            SizedBox(width: 8),
                            FButton(
                              onTap: onSend,
                              width: 50,
                              color: Colors.transparent,
                              highlightColor: Colors.transparent,
                              hoverColor: Colors.transparent,
                              child: Center(
                                child: FIcon(
                                  assetName: Assets.svg.send,
                                  color: isSend
                                      ? ThemeColors.primary
                                      : ThemeColors.primaryMedium,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                // 第一次使用时的覆盖层
                if (FCache().firstClickChatInputBox)
                  Positioned.fill(
                      child: GestureDetector(onTap: firstClickChatInputBox)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField() {
    return TextField(
      textInputAction: TextInputAction.send,
      onEditingComplete: onSend,
      minLines: 1,
      maxLines: null,
      style: ThemeStyle.openSans(
        height: 1.2,
        color: Colors.white,
        fontSize: 14,
        fontWeight: FontWeight.w600,
      ),
      controller: textEditingController,
      enableInteractiveSelection: true, // 确保文本选择功能启用
      dragStartBehavior: DragStartBehavior.down, // 优化拖拽行为
      cursorColor: Colors.white,
      decoration: InputDecoration(
        hintText: LocaleKeys.type_here.tr,
        hintStyle: ThemeStyle.openSans(color: Color(0xFF727374)),
        fillColor: Colors.transparent,
        border: InputBorder.none,
        filled: true,
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(horizontal: 5, vertical: 10),
      ),
      autofocus: false,
      focusNode: focusNode,
    );
  }

  void onSend() async {
    String content = textEditingController.text.trim();
    if (content.isNotEmpty) {
      focusNode.unfocus();
      ctr.sendMsg(content);
      textEditingController.clear();
    } else {
      textEditingController.clear();
      return;
    }
    logEvent('c_chat_send');
  }

  Widget _buildSpecialButton() {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).requestFocus(focusNode);

        final text = textEditingController.text;
        final selection = textEditingController.selection;

        // Insert "**" at the current cursor position
        final newText = text.replaceRange(selection.start, selection.end, '**');

        // Update the text and set the cursor between the two asterisks
        textEditingController.value = TextEditingValue(
          text: newText,
          selection: TextSelection.fromPosition(
              TextPosition(offset: selection.start + 1)),
        );
      },
      child: Container(
        padding: const EdgeInsets.only(top: 4),
        width: 20,
        height: 32,
        child: const Center(
          child: Text(
            '*',
            style: TextStyle(
                color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }
}

class MsgInputButtons extends StatelessWidget {
  const MsgInputButtons({super.key, required this.tags, required this.onTap});

  final List<dynamic> tags;
  final Function(int) onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.bottomCenter,
      height: 50,
      child: Row(
        children: [
          Expanded(
            child: Container(
              alignment: Alignment.center,
              child: ListView.separated(
                physics: const BouncingScrollPhysics(),
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemBuilder: (context, index) {
                  final item = tags[index];
                  return GestureDetector(
                    onTap: () => onTap(index),
                    child: Container(
                      margin: const EdgeInsets.symmetric(vertical: 12),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(13),
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                          child: Container(
                            height: 26,
                            color: Color(0x801C1C1C),
                            alignment: Alignment.centerLeft,
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                            child: Row(
                              spacing: 2,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Image.asset(item['icon'],
                                    width: 16, height: 16),
                                Text(
                                  item['name'],
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  textAlign: TextAlign.center,
                                  style: ThemeStyle.openSans(
                                    fontSize: 11,
                                    color: ThemeColors.primary,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                },
                separatorBuilder: (context, index) => const SizedBox(width: 12),
                itemCount: tags.length,
              ),
            ),
          ),
          GestureDetector(
            onTap: () {
              onTap(100);
            },
            child: Container(
              height: double.infinity,
              padding: EdgeInsets.symmetric(horizontal: 8),
              child: Assets.images.screen.image(width: 32),
            ),
          ),
          GestureDetector(
            onTap: () {
              onTap(101);
            },
            child: Container(
              height: double.infinity,
              padding: EdgeInsets.symmetric(horizontal: 8),
              child: Assets.images.model.image(width: 32),
            ),
          ),
          SizedBox(width: 8),
        ],
      ),
    );
  }
}
