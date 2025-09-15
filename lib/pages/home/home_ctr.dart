import 'package:extended_image/extended_image.dart';
import 'package:fast_ai/component/app_dialog.dart';
import 'package:fast_ai/component/f_keep_alive.dart';
import 'package:fast_ai/component/f_loading.dart';
import 'package:fast_ai/data/role_data.dart';
import 'package:fast_ai/data/role_tags.dart';
import 'package:fast_ai/generated/locales.g.dart';
import 'package:fast_ai/pages/home/home_list_view.dart';
import 'package:fast_ai/pages/router/app_router.dart';
import 'package:fast_ai/pages/router/routers.dart';
import 'package:fast_ai/services/api.dart';
import 'package:fast_ai/services/app_cache.dart';
import 'package:fast_ai/services/app_log_event.dart';
import 'package:fast_ai/services/app_service.dart';
import 'package:fast_ai/services/app_user.dart';
import 'package:fast_ai/services/network_service.dart';
import 'package:fast_ai/services/switch_service.dart';
import 'package:fast_ai/values/app_values.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

enum HomeListCategroy { all, realistic, anime, dressUp, video }

// 为枚举添加扩展，提供title和icon等属性
extension HomeListCategoryExtension on HomeListCategroy {
  String get title {
    switch (this) {
      case HomeListCategroy.all:
        return LocaleKeys.popular.tr;
      case HomeListCategroy.realistic:
        return LocaleKeys.realistic.tr;
      case HomeListCategroy.anime:
        return LocaleKeys.anime.tr;
      case HomeListCategroy.dressUp:
        return LocaleKeys.dress_up.tr;
      case HomeListCategroy.video:
        return LocaleKeys.video.tr;
    }
  }

  int get index => HomeListCategroy.values.indexOf(this);
}

class HomeCtr extends GetxController {
  var categroyList = <HomeListCategroy>[];
  var categroy = HomeListCategroy.all.obs;

  var pages = <Widget>[];

  // 标签
  List<RoleTagRes> roleTags = [];
  var selectTags = <RoleTag>{}.obs;
  Rx<(Set<RoleTag>, int)> filterEvent = (<RoleTag>{}, 0).obs;

  // 关注
  Rx<(FollowEvent, String, int)> followEvent = (FollowEvent.follow, '', 0).obs;

  @override
  void onInit() {
    super.onInit();

    if (NetworkService.to.isConnected.value) {
      setupAndJump();
    } else {
      ever(NetworkService.to.isConnected, (v) {
        if (v) {
          setupAndJump();
        }
      });
    }
  }

  void onTapCate(HomeListCategroy value) {
    categroy.value = value;
  }

  void onTapFilter() {
    Get.toNamed(Routers.homeFilter);
  }

  Future<void> setupAndJump() async {
    FLoading.showLoading();
    await setup();
    FLoading.dismiss();
    jump();
  }

  Future<void> setup() async {
    try {
      await Future.wait([SwitchService.request(), AppUser().getUserInfo()]).timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          return [];
        },
      );
      await AppService().getIdfa();

      categroyList.addAll([
        HomeListCategroy.all,
        HomeListCategroy.realistic,
        HomeListCategroy.anime,
        if (AppCache().isBig) HomeListCategroy.video,
        if (AppCache().isBig) HomeListCategroy.dressUp,
      ]);

      // 使用智能缓存策略，只保活当前页面和相邻页面
      pages = categroyList.map((element) {
        return KeepAliveWrapper(child: HomeListView(cate: element));
      }).toList();

      Api.updateEventParams();
      loadTags();
    } catch (e) {
      log.e('All tasks failed with error: $e');
    }

    update();
  }

  Future loadTags() async {
    final tags = await Api.roleTagsList();
    if (tags != null) {
      roleTags.assignAll(tags);
    }
  }

  void jump() {
    if (AppCache().isBig) {
      jumpForB();
    } else {
      jumpForA();
    }
  }

  void jumpForA() {
    recordInstallTime();
    AppCache().isRestart = true;
  }

  void jumpForB() async {
    final isShowDailyReward = await shouldShowDailyReward();
    final isVip = AppUser().isVip.value;
    final isFirstLaunch = AppCache().isRestart == false;
    if (isFirstLaunch) {
      // 记录安装时间
      recordInstallTime();
      // 记录为重启
      AppCache().isRestart = true;

      // 首次启动 获取指定人物聊天
      FLoading.showLoading();
      final startRole = await getSplashRole();
      FLoading.dismiss();
      if (startRole != null) {
        final roleId = startRole.id;
        AppRouter.pushChat(roleId, showLoading: false);
      } else {
        jumpVip(isFirstLaunch);
      }
    } else {
      // 非首次启动 判断弹出奖励弹窗
      if (isShowDailyReward) {
        // 更新奖励时间戳
        AppCache().lastRewardDate = DateTime.now().millisecondsSinceEpoch;
        AppDialog.showLoginReward();
      } else {
        // 非vip用户 跳转订阅页
        if (!isVip) {
          jumpVip(isFirstLaunch);
        }
      }
    }
  }

  Future<void> recordInstallTime() async {
    AppCache().installTime = DateTime.now().millisecondsSinceEpoch;
  }

  Future<bool> shouldShowDailyReward() async {
    final installTimeMillis = AppCache().lastRewardDate;
    if (installTimeMillis <= 0) {
      // 记录安装时间
      recordInstallTime();
      return false; // 没有记录安装时间，不处理
    }

    final installTime = DateTime.fromMillisecondsSinceEpoch(installTimeMillis);
    final now = DateTime.now();

    // 安装后第一天不弹窗，只有从第二天开始才弹窗
    final isAfterSecondDay = now.year > installTime.year ||
        (now.year == installTime.year && now.month > installTime.month) ||
        (now.year == installTime.year &&
            now.month == installTime.month &&
            now.day > installTime.day);

    if (!isAfterSecondDay) {
      return false;
    }

    // 检查今天是否已经发过奖励（避免重复弹窗）
    final lastRewardDateMillis = AppCache().lastRewardDate;
    if (lastRewardDateMillis > 0) {
      final lastRewardDate = DateTime.fromMillisecondsSinceEpoch(lastRewardDateMillis);

      // 如果今天已经发过奖励，则不弹窗
      if (now.year == lastRewardDate.year &&
          now.month == lastRewardDate.month &&
          now.day == lastRewardDate.day) {
        return false;
      }
    }

    return true; // 可以发奖励
  }

  // 获取开屏随机角色
  Future<Role?> getSplashRole() async {
    AppUser().getUserInfo();
    final role = await Api.splashRandomRole();
    final avatar = role?.avatar;
    if (avatar != null && avatar.isNotEmpty) {
      ExtendedNetworkImageProvider(
        avatar,
        cache: true,
        cacheMaxAge: const Duration(days: 7),
        retries: 3,
      );
    }
    return role;
  }

  void jumpVip(bool isFirstLaunch) async {
    AppRouter.pushVip(AppCache().isRestart ? VipFrom.relaunch : VipFrom.launch);

    var event = AppCache().isBig ? 't_vipb' : 't_vipa';

    if (AppCache().isRestart) {
      event = '${event}_relaunch';
    } else {
      event = '${event}_launch';
      AppCache().isRestart = true;
    }
    logEvent(event);
  }
}
