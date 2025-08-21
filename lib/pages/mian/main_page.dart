import 'package:fast_ai/pages/chat/chat_page.dart';
import 'package:fast_ai/pages/ai/ai_tab_page.dart';
import 'package:fast_ai/pages/home/home_page.dart';
import 'package:fast_ai/pages/me/me_page.dart';
import 'package:fast_ai/pages/mian/main_tab_bar.dart';
import 'package:fast_ai/services/app_cache.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

enum MainTabBarIndex { home, chat, ai, me }

MainTabBarIndex mainTabIndex = MainTabBarIndex.home;

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> with WidgetsBindingObserver {
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    switch (state) {
      case AppLifecycleState.paused:
        debugPrint('App is in paused state 在后台运行');
        // AudioPlayerUtil.instance.stopAll();
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

    // if (NetUtil.to.isConnected.value) {
    //   _setupFuture = setup();
    // } else {
    //   _setupFuture = Future.value();
    //   ever(NetUtil.to.isConnected, (v) {
    //     if (v) {
    //       setState(() {
    //         _setupFuture = setup();
    //       });
    //     }
    //   });
    // }
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
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        extendBody: true,
        bottomNavigationBar: MainTabBar(onTapItem: (p0) => _onTapItem(p0)),
        backgroundColor: Colors.black,
        body: IndexedStack(
          index: mainTabIndex.index,
          children: [HomePage(), ChatPage(), if (AppCache().isBig) AiTabPage(), MePage()],
        ),
      ),
    );
  }
}
