import 'package:easy_refresh/easy_refresh.dart';
import 'package:fast_ai/component/f_empty.dart';
import 'package:fast_ai/data/a_pop.dart';
import 'package:fast_ai/pages/home/home_ctr.dart';
import 'package:fast_ai/pages/home/home_item.dart';
import 'package:fast_ai/pages/home/home_list_controller.dart';
import 'package:fast_ai/services/net_o_b_s.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:get/get.dart';

class HomeListView extends StatefulWidget {
  const HomeListView({super.key, required this.cate, this.onTap});

  final HomeCate cate;
  final Function(APop)? onTap;

  @override
  State<HomeListView> createState() => _HomeListViewState();
}

class _HomeListViewState extends State<HomeListView> {
  late final HomeListController _controller;

  @override
  void initState() {
    super.initState();
    _controller = HomeListController(widget.cate);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!NetOBS.to.isConnected.value) {
        return;
      }
      _controller.refreshCtr.callRefresh();
    });
  }

  @override
  void dispose() {
    // 确保控制器被正确销毁
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return EasyRefresh.builder(
      controller: _controller.refreshCtr,
      onRefresh: _controller.onRefresh,
      onLoad: _controller.onLoad,
      childBuilder: (context, physics) {
        return Obx(() {
          final type = _controller.type.value;
          final list = _controller.list;
          if (type != null && list.isEmpty) {
            return FEmpty(type: _controller.type.value!, physics: physics);
          }
          return _buildList(physics, _controller.list);
        });
      },
    );
  }

  Widget _buildList(ScrollPhysics physics, List<APop> list) {
    final width = MediaQuery.sizeOf(context).width / 2 - 16;

    return MasonryGridView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      gridDelegate: const SliverSimpleGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2),
      mainAxisSpacing: 8,
      crossAxisSpacing: 8,
      itemCount: list.length,
      physics: physics,
      addAutomaticKeepAlives: false,
      addRepaintBoundaries: false,
      itemBuilder: (context, index) {
        final height = index.isOdd ? 300.0 : 250.0;
        final role = list[index];
        return HomeItem(
          width: width,
          height: height,
          role: role,
          onCollect: (APop role) {
            _controller.onCollect(index, role);
          },
          cate: widget.cate,
        );
      },
    );
  }
}
