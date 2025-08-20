import 'package:easy_refresh/easy_refresh.dart';
import 'package:fast_ai/component/f_empty.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'base_list_controller.dart';

abstract class BaseListView<T, C extends BaseListController<T>> extends StatelessWidget {
  const BaseListView({
    super.key,
    required this.itemBuilder,
    this.separatorBuilder,
    this.emptyBuilder,
    this.enablePullRefresh = true,
    this.enableLoadMore = true,
    this.padding,
    this.cacheExtent,
    required this.controller,
    this.listBuilder,
  });

  final Widget Function(BuildContext context, T item) itemBuilder;
  final Widget Function(BuildContext context, int index)? separatorBuilder;
  final Widget Function(BuildContext context)? emptyBuilder;
  final bool enablePullRefresh;
  final bool enableLoadMore;
  final EdgeInsets? padding;
  final double? cacheExtent;

  final BaseListController<T> controller;
  final Widget Function(BuildContext context, ScrollPhysics physics)? listBuilder;

  @override
  Widget build(BuildContext context) {
    return EasyRefresh.builder(
      controller: controller.refreshController,
      onRefresh: enablePullRefresh ? controller.onRefresh : null,
      onLoad: enableLoadMore ? controller.onLoad : null,
      childBuilder: (context, physics) {
        return Obx(() {
          if (controller.emptyType.value != null || controller.dataList.isEmpty) {
            return emptyBuilder?.call(context) ??
                FEmpty(type: controller.emptyType.value!, physics: physics);
          }
          if (listBuilder != null) {
            return listBuilder!(context, physics);
          }
          return ListView.separated(
            physics: physics,
            padding: padding ?? const EdgeInsets.symmetric(vertical: 14),
            cacheExtent: cacheExtent,
            itemBuilder: (_, index) => itemBuilder(context, controller.dataList[index]),
            separatorBuilder: separatorBuilder ?? (_, index) => const SizedBox(height: 16),
            itemCount: controller.dataList.length,
          );
        });
      },
    );
  }
}
