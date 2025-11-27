import 'package:extended_image/extended_image.dart';
import 'package:fast_ai/component/f_dialog.dart';
import 'package:fast_ai/component/f_keep_alive.dart';
import 'package:fast_ai/component/f_loading.dart';
import 'package:fast_ai/data/a_pop.dart';
import 'package:fast_ai/data/a_pop_tags.dart';
import 'package:fast_ai/generated/locales.g.dart';
import 'package:fast_ai/pages/home/home_list_view.dart';
import 'package:fast_ai/pages/router/n_p_n.dart';
import 'package:fast_ai/pages/router/n_t_n.dart';
import 'package:fast_ai/services/f_api.dart';
import 'package:fast_ai/services/f_cache.dart';
import 'package:fast_ai/services/f_log_event.dart';
import 'package:fast_ai/services/f_service.dart';
import 'package:fast_ai/services/m_y.dart';
import 'package:fast_ai/services/net_o_b_s.dart';
import 'package:fast_ai/values/values.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

enum HomeCate { all, realistic, anime, dressUp, video }

// 为枚举添加扩展，提供title和icon等属性
extension HomeListCategoryExtension on HomeCate {
  String get title {
    switch (this) {
      case HomeCate.all:
        return LocaleKeys.popular.tr;
      case HomeCate.realistic:
        return LocaleKeys.realistic.tr;
      case HomeCate.anime:
        return LocaleKeys.anime.tr;
      case HomeCate.dressUp:
        return LocaleKeys.dress_up.tr;
      case HomeCate.video:
        return LocaleKeys.video.tr;
    }
  }

  int get index => HomeCate.values.indexOf(this);
}

class HomeCtr extends GetxController {
  var categroyList = <HomeCate>[];
  var categroy = HomeCate.all.obs;

  var pages = <Widget>[];

  // 标签
  List<APopTagRes> roleTags = [];
  var selectTags = <APopTag>{}.obs;
  Rx<(Set<APopTag>, int)> filterEvent = (<APopTag>{}, 0).obs;

  // 关注
  Rx<(FollowEvent, String, int)> followEvent = (FollowEvent.follow, '', 0).obs;

  @override
  void onInit() {
    super.onInit();

    if (NetOBS.to.isConnected.value) {
      setupAndJump();
    } else {
      ever(NetOBS.to.isConnected, (v) {
        if (v) {
          setupAndJump();
        }
      });
    }
  }

  void onTapCate(HomeCate value) {
    categroy.value = value;
  }

  void onTapFilter() {
    Get.toNamed(NPN.homeFilter);
  }

  Future<void> setupAndJump() async {
    FLoading.showLoading();
    await setup();
    FLoading.dismiss();
    jump();
  }

  Future<void> setup() async {
    try {
      categroyList.addAll([
        HomeCate.all,
        HomeCate.realistic,
        HomeCate.anime,
        if (FCache().isBig) HomeCate.video,
        if (FCache().isBig) HomeCate.dressUp,
      ]);

      // 使用智能缓存策略，只保活当前页面和相邻页面
      pages = categroyList.map((element) {
        return FKeepAlive(child: HomeListView(cate: element));
      }).toList();

      FApi.updateEventParams();
      loadTags();
    } catch (e) {
      log.e('All tasks failed with error: $e');
    }

    update();
  }

  Future loadTags() async {
    final tags = await FApi.roleTagsList();
    if (tags != null) {
      roleTags.assignAll(tags);
    }
  }

  void jump() {
    if (FCache().isBig) {
      jumpForB();
    } else {
      jumpForA();
    }
  }

  void jumpForA() {
    recordInstallTime();
    FCache().isRestart = true;
  }

  void jumpForB() async {
    final isShowDailyReward = await shouldShowDailyReward();
    final isVip = MY().isVip.value;
    final isFirstLaunch = FCache().isRestart == false;
    if (isFirstLaunch) {
      // 记录安装时间
      recordInstallTime();
      // 记录为重启
      FCache().isRestart = true;

      // 首次启动 获取指定人物聊天
      FLoading.showLoading();
      final startRole = await getSplashRole();
      FLoading.dismiss();
      if (startRole != null) {
        final roleId = startRole.id;
        NTN.pushChat(roleId, showLoading: false);
      } else {
        jumpVip(isFirstLaunch);
      }
    } else {
      // 非首次启动 判断弹出奖励弹窗
      if (isShowDailyReward) {
        // 更新奖励时间戳
        FCache().lastRewardDate = DateTime.now().millisecondsSinceEpoch;
        FDialog.showLoginReward();
      } else {
        // 非vip用户 跳转订阅页
        if (!isVip) {
          jumpVip(isFirstLaunch);
        }
      }
    }
  }

  Future<void> recordInstallTime() async {
    FCache().installTime = DateTime.now().millisecondsSinceEpoch;
  }

  Future<bool> shouldShowDailyReward() async {
    final installTimeMillis = FCache().lastRewardDate;
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
    final lastRewardDateMillis = FCache().lastRewardDate;
    if (lastRewardDateMillis > 0) {
      final lastRewardDate =
          DateTime.fromMillisecondsSinceEpoch(lastRewardDateMillis);

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
  Future<APop?> getSplashRole() async {
    MY().getUserInfo();
    final role = await FApi.splashRandomRole();
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
    NTN.pushVip(FCache().isRestart ? ProFrom.relaunch : ProFrom.launch);

    var event = FCache().isBig ? 't_vipb' : 't_vipa';

    if (FCache().isRestart) {
      event = '${event}_relaunch';
    } else {
      event = '${event}_launch';
      FCache().isRestart = true;
    }
    logEvent(event);
  }
}
