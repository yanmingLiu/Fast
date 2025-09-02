import 'package:fast_ai/pages/chat/msg_ctr.dart';
import 'package:fast_ai/pages/chat/msg_item.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:scroll_to_index/scroll_to_index.dart';

class MsgListView extends StatefulWidget {
  const MsgListView({super.key});

  @override
  State<MsgListView> createState() => _MsgListViewState();
}

class _MsgListViewState extends State<MsgListView> {
  late AutoScrollController autoController;

  final ctr = Get.find<MsgCtr>();

  @override
  void initState() {
    super.initState();
    autoController = AutoScrollController(
      viewportBoundaryGetter: () => Rect.fromLTRB(0, 0, 0, MediaQuery.of(context).padding.bottom),
      axis: Axis.vertical,
    );
  }

  @override
  Widget build(BuildContext context) {
    const bottom = 20.0;
    final listHeight =
        MediaQuery.of(context).size.height - MediaQuery.of(context).padding.bottom - 20;
    final top = listHeight * 0.5;

    return Stack(
      alignment: Alignment.topLeft,
      children: [
        GestureDetector(
          onPanDown: (_) {
            try {
              FocusScopeNode currentFocus = FocusScope.of(context);
              if (currentFocus.focusedChild != null && !currentFocus.hasPrimaryFocus) {
                FocusManager.instance.primaryFocus?.unfocus();
              } else {
                SystemChannels.textInput.invokeMethod('TextInput.hide');
              }
            } catch (e) {}
          },
          child: Obx(() {
            final list = ctr.list.reversed.toList();
            return ShaderMask(
              blendMode: BlendMode.dstIn,
              shaderCallback: (rect) {
                return const LinearGradient(
                  colors: [Colors.transparent, Colors.transparent, Colors.white],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  stops: [0, 0.4, 0.5],
                ).createShader(rect);
              },
              child: ListView.separated(
                controller: autoController,
                physics: const BouncingScrollPhysics(),
                padding: EdgeInsets.symmetric(horizontal: 16).copyWith(top: top, bottom: bottom),
                reverse: true,
                itemBuilder: (context, index) {
                  var item = list[index];
                  return AutoScrollTag(
                    controller: autoController,
                    index: index,
                    key: ValueKey('${item.id}_${item.source.name}'), // 更稳定的key
                    child: MsgItem(msg: item),
                  );
                },
                separatorBuilder: (context, index) {
                  return SizedBox(height: 16);
                },
                itemCount: list.length,
              ),
            );
          }),
        ),
      ],
    );
  }
}
