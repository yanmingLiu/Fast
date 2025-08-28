import 'dart:ui';

import 'package:fast_ai/data/msg_data.dart';
import 'package:fast_ai/generated/locales.g.dart';
import 'package:fast_ai/pages/chat/audio_container.dart';
import 'package:fast_ai/pages/chat/msg_ctr.dart';
import 'package:fast_ai/pages/chat/photo_container.dart';
import 'package:fast_ai/pages/chat/text_container.dart';
import 'package:fast_ai/pages/chat/toys_container.dart';
import 'package:fast_ai/pages/chat/video_container.dart';
import 'package:fast_ai/values/app_values.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

class MsgCell extends StatefulWidget {
  const MsgCell({super.key, required this.msg});

  final MsgData msg;

  @override
  State<MsgCell> createState() => _MsgCellState();
}

class _MsgCellState extends State<MsgCell> {
  MsgSource get source => widget.msg.source;
  Color bgColor = Color(0x801C1C1C);
  final borderRadius = BorderRadius.circular(16);

  final ctr = Get.find<MsgCtr>();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    switch (source) {
      case MsgSource.tips:
        return tipsContent();
      case MsgSource.welcome:
        return TextContainer(msg: widget.msg);
      case MsgSource.scenario:
        return TextContainer(msg: widget.msg, title: "${LocaleKeys.scenario.tr}:");
      case MsgSource.intro:
        return TextContainer(msg: widget.msg, title: "${LocaleKeys.intro.tr}:");
      case MsgSource.sendText:
        return TextContainer(msg: widget.msg);
      case MsgSource.text:
      case MsgSource.maskTips:
      case MsgSource.error:
        return TextContainer(msg: widget.msg);
      case MsgSource.photo:
      case MsgSource.clothe:
        return PhotoContainer(msg: widget.msg);
      case MsgSource.video:
        return VideoContainer(msg: widget.msg);
      case MsgSource.audio:
        return AudioContainer(msg: widget.msg);
      case MsgSource.gift:
        return ToysContainer(msg: widget.msg);

      default:
        return Container();
    }
  }

  Widget tipsContent() {
    return Center(
      child: ClipRRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            decoration: BoxDecoration(color: bgColor, borderRadius: borderRadius),
            child: Text(
              LocaleKeys.msg_tips.tr,
              style: GoogleFonts.openSans(
                color: Colors.white,
                fontSize: 10,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
