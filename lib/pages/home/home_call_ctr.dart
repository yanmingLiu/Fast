import 'package:fast_ai/component/app_dialog.dart';
import 'package:fast_ai/data/role_data.dart';
import 'package:fast_ai/pages/home/home_ctr.dart';
import 'package:fast_ai/pages/mian/main_page.dart';
import 'package:fast_ai/pages/router/app_router.dart';
import 'package:fast_ai/pages/router/routers.dart';
import 'package:fast_ai/services/app_cache.dart';
import 'package:fast_ai/services/app_log_event.dart';
import 'package:fast_ai/services/app_service.dart';
import 'package:fast_ai/services/app_user.dart';
import 'package:fast_ai/tools/ext.dart';
import 'package:fast_ai/tools/navigation_obs.dart';
import 'package:fast_ai/values/app_values.dart';
import 'package:get/get.dart';

class HomeCallCtr extends GetxController {
  // 主动来电
  final List<Role> _callList = [];
  Role? _callRole;
  int _callCount = 0;
  int _lastCallTime = 0;
  bool _calling = false;

  void onCall(List<Role>? list) async {
    try {
      if (list == null || list.isEmpty) return;
      _callList.assignAll(list);
      final role = list
          .where((element) => element.gender == 1 && element.renderStyle == 'REALISTIC')
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
      if (!canCall() || _calling) {
        return;
      }
      if (_callRole == null) {
        return;
      }

      String? url;
      if (_callRole!.videoChat == true) {
        logEvent('t_ai_videocall');
        final guide = _callRole?.characterVideoChat?.firstWhereOrNull((e) => e.tag == 'guide');
        url = guide?.gifUrl;
      } else {
        logEvent('t_ai_audiocall');
        url = _callRole?.avatar;
      }

      if (url == null || url.isEmpty) {
        return;
      }
      _calling = true;

      await Future.delayed(const Duration(seconds: 6));

      if (!canCall() || _calling) {
        return;
      }

      final roleId = _callRole?.id;
      if (roleId == null || roleId.isEmpty) {
        return;
      }

      _lastCallTime = DateTime.now().millisecondsSinceEpoch;
      _callCount++;

      const sessionId = 0;

      if (!canCall()) {
        return;
      }

      AppRouter.pushPhone(
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
    if (!AppCache().isBig) {
      log.d('-------->canCall: false isA');
      return false;
    }

    if (mainTabIndex != MainTabBarIndex.home) {
      return false;
    }

    if (NavigationObs().curRoute?.settings.name != Routers.main) {
      log.d('-------->canCall: false curRoute is not root');
      return false;
    }

    if (Get.find<HomeCtr>().categroy.value != HomeListCategroy.all) {
      return false;
    }

    if (AppUser().isVip.value) {
      log.d('-------->canCall: false isVip');
      return false;
    }
    if (_callCount > 2) {
      log.d('-------->canCall:false  _callCount > 2');
      return false;
    }
    if (AppDialog.checkExist('DialogTag.sigin.name')) {
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
