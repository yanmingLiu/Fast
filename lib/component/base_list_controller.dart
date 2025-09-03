import 'package:easy_refresh/easy_refresh.dart';
import 'package:get/get.dart';

import 'f_empty.dart';

abstract class BaseListController<T> extends GetxController {
  var dataList = <T>[].obs;
  int page = 1;
  int size = 100;
  var emptyType = Rx<EmptyType?>(EmptyType.noData);
  bool isNoMoreData = false;
  bool _isRefreshing = false;
  bool _isLoading = false;

  final EasyRefreshController refreshController = EasyRefreshController(
    controlFinishRefresh: true,
    controlFinishLoad: true,
  );

  @override
  void dispose() {
    refreshController.dispose();
    super.dispose();
  }

  Future<void> onRefresh() async {
    if (_isRefreshing) return;
    // 检查控制器是否已被销毁
    try {
      if (isClosed) return;
    } catch (e) {
      // 如果访问isClosed抛出异常，说明控制器可能已被销毁
      return;
    }
    
    _isRefreshing = true;
    try {
      page = 1;
      isNoMoreData = false;
      await fetchData();
      // 再次检查控制器状态
      if (!isClosed) {
        refreshController.finishRefresh();
        refreshController.finishLoad(isNoMoreData ? IndicatorResult.noMore : IndicatorResult.none);
      }
    } finally {
      _isRefreshing = false;
    }
  }

  Future<void> onLoad() async {
    if (_isLoading) return;
    if (isNoMoreData) {
      refreshController.finishLoad(IndicatorResult.noMore);
      return;
    }
    _isLoading = true;
    try {
      page++;
      await fetchData();
      refreshController.finishLoad(isNoMoreData ? IndicatorResult.noMore : IndicatorResult.none);
    } catch (e) {
      page--;
      refreshController.finishLoad(IndicatorResult.fail);
    } finally {
      _isLoading = false;
    }
  }

  Future<void> fetchData();
  Future<void> onItemTap(T item);
}
