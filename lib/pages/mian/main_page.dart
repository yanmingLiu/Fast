import 'package:fast_ai/pages/chat/chat_page.dart';
import 'package:fast_ai/pages/home/home_page.dart';
import 'package:fast_ai/pages/me/me_page.dart';
import 'package:fast_ai/pages/mian/main_tab_bar.dart';
import 'package:fast_ai/services/app_cache.dart';
import 'package:fast_ai/services/app_log_event.dart';
import 'package:fast_ai/services/app_service.dart';
import 'package:fast_ai/services/app_user.dart';
import 'package:fast_ai/services/audio_manager.dart';
import 'package:fast_ai/services/network_service.dart';
import 'package:fast_ai/services/switch_service.dart';
import 'package:fast_ai/tools/fb_sdk_tool.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_lazy_indexed_stack/flutter_lazy_indexed_stack.dart';
import 'package:get/get.dart';

enum MainTabBarIndex {
  home,
  chat,
  // ai,
  me,
}

MainTabBarIndex mainTabIndex = MainTabBarIndex.home;

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> with WidgetsBindingObserver {
  late Future<void> _setupFuture;

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    switch (state) {
      case AppLifecycleState.paused:
        log.d('App is in paused state 在后台运行');
        AudioManager.instance.stopAll();
        break;
      case AppLifecycleState.resumed:
        log.d('App is in resumed state 在前台运行');
        break;
      default:
        break;
    }
  }

  @override
  void initState() {
    super.initState();

    // 注册监听器
    WidgetsBinding.instance.addObserver(this);

    if (NetworkService.to.isConnected.value) {
      _setupFuture = setup();
    } else {
      _setupFuture = Future.value();
      ever(NetworkService.to.isConnected, (v) {
        if (v) {
          setState(() {
            _setupFuture = setup();
          });
        }
      });
    }
  }

  Future<void> setup() async {
    final isFirstLaunch = AppCache().isRestart == false;
    if (isFirstLaunch) {
      AppLogEvent().logInstallEvent();
    }

    AppLogEvent().logSessionEvent();

    try {
      _initializeAsyncServices();

      AppUser().getUserInfo();
      await SwitchService.request();
    } catch (e) {
      // 捕获超时异常或其他异常
      log.e('splash Setup error: $e');
    }
  }

  void _initializeAsyncServices() {
    // 异步初始化Facebook SDK
    FBSDKTool.initializeWithRemoteConfig().catchError((error) {
      log.e('Facebook SDK初始化失败: $error');
    });
  }

  @override
  void dispose() {
    // 移除监听器
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  void _onTapItem(MainTabBarIndex index) {
    setState(() {
      mainTabIndex = index;
    });
    AppUser().getUserInfo();
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion(
      value: SystemUiOverlayStyle.light,
      child: FutureBuilder(
        future: _setupFuture,
        builder: (context, asyncSnapshot) {
          if (asyncSnapshot.connectionState == ConnectionState.waiting) {
            return SizedBox();
          }
          return Scaffold(
            extendBody: true,
            bottomNavigationBar: MainTabBar(onTapItem: (p0) => _onTapItem(p0)),
            backgroundColor: Colors.black,
            body: LazyIndexedStack(
              index: mainTabIndex.index,
              children: [
                HomePage(),
                ChatPage(),
                // if (AppCache().isBig) AiTabPage(),
                MePage(),
              ],
            ),
          );
        },
      ),
    );
  }
}
