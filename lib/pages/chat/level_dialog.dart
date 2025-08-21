import 'package:fast_ai/gen/assets.gen.dart';
import 'package:fast_ai/generated/locales.g.dart';
import 'package:fast_ai/pages/chat/msg_ctr.dart';
import 'package:flutter/material.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';

class LevelDialog extends StatefulWidget {
  const LevelDialog({super.key});

  @override
  State<LevelDialog> createState() => _LevelDialogState();
}

class _LevelDialogState extends State<LevelDialog> {
  List<Map<String, dynamic>> datas = [];

  final ctr = Get.find<MsgCtr>();

  @override
  void initState() {
    super.initState();

    loadData();
  }

  Future<void> loadData() async {
    await ctr.loadChatLevel();
    setState(() {
      datas = ctr.chatLevelConfigs;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(16), color: Color(0xFF333333)),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            LocaleKeys.level_up_intimacy.tr,
            textAlign: TextAlign.center,
            style: GoogleFonts.openSans(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(children: datas.map((e) => _buildRow(e['icon'], e['text'], e['gems'])).toList()),
        ],
      ),
    );
  }

  Widget _buildRow(String icon, String text, int gems) {
    final width = (MediaQuery.of(context).size.width - 100) / 2;
    return Container(
      padding: EdgeInsets.all(12),
      width: width,
      height: width,
      decoration: BoxDecoration(
        image: DecorationImage(image: AssetImage(Assets.images.levelBg.path), fit: BoxFit.fill),
      ),
      child: Column(
        spacing: 8,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(icon, style: const TextStyle(fontSize: 27)),
          Text(
            text,
            style: GoogleFonts.openSans(
              fontSize: 10,
              fontWeight: FontWeight.w400,
              color: Colors.white,
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Assets.images.gems.image(width: 12),
              Text(
                "+ $gems",
                style: GoogleFonts.openSans(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class ChatLevelUpDialog extends StatefulWidget {
  const ChatLevelUpDialog({super.key, required this.rewards});

  final int rewards;

  @override
  State<ChatLevelUpDialog> createState() => _ChatLevelUpDialogState();
}

class _ChatLevelUpDialogState extends State<ChatLevelUpDialog> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();

    // 初始化 AnimationController
    _controller = AnimationController(vsync: this);

    // 监听动画状态
    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        // 动画完成时的处理逻辑
        SmartDialog.dismiss();
      }
    });

    Future.delayed(const Duration(milliseconds: 500), () {
      // 显示动画
      _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Lottie.asset(
        'assets/lottie/level_up.json',
        controller: _controller,
        onLoaded: (composition) {
          // 设置动画时长
          _controller.duration = composition.duration;
        },
      ),
    );
  }
}
