import 'package:fast_ai/component/f_keep_alive.dart';
import 'package:fast_ai/pages/chat/chat_page.dart';
import 'package:fast_ai/pages/home/home_page.dart';
import 'package:fast_ai/pages/me/me_page.dart';
import 'package:fast_ai/pages/mian/main_tab_bar.dart';
import 'package:fast_ai/services/audio_manager.dart';
import 'package:fast_ai/services/f_cache.dart';
import 'package:fast_ai/services/f_log_event.dart';
import 'package:fast_ai/services/f_service.dart';
import 'package:fast_ai/services/f_switch_service.dart';
import 'package:fast_ai/services/m_y.dart';
import 'package:fast_ai/services/net_o_b_s.dart';
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

  late List<Widget> pages = <Widget>[];

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
        FLogEvent().logSessionEvent();
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

    if (NetOBS.to.isConnected.value) {
      _setupFuture = setup();
    } else {
      _setupFuture = Future.value();
      ever(NetOBS.to.isConnected, (v) {
        if (v) {
          setState(() {
            _setupFuture = setup();
          });
        }
      });
    }
  }

  Future<void> setup() async {
    try {
      _initializeAsyncServices();

      await MY().getUserInfo();
      if (FCache().isBig == false) {
        await FSwitchService.request();
      }
    } catch (e) {
      // 捕获超时异常或其他异常
      log.e('splash Setup error: $e');
    }

    pages = [
      FKeepAlive(child: HomePage()),
      FKeepAlive(child: ChatPage()),
      // if (AppCache().isBig) AiTabPage(),
      FKeepAlive(child: MePage()),
    ];
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
    MY().getUserInfo();
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
              children: pages,
            ),
          );
        },
      ),
    );
  }
}
