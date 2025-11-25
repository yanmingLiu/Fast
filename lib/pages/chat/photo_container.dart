import 'dart:ui';

import 'package:fast_ai/component/f_image.dart';
import 'package:fast_ai/data/msg_data.dart';
import 'package:fast_ai/pages/chat/text_container.dart';
import 'package:fast_ai/pages/router/n_t_n.dart';
import 'package:fast_ai/services/f_log_event.dart';
import 'package:fast_ai/services/m_y.dart';
import 'package:fast_ai/values/theme_style.dart';
import 'package:fast_ai/values/values.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../gen/assets.gen.dart';
import '../../generated/locales.g.dart';

class PhotoContainer extends StatelessWidget {
  const PhotoContainer({super.key, required this.msg});

  final MsgData msg;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: AlignmentDirectional.centerStart,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextContainer(msg: msg),
          const SizedBox(height: 8),
          if (!msg.typewriterAnimated) _buildImageWidget(context),
        ],
      ),
    );
  }

  Widget _buildImageWidget(BuildContext context) {
    var imageUrl = msg.imgUrl ?? '';
    if (msg.source == MsgType.clothe) {
      imageUrl = msg.giftImg ?? '';
    }
    var isLockImage = msg.mediaLock == LockType.private.value;
    var imageWidth = 200.0;
    var imageHeight = 240.0;

    var imageWidget = ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: FImage(
        url: imageUrl,
        width: imageWidth,
        height: imageHeight,
        borderRadius: BorderRadius.circular(16),
      ),
    );

    return Obx(() {
      var isHide = !MY().isVip.value && isLockImage;
      return isHide
          ? _buildLoackWidge(imageWidth, imageHeight, imageWidget)
          : GestureDetector(
              onTap: () {
                NTN.pushImagePreview(imageUrl);
              },
              child: imageWidget,
            );
    });
  }

  GestureDetector _buildLoackWidge(
      double imageWidth, double imageHeight, Widget imageWidget) {
    return GestureDetector(
      onTap: _onTapUnlock,
      child: Container(
        width: imageWidth,
        height: imageHeight,
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(16)),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          alignment: Alignment.center,
          children: [
            imageWidget,
            ClipRect(
              child: BackdropFilter(
                blendMode: BlendMode.srcIn,
                filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                child: Container(
                  alignment: Alignment.center,
                  height: double.infinity,
                  width: double.infinity,
                  decoration: BoxDecoration(color: Color(0x801C1C1C)),
                ),
              ),
            ),
            _buildContentButton(),
          ],
        ),
      ),
    );
  }

  Column _buildContentButton() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Assets.images.lock.image(width: 32),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Color(0xFF3F8DFD),
                borderRadius: const BorderRadius.all(Radius.circular(30)),
              ),
              child: Row(
                children: [
                  Text(
                    LocaleKeys.hot_photo.tr,
                    style: ThemeStyle.openSans(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  void _onTapUnlock() async {
    logEvent('c_news_lockpic');
    final isVip = MY().isVip.value;
    if (!isVip) {
      NTN.pushVip(ProFrom.lockpic);
    }
  }
}
