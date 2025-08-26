import 'dart:async';
import 'dart:io';

import 'package:fast_ai/component/f_button.dart';
import 'package:fast_ai/component/f_image.dart';
import 'package:fast_ai/component/f_loading.dart';
import 'package:fast_ai/data/role_data.dart';
import 'package:fast_ai/gen/assets.gen.dart';
import 'package:fast_ai/generated/locales.g.dart';
import 'package:fast_ai/pages/chat/phone_page.dart';
import 'package:fast_ai/pages/router/app_router.dart';
import 'package:fast_ai/services/app_log_event.dart';
import 'package:fast_ai/services/app_user.dart';
import 'package:fast_ai/tools/navigation_obs.dart';
import 'package:fast_ai/values/app_values.dart';
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

class _PhoneGuidePageState extends State<PhoneGuidePage> with RouteAware, WidgetsBindingObserver {
  late Role role;

  late VideoPlayerController? _controller;
  late Future<void> _initializeVideoPlayerFuture;

  bool _isPlayed = false;
  StreamSubscription? _phoneStateSub;

  @override
  void initState() {
    super.initState();
    var args = Get.arguments;
    role = args['role'];

    WidgetsBinding.instance.addObserver(this);

    _initVideoPlay();
  }

  void _initVideoPlay() async {
    final guide = role.characterVideoChat?.firstWhereOrNull((e) => e.tag == 'guide');
    var url = guide?.url;

    _controller = VideoPlayerController.networkUrl(Uri.parse(url ?? ''));

    _initializeVideoPlayerFuture = _controller!.initialize().then((_) {
      _controller?.addListener(_videoListener);
      handlePhoneCall();

      Future.delayed(const Duration(seconds: 5), () {
        if (mounted) {
          _controller?.play();
          setState(() {});
        }
      });
      setState(() {});
    });
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
    _phoneStateSub?.cancel();
    _phoneStateSub = null;
    super.dispose();
  }

  @override
  void didPushNext() {
    // 页面被其他页面覆盖时调用
    debugPrint('ChatPage pushed to the background');
    _controller?.pause();
  }

  @override
  void didPopNext() {
    // 页面从其他页面回到前台时调用
    debugPrint('ChatPage resumed from the background');
    _controller?.play();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused || state == AppLifecycleState.inactive) {
      _controller?.pause();
      setState(() {});
    }
    if (state == AppLifecycleState.resumed) {
      _controller?.play();
      setState(() {});
    }
  }

  void _videoListener() {
    if (_controller == null) return;
    if (_controller!.value.isPlaying) {
      setState(() {});
    }

    final position = _controller!.value.position;
    final duration = _controller!.value.duration;
    final timeRemaining = duration - position;

    if (timeRemaining <= const Duration(milliseconds: 500)) {
      _isPlayed = true;
      _controller?.pause();
      setState(() {});
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

  //处理来电话播放器停止播放的操作
  void handlePhoneCall() async {
    if (_phoneStateSub != null) {
      return;
    }
    bool havePermission = true;
    if (Platform.isAndroid) {
      havePermission = await requestPermission() ?? true;
    }
    // if (havePermission) {
    //   _phoneStateSub = PhoneState.stream.listen((event) {
    //     _controller?.pause();
    //   });
    // }
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        body: Stack(
          children: [
            Positioned.fill(child: FImage(url: role.avatar)),
            FutureBuilder(
              future: _initializeVideoPlayerFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.done) {
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
                }
                return Center(child: FLoading.loadingWidget());
              },
            ),
            Positioned.fill(
              child: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Color(0xCC000000),
                      Color(0x001A1A1A),
                      Color(0x001A1A1A),
                      Color(0x801A1A1A),
                      Color(0xCC1A1A1A),
                    ],
                    stops: [0.1, 0.27, 0.43, 0.55, 0.99],
                  ),
                ),
              ),
            ),
            Obx(() {
              final vip = AppUser().isVip.value;
              if (_isPlayed) {
                if (vip) {
                  return _buildButtons();
                }
                return _buildVideoView();
              }
              return _buildWattingView();
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildButtons() {
    List<Widget> buttons = [
      PhoneBtn(icon: Assets.images.hangup.image(), onTap: () => Get.back()),
      PhoneBtn(
        icon: Assets.images.accept.image(),
        animationColor: const Color(0xFF3F8DFD),
        onTap: () {
          if (AppUser().balance.value < ConsumeFrom.call.gems) {
            AppRouter.pushGem(ConsumeFrom.call);
            return;
          }
          AppRouter.offPhone(role: role, showVideo: true);
        },
      ),
    ];

    return Column(
      children: [
        Expanded(child: Container()),
        Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: buttons),
        SizedBox(height: 60),
      ],
    );
  }

  Widget _buildVideoView() {
    return SafeArea(
      child: Column(
        children: [
          Row(
            children: [
              const SizedBox(width: 20),
              IconButton(
                onPressed: () {
                  Get.back();
                },
                icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
              ),
            ],
          ),
          Expanded(child: Container()),
          Text(
            LocaleKeys.activate_benefits.tr,
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w500),
          ),
          SizedBox(height: 16),
          Text(
            LocaleKeys.get_ai_interactive_video_chat.tr,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
          ),
          SizedBox(height: 36),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: FButton(
              onTap: () {
                logEvent('c_unlock_videocall');
                AppRouter.pushVip(VipFrom.call);
              },
              child: Text(LocaleKeys.btn_continue.tr),
            ),
          ),
          SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildWattingView() {
    if (_controller?.value.isPlaying ?? false) {
      return SafeArea(
        child: Column(
          children: [
            Text(
              role.name ?? '',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white, fontSize: 23, fontWeight: FontWeight.w600),
            ),
            SizedBox(height: 16),
            Text(
              LocaleKeys.invites_you_to_video_call.tr,
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600),
            ),
            Expanded(child: Container()),
            PhoneBtn(icon: Assets.images.hangup.image(), onTap: () => Get.back()),
            SizedBox(height: 60),
          ],
        ),
      );
    }
    return SafeArea(
      child: Column(
        children: [
          Text(
            role.name ?? '',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white, fontSize: 23, fontWeight: FontWeight.w600),
          ),
          SizedBox(height: 16),
          Text(
            LocaleKeys.invites_you_to_video_call.tr,
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600),
          ),
          Expanded(child: Container()),
          PhoneBtn(icon: Assets.images.hangup.image(), onTap: () => Get.back()),
          SizedBox(height: 60),
        ],
      ),
    );
  }
}
