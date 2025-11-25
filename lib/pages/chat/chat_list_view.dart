import 'package:fast_ai/component/f_list_view.dart';
import 'package:fast_ai/data/session_data.dart';
import 'package:fast_ai/pages/chat/chat_ctr.dart';
import 'package:fast_ai/pages/chat/chat_item.dart';
import 'package:flutter/material.dart';

class ChatListView extends FListView<SessionData, ChatCtr> {
  const ChatListView({super.key, required super.controller});

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

  Widget buildItem(BuildContext context, SessionData item) {
    return ChatItem(
      avatar: item.avatar ?? '',
      name: item.title ?? '',
      updateTime: item.updateTime,
      lastMsg: item.lastMessage ?? '-',
      onTap: () => controller.onItemTap(item),
    );
  }
}
