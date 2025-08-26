import 'package:fast_ai/pages/ai/ai_tab_page.dart';
import 'package:fast_ai/pages/chat/chat_page.dart';
import 'package:fast_ai/pages/home/home_page.dart';
import 'package:fast_ai/pages/me/me_page.dart';
import 'package:fast_ai/pages/mian/main_tab_bar.dart';
import 'package:fast_ai/services/app_cache.dart';
import 'package:fast_ai/services/app_log_event.dart';
import 'package:fast_ai/services/app_service.dart';
import 'package:fast_ai/services/app_user.dart';
import 'package:fast_ai/services/network_service.dart';
import 'package:fast_ai/services/switch_service.dart';
import 'package:fast_ai/tools/audio_tool.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

enum MainTabBarIndex { home, chat, ai, me }

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
        debugPrint('App is in paused state 在后台运行');
        AudioTool().stopAll();
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
      AppUser().getUserInfo();
      await SwitchService.request();
    } catch (e) {
      // 捕获超时异常或其他异常
      log.e('splash Setup error: $e');
    }
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
            body: IndexedStack(
              index: mainTabIndex.index,
              children: [HomePage(), ChatPage(), if (AppCache().isBig) AiTabPage(), MePage()],
            ),
          );
        },
      ),
    );
  }
}
