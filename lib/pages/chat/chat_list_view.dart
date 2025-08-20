import 'package:fast_ai/data/session_data.dart';
import 'package:fast_ai/component/base_list_view.dart';
import 'package:fast_ai/pages/chat/chat_ctr.dart';
import 'package:fast_ai/pages/chat/chat_item.dart';

class ChatListView extends BaseListView<SessionData, ChatCtr> {
  ChatListView({super.key, required ChatCtr controller})
    : super(
        controller: controller,
        itemBuilder: (context, item) {
          return ChatItem(
            avatar: item.avatar ?? '',
            name: item.title ?? '',
            updateTime: item.updateTime,
            lastMsg: item.lastMessage ?? '-',
            onTap: () => controller.onItemTap(item),
          );
        },
      );
}
