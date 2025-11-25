import 'dart:ui';

import 'package:fast_ai/component/f_image.dart';
import 'package:fast_ai/data/msg_data.dart';
import 'package:fast_ai/gen/assets.gen.dart';
import 'package:fast_ai/generated/locales.g.dart';
import 'package:fast_ai/pages/chat/text_container.dart';
import 'package:fast_ai/pages/router/n_t_n.dart';
import 'package:fast_ai/services/f_log_event.dart';
import 'package:fast_ai/services/m_y.dart';
import 'package:fast_ai/values/theme_style.dart';
import 'package:fast_ai/values/values.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class VideoContainer extends StatelessWidget {
  const VideoContainer({super.key, required this.msg});

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
          if (!msg.typewriterAnimated) _buildImageWidget(),
        ],
      ),
    );
  }

  Widget _buildImageWidget() {
    var imageUrl = msg.thumbLink ?? msg.imgUrl ?? '';
    var isLockImage = msg.mediaLock == LockType.private.value;
    var imageWidth = 200.0;
    var imageHeight = 240.0;

    var videoUrl = msg.videoUrl ?? '';

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
          ? _buildCover(imageWidth, imageHeight, imageWidget)
          : _buildVideoButton(videoUrl, imageWidget);
    });
  }

  Widget _buildCover(
      double imageWidth, double imageHeight, Widget imageWidget) {
    return GestureDetector(
      onTap: _onTapUnlock,
      child: Container(
        width: imageWidth,
        height: imageHeight,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: Color(0x801C1C1C),
        ),
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
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              spacing: 12,
              children: [
                Assets.images.player.image(width: 32),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: Color(0xFF3F8DFD),
                        borderRadius:
                            const BorderRadius.all(Radius.circular(30)),
                      ),
                      child: Row(
                        children: [
                          Text(
                            LocaleKeys.hot_video.tr,
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
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVideoButton(String videoUrl, Widget imageWidget) {
    return InkWell(
      onTap: () {
        NTN.pushVideoPreview(videoUrl);
      },
      child: Stack(
        alignment: Alignment.center,
        children: [imageWidget, Assets.images.player.image(width: 32)],
      ),
    );
  }

  void _onTapUnlock() async {
    logEvent('c_news_lockvideo');
    final isVip = MY().isVip.value;
    if (!isVip) {
      NTN.pushVip(ProFrom.lockpic);
    }
  }
}
