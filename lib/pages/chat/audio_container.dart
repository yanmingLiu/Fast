import 'package:audioplayers/audioplayers.dart';
import 'package:fast_ai/data/msg_data.dart';
import 'package:fast_ai/gen/assets.gen.dart';
import 'package:fast_ai/generated/locales.g.dart';
import 'package:fast_ai/pages/chat/text_container.dart';
import 'package:fast_ai/pages/router/app_router.dart';
import 'package:fast_ai/services/app_log_event.dart';
import 'package:fast_ai/services/app_user.dart';
import 'package:fast_ai/tools/audio_tool.dart';
import 'package:fast_ai/tools/downloader.dart';
import 'package:fast_ai/values/app_values.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:lottie/lottie.dart';

enum PlayState { downloading, playing, paused, stopped }

class AudioContainer extends StatefulWidget {
  const AudioContainer({super.key, required this.msg});

  final MsgData msg;

  @override
  State<AudioContainer> createState() => _ChatMsgVoiceWidgetState();
}

class _ChatMsgVoiceWidgetState extends State<AudioContainer>
    with SingleTickerProviderStateMixin, AutomaticKeepAliveClientMixin {
  // 返回 true 以保持状态
  @override
  bool get wantKeepAlive => true;

  AnimationController? _controller;

  var playState = PlayState.stopped.obs;

  @override
  void initState() {
    super.initState();

    final msgId = widget.msg.id.toString();

    AudioTool().getCurrentPosition(msgId).then((value) {
      //如果消息未播放完成则恢复动画
      if (value != null) {
        var duration = widget.msg.audioDuration ?? 0;
        var durLast = duration - value.inMilliseconds;
        playState.value = PlayState.playing;
        _startPlayAni(durLast);
      }
    });

    // 初始化 AnimationController
    _controller = AnimationController(vsync: this);
  }

  @override
  void dispose() {
    _stopAudioPlay();
    _controller?.dispose();
    super.dispose();
  }

  // int _getAudioLen(MsgData msg) {
  //   int len = msg.audioDuration ?? 0;
  //   return len.truncate();
  // }

  Widget _getAudioUI(MsgData msg) {
    return ColorFiltered(
      colorFilter: const ColorFilter.mode(
        Colors.white, // 你想要的颜色
        BlendMode.srcIn, // 或者尝试其他混合模式如 modulate, multiply
      ),
      child: Lottie.asset(
        'assets/lottie/audio.json',
        controller: _controller,
        fit: BoxFit.fill,
        onLoaded: (composition) {
          _controller?.duration = composition.duration;
        },
      ),
    );
  }

  void _startAudioPlay(MsgData msg) async {
    playState.value = PlayState.downloading;

    var url = msg.audioUrl ?? '';
    var duration = msg.audioDuration ?? 0;

    final filePath = await Downloader.downloadFile(
      url,
      fileType: FileType.audio,
      fileExtension: ".mp3",
    );
    if (filePath == null || filePath.isEmpty) {
      playState.value = PlayState.stopped;
      return;
    }

    if (mounted) {
      _playAudio(filePath, duration);
    }
  }

  void _playAudio(String path, int duration) async {
    AudioTool()
        .play(widget.msg.id.toString(), DeviceFileSource(path), stopAction: _stopPlayAni)
        .then((value) {
          debugPrint('play audio: $value');
          if (value) {
            _startPlayAni(duration);
          } else {
            playState.value = PlayState.stopped;
          }
        });
  }

  void _stopAudioPlay() {
    AudioTool().stop(widget.msg.id.toString());
    _stopPlayAni();
  }

  void _startPlayAni(int duration) {
    if (playState.value == PlayState.playing) {
      _stopAudioPlay();
      return;
    }
    playState.value = PlayState.playing;

    if (mounted) {
      _controller?.forward(from: 0.0).then((_) {
        _controller?.repeat();
      });
    }
  }

  void _stopPlayAni() {
    if (mounted) {
      _controller?.stop();
    }

    playState.value = PlayState.stopped;
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    var isRead = widget.msg.isRead;
    var isShowTrial = !AppUser().isVip.value;

    return Column(
      children: [
        TextContainer(msg: widget.msg),
        const SizedBox(height: 8),
        Row(children: [_buildAudio(isShowTrial, isRead)]),
      ],
    );
  }

  Widget _buildAudio(bool isShowTrial, bool isRead) {
    return Stack(
      alignment: Alignment.topLeft,
      children: [
        GestureDetector(
          onTap: () {
            if (!AppUser().isVip.value) {
              logEvent('c_news_lockaudio');
              AppRouter.pushVip(VipFrom.lockaudio);
              return;
            }
            if (playState.value == PlayState.paused || playState.value == PlayState.stopped) {
              _startAudioPlay(widget.msg);
            } else {
              _stopAudioPlay();
            }
            if (!isRead) {
              // MsgService.to.markMessageAsRead(widget.msg.id);
            }
          },
          child: Padding(
            padding: const EdgeInsets.only(top: 12),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 200,
                  height: 62,
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: _getAudioUI(widget.msg),
                ),
              ],
            ),
          ),
        ),
        _buildTag(),
      ],
    );
  }

  Container _buildTag() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      alignment: Alignment.centerLeft,
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(16), color: Color(0xFF3F8DFD)),
      child: Row(
        children: [
          Obx(() {
            switch (playState.value) {
              case PlayState.downloading:
                return Center(
                  child: LoadingAnimationWidget.discreteCircle(
                    color: Colors.white,
                    secondRingColor: Colors.white,
                    thirdRingColor: Colors.white,
                    size: 14,
                  ),
                );
              case PlayState.playing:
                return Assets.images.voiceing.image(width: 20);
              default:
                return Assets.images.audioPause.image(width: 20);
            }
          }),
          const SizedBox(width: 8),
          Text(
            LocaleKeys.moans_for_you.tr,
            style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w500, color: Colors.black),
          ),
        ],
      ),
    );
  }
}
