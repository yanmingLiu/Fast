import 'package:fast_ai/component/f_list_view.dart';
import 'package:fast_ai/data/a_pop.dart';
import 'package:fast_ai/pages/chat/chat_item.dart';
import 'package:fast_ai/pages/chat/liked_ctr.dart';
import 'package:flutter/material.dart';

class LikedListView extends FListView<APop, LikedCtr> {
  // 简化构造函数，只传递必要的controller
  const LikedListView({super.key, required super.controller});

  Widget buildItem(BuildContext context, APop item) {
    // 将itemBuilder逻辑移到重写方法中
    return ChatItem(
      avatar: item.avatar ?? '',
      name: item.name ?? '',
      updateTime: item.updateTime,
      lastMsg: item.lastMessage ?? '-',
      onTap: () => controller.onItemTap(item),
    );
  }

  @override
  Widget buildList(BuildContext context, ScrollPhysics physics) {
    return ListView.separated(
      physics: physics,
      padding: padding ?? const EdgeInsets.symmetric(vertical: 14),
      cacheExtent: cacheExtent,
      itemBuilder: (_, index) => buildItem(context, controller.dataList[index]),
      separatorBuilder: (_, index) => const SizedBox(height: 16),
      itemCount: controller.dataList.length,
    );
  }
}
