import 'dart:ui';

import 'package:fast_ai/component/gradient_text.dart';
import 'package:fast_ai/component/rich_text_placeholder.dart';
import 'package:fast_ai/gen/assets.gen.dart';
import 'package:fast_ai/generated/locales.g.dart';
import 'package:fast_ai/services/app_cache.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

class VipContentWidget extends StatelessWidget {
  final String contentText;

  const VipContentWidget({super.key, required this.contentText});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        _buildTitle(),
        const SizedBox(height: 20),
        _buildContentCard(),
        const SizedBox(height: 26),
      ],
    );
  }

  /// 构建标题
  Widget _buildTitle() {
    if (AppCache().isBig) {
      return _buildBigVersionTitle();
    } else {
      return _buildSmallVersionTitle();
    }
  }

  /// 构建大版本标题
  Widget _buildBigVersionTitle() {
    return Row(
      spacing: 12,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        GradientText(
          textAlign: TextAlign.center,
          data: "50%",
          gradient: const LinearGradient(
            colors: [Color(0xFFF4FCFF), Color(0xFF49AAFF)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            stops: [0.0, 1.0],
          ),
          style: GoogleFonts.openSans(fontSize: 64, fontWeight: FontWeight.w800),
        ),
        Padding(
          padding: const EdgeInsets.only(top: 38),
          child: GradientText(
            textAlign: TextAlign.center,
            data: "OFF",
            gradient: const LinearGradient(
              colors: [Color(0xFFF4FCFF), Color(0xFF49AAFF)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              stops: [0.0, 1.0],
            ),
            style: GoogleFonts.openSans(fontSize: 64, fontWeight: FontWeight.w800),
          ),
        ),
      ],
    );
  }

  /// 构建小版本标题
  Widget _buildSmallVersionTitle() {
    return GradientText(
      data: LocaleKeys.up_to_vip.tr,
      textAlign: TextAlign.center,
      gradient: const LinearGradient(
        colors: [Color(0xFFF4FCFF), Color(0xFF49AAFF)],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        stops: [0.0, 1.0],
      ),
      style: GoogleFonts.openSans(fontSize: 36, fontWeight: FontWeight.w800),
    );
  }

  /// 构建内容卡片
  Widget _buildContentCard() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 16),
          decoration: BoxDecoration(
            color: const Color(0x801C1C1C),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: const Color(0x33FFFFFF), width: 1),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 16,
            children: [if (AppCache().isBig) _buildSubtitle(), _buildContent()],
          ),
        ),
      ),
    );
  }

  /// 构建副标题（仅大版本显示）
  Widget _buildSubtitle() {
    return Text(
      LocaleKeys.best_chat_experience.tr,
      style: GoogleFonts.openSans(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w400),
    );
  }

  /// 构建内容
  Widget _buildContent() {
    return RichTextPlaceholder(
      textKey: contentText,
      placeholders: {
        'icon': WidgetSpan(
          alignment: PlaceholderAlignment.middle,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Assets.images.sure.image(width: 16),
          ),
        ),
      },
      style: GoogleFonts.openSans(
        color: Colors.white,
        fontSize: 12,
        fontWeight: FontWeight.w500,
        height: 1.8,
      ),
    );
  }
}
