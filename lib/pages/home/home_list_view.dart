import 'package:easy_refresh/easy_refresh.dart';
import 'package:fast_ai/component/f_empty.dart';
import 'package:fast_ai/data/role_data.dart';
import 'package:fast_ai/pages/home/home_ctr.dart';
import 'package:fast_ai/pages/home/home_item.dart';
import 'package:fast_ai/pages/home/home_list_controller.dart';
import 'package:fast_ai/services/network_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:get/get.dart';

class HomeListView extends StatefulWidget {
  const HomeListView({super.key, required this.cate, this.onTap});

  final HomeListCategroy cate;
  final Function(Role)? onTap;

  @override
  State<HomeListView> createState() => _HomeListViewState();
}

class _HomeListViewState extends State<HomeListView> {
  late final HomeListController _controller;

  @override
  void initState() {
    super.initState();
    _controller = HomeListController();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!NetworkService.to.isConnected.value) {
        return;
      }
      _controller.refreshCtr.callRefresh();
    });
  }

  @override
  void dispose() {
    _controller.refreshCtr.dispose();
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
          if (_controller.type.value != null) {
            return FEmpty(type: _controller.type.value!, physics: physics);
          }
          return _buildList(physics, _controller.list);
        });
      },
    );
  }

  Widget _buildList(ScrollPhysics physics, List<Role> list) {
    return MasonryGridView.count(
      crossAxisCount: 2,
      mainAxisSpacing: 8,
      crossAxisSpacing: 8,
      itemCount: list.length,
      physics: physics,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemBuilder: (context, index) {
        final role = list[index];
        return SizedBox(
          height: index.isOdd ? 300 : 250,
          child: HomeItem(
            role: role,
            onCollect: (Role role) {
              _controller.onCollect(index, role);
            },
            cate: widget.cate,
          ),
        );
      },
    );
  }
}
