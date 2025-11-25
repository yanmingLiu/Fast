import 'package:fast_ai/component/f_empty.dart';
import 'package:fast_ai/data/a_pop.dart';
import 'package:fast_ai/pages/router/n_t_n.dart';
import 'package:fast_ai/services/f_api.dart';

import '../../component/f_list_controller.dart';

class LikedCtr extends FListController<APop> {
  @override
  Future<void> fetchData() async {
    try {
      final res = await FApi.likedList(page, size);
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
  Future<void> onItemTap(APop session) async {
    NTN.pushChat(session.id);
  }
}
