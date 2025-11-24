import 'dart:async';
import 'dart:io';

import 'package:fast_ai/component/f_button.dart';
import 'package:fast_ai/component/f_icon.dart';
import 'package:fast_ai/component/f_image.dart';
import 'package:fast_ai/component/f_loading.dart';
import 'package:fast_ai/component/f_toast.dart';
import 'package:fast_ai/data/a_pop.dart';
import 'package:fast_ai/gen/assets.gen.dart';
import 'package:fast_ai/generated/locales.g.dart';
import 'package:fast_ai/pages/chat/phone_page.dart';
import 'package:fast_ai/pages/router/app_router.dart';
import 'package:fast_ai/services/f_log_event.dart';
import 'package:fast_ai/services/m_y.dart';
import 'package:fast_ai/tools/downloader.dart';
import 'package:fast_ai/tools/navigation_obs.dart';
import 'package:fast_ai/values/theme_colors.dart';
import 'package:fast_ai/values/values.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:video_player/video_player.dart';

class PhoneGuidePage extends StatefulWidget {
  const PhoneGuidePage({super.key});

  @override
  State<PhoneGuidePage> createState() => _PhoneGuidePageState();
}

enum PlayState { init, playing, finish }

class _PhoneGuidePageState extends State<PhoneGuidePage>
    with RouteAware, WidgetsBindingObserver {
  late APop role;

  VideoPlayerController? _controller;
  Future<void>? _initializeVideoPlayerFuture;

  var playState = PlayState.init.obs;
  bool _hasCalledPhoneAccept = false; // 添加标志位防止重复调用

  @override
  void initState() {
    super.initState();
    var args = Get.arguments;
    role = args['role'];

    WidgetsBinding.instance.addObserver(this);

    _initVideoPlay();
  }

  void _initVideoPlay() {
    // 创建一个包含下载和初始化的完整Future
    _initializeVideoPlayerFuture = _downloadAndInitVideo();
    _hasCalledPhoneAccept = false; // 重置标志位
  }

  Future<void> _downloadAndInitVideo() async {
    try {
      final guide =
          role.characterVideoChat?.firstWhereOrNull((e) => e.tag == 'guide');
      var url = guide?.url;
      if (url == null) {
        throw Exception('Video URL not found');
      }

      final path = await Downloader.downloadFile(url, fileType: FileType.video);
      if (path == null) {
        throw Exception('Video download failed');
      }

      _controller = VideoPlayerController.file(File(path));

      await _controller!.initialize().then((_) {
        _controller?.addListener(_videoListener);
        _delayedPlay();
      });
    } catch (e) {
      if (mounted) {
        FToast.toast(LocaleKeys.some_error_try_again.tr);
        Get.back();
      }
    }
  }

  Future _delayedPlay() async {
    // 延迟5秒后开始播放
    await Future.delayed(const Duration(seconds: 5));

    if (mounted) {
      _controller?.play();
      playState.value = PlayState.playing;
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    /// 路由订阅
    NavigationObs().observer.subscribe(this, ModalRoute.of(context)!);
  }

  @override
  void dispose() {
    /// 取消路由订阅
    NavigationObs().observer.unsubscribe(this);
    WidgetsBinding.instance.removeObserver(this);

    _controller?.removeListener(_videoListener);
    _controller?.dispose();
    super.dispose();
  }

  @override
  void didPushNext() {
    // 页面被其他页面覆盖时调用
    debugPrint('didPushNext');
    _controller?.pause();
  }

  @override
  void didPopNext() {
    // 页面从其他页面回到前台时调用
    debugPrint('didPopNext');
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive) {
      _controller?.pause();
      setState(() {});
    }
    // if (state == AppLifecycleState.resumed) {
    //   _controller?.play();
    //   setState(() {});
    // }
  }

  void _videoListener() {
    if (_controller == null) return;

    final position = _controller!.value.position;
    final duration = _controller!.value.duration;
    final timeRemaining = duration - position;

    if (timeRemaining <= const Duration(milliseconds: 500)) {
      _controller?.pause();
      playState.value = PlayState.finish;

      if (MY().isVip.value && !_hasCalledPhoneAccept) {
        _hasCalledPhoneAccept = true; // 设置标志位防止重复调用
        _phoneAccept();
      }
    }
  }

  //监听权限
  Future<bool?> requestPermission() async {
    var status = await Permission.phone.request();

    switch (status) {
      case PermissionStatus.denied:
      case PermissionStatus.restricted:
      case PermissionStatus.limited:
      case PermissionStatus.permanentlyDenied:
        return false;
      case PermissionStatus.granted:
        return true;
      default:
        return true;
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(body: _buildBody()),
    );
  }

  Widget _buildBody() {
    final width = MediaQuery.of(context).size.width - 32;
    final height = MediaQuery.of(context).size.height -
        32 -
        MediaQuery.of(context).padding.top -
        MediaQuery.of(context).padding.bottom;

    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF0B192D), Color(0x1C103D00)],
        ),
      ),
      child: SafeArea(
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Container(
            width: width,
            height: height,
            color: Colors.black,
            child: Stack(
              children: [
                Positioned.fill(
                  child:
                      FImage(url: role.avatar, width: height, height: height),
                ),
                FutureBuilder(
                  future: _initializeVideoPlayerFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.done &&
                        _controller != null) {
                      return Positioned.fill(
                        child: FittedBox(
                          fit: BoxFit.cover,
                          child: SizedBox(
                            width: _controller?.value.size.width,
                            height: _controller?.value.size.height,
                            child: VideoPlayer(_controller!),
                          ),
                        ),
                      );
                    } else {
                      // 在加载时显示进度指示器
                      return Center(child: FLoading.loadingWidget());
                    }
                  },
                ),
                Positioned(
                  top: 0,
                  right: 0,
                  left: 0,
                  child: Obx(() {
                    if (playState.value == PlayState.playing) {
                      return SizedBox.shrink();
                    }
                    return _buldName();
                  }),
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  left: 0,
                  child: Obx(() {
                    final vip = MY().isVip.value;

                    switch (playState.value) {
                      case PlayState.init:
                      case PlayState.playing:
                        return _playingView();

                      case PlayState.finish:
                        return vip ? _playingView() : _playedView();
                    }
                  }),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Container _buldName() {
    return Container(
      height: 80,
      color: Color(0x80000000),
      padding: EdgeInsets.all(16),
      child: Row(
        spacing: 8,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          FImage(
              url: role.avatar,
              width: 48,
              height: 48,
              borderRadius: BorderRadius.circular(24)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  role.name ?? '',
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w700),
                ),
                if (role.age != null)
                  Text(
                    LocaleKeys.age_years_olds
                        .trParams({'age': role.age.toString()}),
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                      color: Color(0xffC9C9C9),
                    ),
                  ),
              ],
            ),
          ),
          FButton(
            width: 48,
            height: 48,
            onTap: () => Get.back(),
            child: Center(child: FIcon(assetName: Assets.svg.close)),
          ),
        ],
      ),
    );
  }

  void _phoneAccept() async {
    final vip = MY().isVip.value;
    if (vip) {
      if (MY().balance.value < GemsFrom.call.gems) {
        AppRouter.pushGem(GemsFrom.call);
        return;
      }
      AppRouter.offPhone(role: role, showVideo: true);
    } else {
      _pushVip();
    }
  }

  void _pushVip() {
    logEvent('c_unlock_videocall');
    AppRouter.pushVip(ProFrom.call);
  }

  Widget _playingView() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      spacing: 8,
      children: [
        Text(
          LocaleKeys.invites_you_to_video_call.tr,
          textAlign: TextAlign.center,
          style: TextStyle(
              color: Colors.white, fontSize: 16, fontWeight: FontWeight.w400),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            PhoneBtn(
                icon: Assets.images.hangup.image(), onTap: () => Get.back()),
            if (playState.value == PlayState.finish)
              PhoneBtn(icon: Assets.images.accept.image(), onTap: _phoneAccept),
          ],
        ),
        SizedBox(height: 32),
      ],
    );
  }

  Widget _playedView() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Colors.transparent, Color(0xff0B192D)],
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            LocaleKeys.activate_benefits.tr,
            textAlign: TextAlign.center,
            style: TextStyle(
                color: Colors.white, fontSize: 16, fontWeight: FontWeight.w700),
          ),
          SizedBox(height: 8),
          Text(
            LocaleKeys.get_ai_interactive_video_chat.tr,
            textAlign: TextAlign.center,
            style: TextStyle(
                fontSize: 12, fontWeight: FontWeight.w400, color: Colors.white),
          ),
          SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: FButton(
              color: ThemeColors.primary,
              onTap: _pushVip,
              hasShadow: true,
              margin: EdgeInsets.symmetric(horizontal: 40),
              child: Center(
                child: Text(
                  LocaleKeys.btn_continue.tr,
                  style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 16),
                ),
              ),
            ),
          ),
          SizedBox(height: 24),
        ],
      ),
    );
  }
}
