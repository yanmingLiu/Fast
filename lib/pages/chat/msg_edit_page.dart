import 'package:fast_ai/gen/assets.gen.dart';
import 'package:fast_ai/generated/locales.g.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:get/get.dart';

class MsgEditPage extends StatefulWidget {
  const MsgEditPage({super.key, required this.onInputTextFinish, this.content, this.subtitle});

  final String? content;
  final Widget? subtitle;
  final Function(String text) onInputTextFinish;

  @override
  State<MsgEditPage> createState() => _MsgEditPageState();
}

class _MsgEditPageState extends State<MsgEditPage> {
  final focusNode = FocusNode();
  final textController = TextEditingController();

  @override
  void initState() {
    focusNode.requestFocus();
    textController.addListener(_onTextChanged);
    if (widget.content != null && widget.content!.isNotEmpty) {
      textController.text = widget.content!;
    }
    super.initState();
  }

  void _onTextChanged() {
    if (textController.text.length > 500) {
      SmartDialog.showToast(
        LocaleKeys.max_input_length.tr,
        displayType: SmartToastType.onlyRefresh,
      );
      // 截断文本到500字符
      textController.text = textController.text.substring(0, 500);
      // 将光标移到文本末尾
      textController.selection = TextSelection.fromPosition(
        TextPosition(offset: textController.text.length),
      );
    }
  }

  void _onSure() {
    focusNode.unfocus();
    // 将值回调出去
    widget.onInputTextFinish(textController.text.trim());
  }

  @override
  void dispose() {
    textController.removeListener(_onTextChanged);
    textController.dispose();
    focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => focusNode.requestFocus(),
      child: Container(
        margin: EdgeInsets.only(top: MediaQuery.of(context).size.height / 2 - 150),
        decoration: BoxDecoration(
          color: const Color(0xFF333333),
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(16),
            topRight: Radius.circular(16),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                InkWell(
                  onTap: () {
                    focusNode.unfocus();
                    Get.back();
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                    child: const Icon(Icons.close, color: Colors.white),
                  ),
                ),
                Expanded(
                  child: Column(
                    children: [
                      Container(
                        width: 44,
                        height: 4,
                        decoration: BoxDecoration(
                          color: Color(0xFFD9D9D9),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      SizedBox(height: 8),
                    ],
                  ),
                ),
                InkWell(
                  onTap: _onSure,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                    child: Assets.images.selected.image(width: 24, height: 24),
                  ),
                ),
              ],
            ),
            if (widget.subtitle != null)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 16),
                child: widget.subtitle!,
              ),
            Expanded(
              child: Container(
                margin: EdgeInsets.symmetric(horizontal: 16),
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                decoration: BoxDecoration(
                  color: Color(0x40808080),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: NotificationListener<ScrollNotification>(
                  onNotification: (notification) {
                    // 阻止滚动通知传播到父级，避免与底部表单的拖拽冲突
                    return true;
                  },
                  child: TextField(
                    autofocus: true,
                    textInputAction: TextInputAction.newline, // 修改为换行操作
                    maxLines: null, // 允许多行输入
                    minLines: 5, // 最小显示5行
                    maxLength: null,
                    enableInteractiveSelection: true, // 确保文本选择功能启用
                    dragStartBehavior: DragStartBehavior.down, // 优化拖拽行为
                    style: const TextStyle(
                      height: 1.5, // 增加行高
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                    controller: textController,
                    decoration: InputDecoration(
                      contentPadding: EdgeInsets.zero, // 添加内边距
                      hintText: LocaleKeys.please_input_custom_text.tr,
                      counterText: '',
                      hintStyle: const TextStyle(color: Color(0xFFB3B3B3)),
                      fillColor: Colors.transparent,
                      border: InputBorder.none,
                      filled: true,
                      isDense: true,
                    ),
                    focusNode: focusNode,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
