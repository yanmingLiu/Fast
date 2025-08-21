import 'package:fast_ai/component/f_empty.dart';
import 'package:fast_ai/data/role_data.dart';
import 'package:fast_ai/services/api.dart';
import 'package:fast_ai/tools/app_router.dart';

import '../../component/base_list_controller.dart';

class LikedCtr extends BaseListController<Role> {
  @override
  Future<void> fetchData() async {
    try {
      final res = await Api.likedList(page, size);
      final newRecords = res?.records ?? [];
      isNoMoreData = newRecords.length < size;
      if (page == 1) dataList.clear();
      dataList.addAll(newRecords);
      emptyType.value = dataList.isEmpty ? EmptyType.empty : null;
    } catch (e) {
      emptyType.value = dataList.isEmpty ? EmptyType.empty : null;
      if (page > 1) page--;
      rethrow;
    }
  }

  @override
  Future<void> onItemTap(Role session) async {
    AppRouter.pushChat(session.id);
  }
}
