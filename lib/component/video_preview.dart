import 'dart:async';
import 'dart:io';

import 'package:fast_ai/component/f_loading.dart';
import 'package:fast_ai/tools/downloader.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:video_player/video_player.dart';

extension IntExt on int {
  String formatTimeMMSS() {
    int minutes = this ~/ 60;
    int seconds = this % 60;
    String mm = minutes.toString().padLeft(2, '0');
    String ss = seconds.toString().padLeft(2, '0');
    return '$mm:$ss';
  }
}

class VideoPreview extends StatefulWidget {
  const VideoPreview({super.key});

  @override
  State<VideoPreview> createState() => _VideoPreviewState();
}

class _VideoPreviewState extends State<VideoPreview> with WidgetsBindingObserver {
  late VideoPlayerController _controller;

  bool _progressShow = true;
  Timer? _timer;
  bool _isError = false;
  bool _isInit = false;
  bool _isPlaying = true;
  StreamSubscription? _phoneStateSub;

  late String url;

  // 添加下滑关闭所需的状态变量
  double _dragDistance = 0.0;
  double _opacity = 1.0;
  static const double _dragThreshold = 150.0; // 下滑多少距离后关闭

  void _playProgressAutoHide() {
    _timer?.cancel();
    if (_progressShow) {
      _timer = Timer(const Duration(seconds: 3), () {
        if (_progressShow) {
          setState(() {
            _progressShow = false;
          });
        }
      });
    }
  }

  // 处理垂直拖动
  void _handleVerticalDrag(DragUpdateDetails details) {
    // 只允许向下拖动
    if (details.delta.dy > 0) {
      setState(() {
        _dragDistance += details.delta.dy;
        // 计算不透明度，随着拖动距离增加而降低
        _opacity = 1.0 - (_dragDistance / _dragThreshold).clamp(0.0, 0.6);
      });
    }
  }

  // 处理拖动结束
  void _handleDragEnd(DragEndDetails details) {
    if (_dragDistance > _dragThreshold) {
      // 超过阈值，关闭页面
      Get.back();
    } else {
      // 未超过阈值，恢复原状
      setState(() {
        _dragDistance = 0.0;
        _opacity = 1.0;
      });
    }
  }

  @override
  void initState() async {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    url = Get.arguments;

    if (url.startsWith('http://') || url.startsWith('https://')) {
      FLoading.showLoading();
      final path = await Downloader.downloadFile(url, fileType: FileType.video);
      FLoading.dismiss();
      if (path != null) {
        _controller = VideoPlayerController.file(File(url));
      } else {
        _controller = VideoPlayerController.networkUrl(Uri.parse(url));
      }
    } else {
      _controller = VideoPlayerController.file(File(url));
    }

    _controller.addListener(() {
      var isPlaying = _controller.value.isPlaying;
      var position = _controller.value.position;
      var duration = _controller.value.duration;
      if (!isPlaying && position == duration) {
        _controller.seekTo(const Duration());
        _isPlaying = false;
      } else {
        // _handlePhoneCall();
      }

      setState(() {});
    });
    _controller.setLooping(false);
    _controller
        .initialize()
        .then((_) {
          _isInit = true;
          if (mounted) {
            _isPlaying = true;
            _controller.play();
            setState(() {});
          }
        })
        .catchError((e) {
          _isError = true;
          if (mounted) {
            setState(() {});
          }
        });
    _playProgressAutoHide();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // 添加 inactive 状态判断避免来电等状态
    if ((AppLifecycleState.paused == state || AppLifecycleState.inactive == state) && _isPlaying) {
      _isPlaying = false;
      _controller.pause();
      setState(() {});
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _controller.dispose();
    _timer?.cancel();
    _phoneStateSub?.cancel();
    _phoneStateSub = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      // 添加垂直拖动手势
      onVerticalDragUpdate: _handleVerticalDrag,
      onVerticalDragEnd: _handleDragEnd,
      child: Scaffold(
        backgroundColor: Colors.black,
        extendBody: true,
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          leading: IconButton(
            onPressed: () => Get.back(),
            icon: const Icon(Icons.close, color: Colors.white),
          ),
        ),
        body: Transform.translate(
          offset: Offset(0, _dragDistance),
          child: Opacity(
            opacity: _opacity,
            child: Stack(
              children: [
                Center(
                  child: _isError
                      ? const Icon(Icons.error, color: Colors.white)
                      : _isInit
                      ? GestureDetector(
                          onTap: () {
                            setState(() {
                              _progressShow = !_progressShow;
                              _playProgressAutoHide();
                            });
                          },
                          child: AspectRatio(
                            aspectRatio: _controller.value.aspectRatio,
                            child: VideoPlayer(_controller),
                          ),
                        )
                      : const CupertinoActivityIndicator(radius: 16.0, color: Colors.white),
                ),
                Visibility(
                  visible: _isInit && !_isPlaying,
                  child: GestureDetector(
                    onTap: () {
                      _isPlaying = true;
                      _controller.play();
                    },
                    child: Center(child: Icon(Icons.play_circle, color: Colors.white, size: 80)),
                  ),
                ),
                Positioned(
                  left: 20,
                  right: 20,
                  bottom: 75,
                  child: Visibility(
                    visible: _isInit && _progressShow,
                    child: Row(
                      children: [
                        GestureDetector(
                          onTap: () {
                            if (_isPlaying) {
                              _isPlaying = false;
                              _controller.pause();
                            } else {
                              _isPlaying = true;
                              _controller.play();
                            }
                          },
                          child: Icon(
                            _isPlaying ? Icons.pause_circle : Icons.play_circle,
                            color: Colors.white,
                            size: 26,
                          ),
                        ),
                        const SizedBox(width: 20),
                        Text(
                          _controller.value.position.inSeconds.formatTimeMMSS(),
                          style: const TextStyle(color: Colors.white, fontSize: 12),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: SizedBox(
                            height: 2,
                            child: VideoProgressIndicator(
                              _controller,
                              colors: const VideoProgressColors(
                                playedColor: Colors.white,
                                backgroundColor: Color(0x4d000000),
                              ),
                              padding: EdgeInsets.zero,
                              allowScrubbing: false,
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Text(
                          _controller.value.duration.inSeconds.formatTimeMMSS(),
                          style: const TextStyle(color: Colors.white, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                ),
                // 下滑指示器
                if (_dragDistance > 0)
                  Positioned(
                    top: 80,
                    left: 0,
                    right: 0,
                    child: Center(
                      child: Text(
                        'Swipe down to close',
                        style: TextStyle(color: Colors.white.withValues(alpha: 0.8), fontSize: 14),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
