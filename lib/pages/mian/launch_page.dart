import 'dart:async';

import 'package:easy_refresh/easy_refresh.dart';
import 'package:fast_ai/component/f_progress.dart';
import 'package:fast_ai/gen/assets.gen.dart';
import 'package:fast_ai/pages/router/routers.dart';
import 'package:fast_ai/services/f_service.dart';
import 'package:fast_ai/services/f_switch_service.dart';
import 'package:fast_ai/services/m_y.dart';
import 'package:fast_ai/services/net_o_b_s.dart';
import 'package:fast_ai/tools/iap_tool.dart';
import 'package:flutter/material.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:get/get.dart';

class LaunchPage extends StatefulWidget {
  const LaunchPage({super.key});

  @override
  State<LaunchPage> createState() => _LaunchPageState();
}

class _LaunchPageState extends State<LaunchPage>
    with SingleTickerProviderStateMixin {
  double _progressValue = 0.0;
  Timer? _progressTimer;
  bool _isProgressComplete = false;

  @override
  void initState() {
    super.initState();

    initUI();

    if (NetOBS.to.isConnected.value) {
      setup();
    } else {
      ever(NetOBS.to.isConnected, (v) {
        setup();
      });
    }
  }

  @override
  void dispose() {
    _progressTimer?.cancel();
    super.dispose();
  }

  void initUI() {
    EasyRefresh.defaultHeaderBuilder =
        () => const MaterialHeader(color: Color(0xFF3F8DFD));
    EasyRefresh.defaultFooterBuilder = () => const ClassicFooter(
          showText: false,
          showMessage: false,
          iconTheme: IconThemeData(color: Color(0xFF3F8DFD)),
        );
    SmartDialog.config.toast = SmartConfigToast(alignment: Alignment.center);
  }

  Future<void> setup() async {
    try {
      await FService().getIdfa();

      // 启动进度条动画
      _startProgressAnimation();

      await Future.wait([
        FSwitchService.request(isFisrt: true),
        MY().register(),
        IAPTool().query(),
      ]).timeout(Duration(seconds: 7));

      _completeSetup();
    } catch (e) {
      log.d('Splash setup error: $e');
      _completeSetup();
    }
  }

  void _startProgressAnimation() {
    _progressTimer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
      if (!mounted) return;
      setState(() {
        if (_progressValue < 0.5) {
          _progressValue += 0.02;
        } else if (_progressValue < 0.9) {
          _progressValue += 0.01;
        } else if (!_isProgressComplete) {
          _progressValue += 0.001;
        }
      });
    });
  }

  void _completeSetup() {
    if (!mounted) return;
    setState(() {
      _progressValue = 1.0;
      _isProgressComplete = true;
    });
    _progressTimer?.cancel();
    _navigateToMain();
  }

  Future<void> _navigateToMain() async {
    if (!mounted) return;
    Get.offAllNamed(Routers.main);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF3F8DFD),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 150),
            Center(child: Assets.images.launchLogo.image(width: 120)),
            Spacer(),
            Text(
              'Fast Ai',
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 32,
                  fontWeight: FontWeight.w700),
            ),
            Text(
              'Effortless teamwork in an advanced AI realm',
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 20),
            FProgress(
              progress: _progressValue,
              width: 250,
              height: 4,
              backgroundColor: Color(0x80FFFFFF),
              progressColor: Colors.white,
              borderRadius: 4,
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }
}
