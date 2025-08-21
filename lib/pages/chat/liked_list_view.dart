import 'package:fast_ai/component/base_list_view.dart';
import 'package:fast_ai/data/role_data.dart';
import 'package:fast_ai/pages/chat/chat_item.dart';
import 'package:fast_ai/pages/chat/liked_ctr.dart';
import 'package:flutter/material.dart';

class LikedListView extends BaseListView<Role, LikedCtr> {
  // 简化构造函数，只传递必要的controller
  const LikedListView({super.key, required super.controller});

  Widget buildItem(BuildContext context, Role item) {
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
