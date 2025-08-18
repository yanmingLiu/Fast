import 'package:easy_refresh/easy_refresh.dart';
import 'package:fast_ai/component/app_dialog.dart';
import 'package:fast_ai/component/f_empty.dart';
import 'package:fast_ai/component/f_loading.dart';
import 'package:fast_ai/data/role.dart';
import 'package:fast_ai/generated/locales.g.dart';
import 'package:fast_ai/pages/home/home_call_ctr.dart';
import 'package:fast_ai/pages/home/home_ctr.dart';
import 'package:fast_ai/services/api.dart';
import 'package:fast_ai/services/app_service.dart';
import 'package:fast_ai/services/app_user.dart';
import 'package:fast_ai/services/network_service.dart';
import 'package:fast_ai/values/app_values.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class HomeListView extends StatefulWidget {
  const HomeListView({super.key, required this.cate, this.onTap});

  final HomeListCategroy cate;
  final Function(Role)? onTap;

  @override
  State<HomeListView> createState() => _HomeListViewState();
}

class _HomeListViewState extends State<HomeListView> {
  final EasyRefreshController _controller = EasyRefreshController(
    controlFinishRefresh: true,
    controlFinishLoad: true,
  );

  String? rendStyl;
  bool? videoChat;
  bool? genVideo;
  bool? genImg;
  bool? changeClothing;
  int page = 1;
  int size = 10;
  List<Role> list = [];

  EmptyType? type;
  bool isNoMoreData = false;

  // create
  bool fromCreat = false;
  Role? creatSelectedRole;

  final ctr = Get.find<HomeCtr>();
  List<int> tagIds = [];

  @override
  void initState() {
    super.initState();

    if (widget.cate == HomeListCategroy.realistic) {
      rendStyl = HomeListCategroy.realistic.name.toUpperCase();
    } else if (widget.cate == HomeListCategroy.anime) {
      rendStyl = HomeListCategroy.anime.name.toUpperCase();
    } else if (widget.cate == HomeListCategroy.video) {
      videoChat = true;
    } else if (widget.cate == HomeListCategroy.dressUp) {
      changeClothing = true;
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!NetworkService.to.isConnected.value) {
        return;
      }
      _controller.callRefresh(); // 触发刷新
    });

    ever(ctr.filterEvent, (tags) {
      if (ctr.categroy.value == widget.cate) {
        final ids = tags.map((e) => e.id!).toList();
        setState(() {
          tagIds = ids; // 更新 tagIds 并确保 UI 刷新
        });
        // 在视图渲染完成后调用 refresh
        WidgetsBinding.instance.addPostFrameCallback((_) {
          FLoading.showLoading();
          _onRefresh();
        });
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
        setState(() {});
      } catch (e) {}
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _onRefresh() async {
    page = 1;
    await _fetchData();
    _controller.finishRefresh();
    _controller.resetFooter();
  }

  Future<void> _onLoad() async {
    await _fetchData();
    _controller.finishLoad(isNoMoreData ? IndicatorResult.noMore : IndicatorResult.none);
  }

  void _onCollect(int index, Role role) async {
    final role = list[index];
    final chatId = role.id;
    if (chatId == null) {
      return;
    }
    if (role.collect == true) {
      final res = await Api.cancelCollectRole(chatId);
      if (res) {
        role.collect = false;
        setState(() {});
      }
    } else {
      final res = await Api.collectRole(chatId);
      if (res) {
        role.collect = true;
        setState(() {});

        if (AppDialog.rateCollectShowd == false) {
          AppDialog.showRateUs(LocaleKeys.home_rate_message.tr);
          AppDialog.rateCollectShowd = true;
        }
      }
    }
    // try {
    //   if (Get.isRegistered<ChatFollowController>()) {
    //     Get.find<ChatFollowController>().onRefresh();
    //   }
    // } catch (e) {}
  }

  Future<RolePage?> _fetchData() async {
    try {
      AppUser().getUserInfo();

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
      if (res == null || (res.records?.isEmpty ?? true)) {
        setState(() {
          type = list.isEmpty ? EmptyType.empty : null;
        });
        return null;
      }
      isNoMoreData = (res.records?.length ?? 0) < size;

      if (page == 1) {
        list.clear();
        // 主动来电
        Get.find<HomeCallCtr>().onCall(res.records);
      }

      setState(() {
        type = null;
        list.addAll(res.records!);
        page++;
      });

      return res;
    } catch (e) {
      log.e('Error fetching home data: $e');
      setState(() {
        type = list.isEmpty
            ? (NetworkService().isConnected.value == false
                  ? EmptyType.noNetwork
                  : EmptyType.empty) //
            : type;
      });

      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return EasyRefresh.builder(
      controller: _controller,
      onRefresh: _onRefresh,
      onLoad: _onLoad,
      childBuilder: (context, physics) {
        if (type != null) {
          return FEmpty(type: type!, physics: physics);
        }

        return _buildHomeList(physics);
      },
    );
  }

  Widget _buildHomeList(ScrollPhysics physics) {
    if (list.isEmpty) {
      return FEmpty(type: EmptyType.empty, physics: physics);
    }

    return Text('data');

    // return GridView.builder(
    //   physics: physics,
    //   padding: const EdgeInsets.symmetric(horizontal: 20),
    //   gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
    //     crossAxisCount: 2,
    //     mainAxisSpacing: 8,
    //     crossAxisSpacing: 8,
    //     childAspectRatio: 164.0 / 280.0,
    //   ),
    //   itemBuilder: (BuildContext context, int index) {
    //     return HomeItem(
    //       key: ValueKey(list[ridx].id),
    //       role: list[ridx],
    //       categroy: widget.cate,
    //       onCollect: (role) {
    //         _onCollect(ridx, role);
    //       },
    //     );
    //   },
    //   itemCount: itemCount,
    // );
  }
}
