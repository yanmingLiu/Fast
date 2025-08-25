import 'package:fast_ai/component/f_button.dart';
import 'package:fast_ai/component/f_icon.dart';
import 'package:fast_ai/component/f_image.dart';
import 'package:fast_ai/data/msg_data.dart';
import 'package:fast_ai/gen/assets.gen.dart';
import 'package:fast_ai/pages/chat/msg_ctr.dart';
import 'package:fast_ai/services/app_user.dart';
import 'package:fast_ai/tools/app_router.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

class ToysContainer extends StatefulWidget {
  const ToysContainer({super.key, required this.msg});

  final MsgData msg;

  @override
  State<ToysContainer> createState() => _ToysContainerState();
}

class _ToysContainerState extends State<ToysContainer> {
  MsgCtr ctr = Get.find<MsgCtr>();

  Color bgColor = Color(0x801C1C1C);
  final borderRadius = BorderRadius.circular(16);

  @override
  Widget build(BuildContext context) {
    final msg = widget.msg;
    final question = widget.msg.question ?? '';

    var showTranslate = msg.showTranslate == true;
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
      children: [
        _buildQuestion(question),
        const SizedBox(height: 16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: 4,
          children: [_buildAnser(showTranslate), _buildTransBtn(showTransBtn, showTranslate)],
        ),
      ],
    );
  }

  Widget _buildTransBtn(bool showTransBtn, bool showTranslate) {
    return showTransBtn
        ? FButton(
            onTap: () => ctr.translateMsg(widget.msg),
            width: 24,
            height: 24,
            child: FIcon(
              assetName: Assets.svg.trans,
              width: 24,
              color: showTranslate ? Color(0xFF3F8DFD) : Colors.white,
            ),
          )
        : SizedBox();
  }

  Widget _buildAnser(bool showTranslate) {
    final msg = widget.msg;

    final translate = msg.translateAnswer ?? '';
    final content = msg.answer ?? '';

    return Container(
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(color: bgColor, borderRadius: borderRadius),
      constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            showTranslate ? translate : content,
            style: GoogleFonts.openSans(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w400,
            ),
          ),
          const SizedBox(height: 2),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: InkWell(
              onTap: () {
                AppRouter.pushImagePreview(widget.msg.giftImg ?? '');
              },
              child: Container(
                width: 40,
                height: 52,
                color: Colors.white,
                child: FImage(url: widget.msg.giftImg),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuestion(String question) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Container(
          decoration: const BoxDecoration(
            color: Color(0xFF3F8DFD),
            borderRadius: BorderRadius.all(Radius.circular(8)),
          ),
          padding: const EdgeInsets.all(12),
          width: 164,
          child: Column(
            spacing: 8,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: InkWell(
                  onTap: () {
                    AppRouter.pushImagePreview(widget.msg.giftImg ?? '');
                  },
                  child: Container(
                    height: 186,
                    color: Colors.white,
                    child: FImage(url: widget.msg.giftImg),
                  ),
                ),
              ),
              Text(
                question,
                style: GoogleFonts.openSans(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
