import 'package:fast_ai/component/f_dialog.dart';
import 'package:fast_ai/data/a_pop.dart';
import 'package:fast_ai/pages/mian/main_page.dart';
import 'package:fast_ai/pages/router/n_p_n.dart';
import 'package:fast_ai/pages/router/n_t_n.dart';
import 'package:fast_ai/services/f_cache.dart';
import 'package:fast_ai/services/f_log_event.dart';
import 'package:fast_ai/services/f_service.dart';
import 'package:fast_ai/services/m_y.dart';
import 'package:fast_ai/tools/ext.dart';
import 'package:fast_ai/tools/navigation_obs.dart';
import 'package:fast_ai/values/values.dart';
import 'package:get/get.dart';

class HomeCallCtr extends GetxController {
  // 主动来电
  final List<APop> _callList = [];
  APop? _callRole;
  int _callCount = 0;
  int _lastCallTime = 0;
  bool _calling = false;

  void onCall(List<APop>? list) async {
    try {
      if (list == null || list.isEmpty) return;
      _callList.assignAll(list);
      final role = list
          .where((element) =>
              element.gender == 1 && element.renderStyle == 'REALISTIC')
          .toList()
          .randomOrNull;
      if (role == null) {
        return;
      }
      _callRole = role;
      callOut();
    } catch (e) {
      log.e(e.toString());
    }
  }

  Future callOut() async {
    try {
      if (_callRole == null) {
        return;
      }
      final roleId = _callRole?.id;
      if (roleId == null || roleId.isEmpty) {
        return;
      }

      String? url;
      if (_callRole!.videoChat == true) {
        logEvent('t_ai_videocall');
        final guide = _callRole?.characterVideoChat
            ?.firstWhereOrNull((e) => e.tag == 'guide');
        url = guide?.gifUrl;
      } else {
        logEvent('t_ai_audiocall');
        url = _callRole?.avatar;
      }

      if (url == null || url.isEmpty) {
        return;
      }

      await Future.delayed(Duration(seconds: 4));

      if (!canCall() || _calling) {
        return;
      }

      _calling = true;

      _lastCallTime = DateTime.now().millisecondsSinceEpoch;
      _callCount++;

      const sessionId = 0;

      NTN.pushPhone(
        sessionId: sessionId,
        role: _callRole!,
        showVideo: true,
        callState: CallState.incoming,
      );

      final role = _callList
          .where(
            (element) =>
                element.gender == 1 &&
                element.renderStyle == 'REALISTIC' &&
                element.id != _callRole?.id,
          )
          .toList()
          .randomOrNull;
      if (role == null) {
        return;
      }
      _callRole = role;
    } catch (e) {
      log.e(e.toString());
    } finally {
      _calling = false;
    }
  }

  bool canCall() {
    if (!FCache().isBig) {
      log.d('-------->canCall: false isA');
      return false;
    }

    if (mainTabIndex != MainTabBarIndex.home) {
      return false;
    }

    if (NavigationObs().curRoute?.settings.name != NPN.main) {
      log.d('-------->canCall: false curRoute is not root');
      return false;
    }

    if (MY().isVip.value) {
      log.d('-------->canCall: false isVip');
      return false;
    }
    if (_callCount > 2) {
      log.d('-------->canCall:false  _callCount > 2');
      return false;
    }
    if (FDialog.checkExist(loginRewardTag)) {
      log.d('-------->canCall: false  loginRewardTag');
      return false;
    }
    int currentTimestamp = DateTime.now().millisecondsSinceEpoch;
    if (_lastCallTime > 0 && currentTimestamp - _lastCallTime < 2 * 60 * 1000) {
      log.d('-------->canCall: 180s false');
      return false;
    }
    return true;
  }
}
