import 'package:easy_refresh/easy_refresh.dart';
import 'package:fast_ai/component/app_dialog.dart';
import 'package:fast_ai/component/f_empty.dart';
import 'package:fast_ai/component/f_loading.dart';
import 'package:fast_ai/data/role_data.dart';
import 'package:fast_ai/generated/locales.g.dart';
import 'package:fast_ai/pages/home/home_call_ctr.dart';
import 'package:fast_ai/pages/home/home_ctr.dart';
import 'package:fast_ai/services/api.dart';
import 'package:fast_ai/services/app_service.dart';
import 'package:fast_ai/services/app_user.dart';
import 'package:fast_ai/values/app_values.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class HomeListController {
  HomeListController() {
    _initState();
  }

  final EasyRefreshController refreshCtr = EasyRefreshController(
    controlFinishRefresh: true,
    controlFinishLoad: true,
  );

  // 添加ScrollController来控制滚动位置
  final ScrollController scrollController = ScrollController();

  String? rendStyl;
  bool? videoChat;
  bool? genVideo;
  bool? genImg;
  bool? changeClothing;
  int page = 1;
  int size = 50;
  var list = <Role>[].obs;

  Rx<EmptyType?> type = Rx<EmptyType?>(null);

  bool isNoMoreData = false;
  bool _isRefreshing = false;
  bool _isLoading = false;

  final HomeCtr ctr = Get.find<HomeCtr>();
  List<int> tagIds = [];

  void _initState() {
    ever(ctr.filterEvent, (event) {
      final tags = event.$1;
      if (ctr.categroy.value == ctr.categroy.value) {
        final ids = tags.map((e) => e.id!).toList();
        tagIds = ids;
        FLoading.showLoading();
        onRefresh();
      }
    });

    ever(ctr.followEvent, (even) {
      try {
        final e = even.$1;
        final id = even.$2;

        final index = list.indexWhere((element) => element.id == id);
        if (index != -1) {
          list[index].collect = e == FollowEvent.follow;
        }
      } catch (e) {}
    });
  }

  Future<void> onRefresh() async {
    if (_isRefreshing) return;
    _isRefreshing = true;

    try {
      page = 1;
      isNoMoreData = false;
      await _fetchData();

      // 刷新后滚动到顶部
      if (scrollController.hasClients) {
        await scrollController.animateTo(
          0,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      }

      await Future.delayed(Duration(milliseconds: 50));
      refreshCtr.finishRefresh();
      refreshCtr.finishLoad(isNoMoreData ? IndicatorResult.noMore : IndicatorResult.none);
    } finally {
      _isRefreshing = false;
    }
  }

  Future<void> onLoad() async {
    if (_isLoading) return;

    if (isNoMoreData) {
      refreshCtr.finishLoad(IndicatorResult.noMore);
      return;
    }

    _isLoading = true;

    try {
      page++;
      await _fetchData();

      await Future.delayed(Duration(milliseconds: 50));
      refreshCtr.finishLoad(isNoMoreData ? IndicatorResult.noMore : IndicatorResult.none);
    } catch (e) {
      page--;
      refreshCtr.finishLoad(IndicatorResult.fail);
    } finally {
      _isLoading = false;
    }
  }

  void onCollect(int index, Role role) async {
    final chatId = role.id;
    if (chatId == null) {
      return;
    }
    if (role.collect == true) {
      final res = await Api.cancelCollectRole(chatId);
      if (res) {
        role.collect = false;
        list.refresh();
      }
    } else {
      final res = await Api.collectRole(chatId);
      if (res) {
        role.collect = true;
        list.refresh();

        if (AppDialog.rateCollectShowd == false) {
          AppDialog.showRateUs(LocaleKeys.rate_us_like.tr);
          AppDialog.rateCollectShowd = true;
        }
      }
    }
  }

  Future<RolePage?> _fetchData() async {
    if (ctr.categroy.value == HomeListCategroy.realistic) {
      rendStyl = HomeListCategroy.realistic.name.toUpperCase();
    } else if (ctr.categroy.value == HomeListCategroy.anime) {
      rendStyl = HomeListCategroy.anime.name.toUpperCase();
    } else if (ctr.categroy.value == HomeListCategroy.video) {
      videoChat = true;
    } else if (ctr.categroy.value == HomeListCategroy.dressUp) {
      changeClothing = true;
    }
    try {
      final res = await Api.homeList(
        page: page,
        size: size,
        rendStyl: rendStyl,
        videoChat: videoChat,
        genImg: genImg,
        genVideo: genVideo,
        tags: tagIds,
        dress: changeClothing,
      );

      final records = res?.records ?? [];
      isNoMoreData = (records.length) < size;

      if (page == 1) {
        list.clear();

        if (AppUser().isVip.value == false) {
          Get.find<HomeCallCtr>().onCall(records);
        }
      }

      type.value = list.isEmpty ? EmptyType.noData : null;
      list.addAll(records);
      return res;
    } catch (e) {
      log.e('Error fetching home data: $e');
      type.value = list.isEmpty ? EmptyType.noData : null;

      return null;
    } finally {
      FLoading.dismiss();
    }
  }

  // 添加dispose方法来释放ScrollController
  void dispose() {
    scrollController.dispose();
  }
}
