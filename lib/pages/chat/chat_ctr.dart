import 'package:fast_ai/component/f_empty.dart';
import 'package:fast_ai/data/session_data.dart';
import 'package:fast_ai/pages/router/app_router.dart';
import 'package:fast_ai/services/api.dart';

import '../../component/base_list_controller.dart';

enum ChatTab { chatted, liked }

class ChatCtr extends BaseListController<SessionData> {
  @override
  Future<void> fetchData() async {
    try {
      final res = await Api.sessionList(page, size);
      final newRecords = res?.records ?? [];
      isNoMoreData = newRecords.length < size;
      if (page == 1) dataList.clear();
      dataList.addAll(newRecords);
      emptyType.value = dataList.isEmpty ? EmptyType.noData : null;
    } catch (e) {
      emptyType.value = dataList.isEmpty ? EmptyType.noData : null;
      if (page > 1) page--;
      rethrow;
    }
  }

  @override
  Future<void> onItemTap(SessionData session) async {
    AppRouter.pushChat(session.characterId);
  }
}
