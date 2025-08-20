import 'package:fast_ai/data/role.dart';
import 'package:fast_ai/component/base_list_view.dart';
import 'package:fast_ai/pages/chat/chat_item.dart';
import 'package:fast_ai/pages/chat/liked_ctr.dart';

class LikedListView extends BaseListView<Role, LikedCtr> {
  LikedListView({super.key, required LikedCtr controller})
    : super(
        controller: controller,
        itemBuilder: (context, item) {
          return ChatItem(
            avatar: item.avatar ?? '',
            name: item.name ?? '',
            updateTime: item.updateTime,
            lastMsg: item.lastMessage ?? '-',
            onTap: () => controller.onItemTap(item),
          );
        },
      );
}
