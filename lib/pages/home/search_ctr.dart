import 'package:fast_ai/component/app_dialog.dart';
import 'package:fast_ai/component/f_empty.dart';
import 'package:fast_ai/component/f_loading.dart';
import 'package:fast_ai/data/role_data.dart';
import 'package:fast_ai/generated/locales.g.dart';
import 'package:fast_ai/pages/chat/liked_ctr.dart';
import 'package:fast_ai/pages/home/home_ctr.dart';
import 'package:fast_ai/services/api.dart';
import 'package:fast_ai/services/app_service.dart';
import 'package:fast_ai/values/app_values.dart';
import 'package:get/get.dart';

class SearchCtr extends GetxController {
  // 常量定义
  static const int _defaultPage = 1;
  static const int _defaultSize = 1000;
  static const Duration _debounceDelay = Duration(milliseconds: 500);

  // 分页参数
  int page = _defaultPage;
  int size = _defaultSize;

  // 响应式状态
  final list = <Role>[].obs;
  final type = Rx<EmptyType?>(EmptyType.noData);
  final searchQuery = ''.obs;
  final currentRequestId = 0.obs;
  final isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    _setupSearchDebounce();
  }

  /// 设置搜索防抖
  void _setupSearchDebounce() {
    debounce(searchQuery, (_) {
      final requestId = _generateRequestId();
      currentRequestId.value = requestId;
      search(searchQuery.value, requestId);
    }, time: _debounceDelay);
  }

  /// 生成唯一请求ID
  int _generateRequestId() => DateTime.now().millisecondsSinceEpoch;

  /// 搜索角色
  Future<void> search(String searchText, int requestId) async {
    try {
      if (searchText.trim().isEmpty) {
        _clearSearchResults();
        return;
      }

      _setLoadingState();
      final res = await Api.homeList(page: page, size: size, name: searchText.trim());

      // 检查请求是否已过期
      if (!_isRequestValid(requestId)) {
        return;
      }

      _updateSearchResults(res?.records ?? []);
    } catch (e, stackTrace) {
      log.e('搜索请求失败', error: e, stackTrace: stackTrace);
      _handleSearchError();
    }
  }

  /// 清空搜索结果
  void _clearSearchResults() {
    list.clear();
    type.value = EmptyType.noData;
  }

  /// 设置加载状态
  void _setLoadingState() {
    type.value = EmptyType.loading;
  }

  /// 检查请求是否有效
  bool _isRequestValid(int requestId) => requestId == currentRequestId.value;

  /// 更新搜索结果
  void _updateSearchResults(List<Role> records) {
    if (page == _defaultPage) {
      list.clear();
    }

    list.addAll(records);
    type.value = list.isEmpty ? EmptyType.noData : null;
  }

  /// 处理搜索错误
  void _handleSearchError() {
    type.value = list.isEmpty ? EmptyType.noData : null;
  }

  /// 处理收藏/取消收藏操作
  Future<void> onCollect(int index, Role role) async {
    final targetRole = list[index];
    final chatId = targetRole.id;

    if (chatId == null) {
      log.w('角色ID为空 无法执行收藏操作');
      return;
    }

    final chatIdStr = chatId.toString();
    final isCurrentlyCollected = targetRole.collect == true;

    try {
      FLoading.showLoading();

      final success = isCurrentlyCollected
          ? await Api.cancelCollectRole(chatIdStr)
          : await Api.collectRole(chatIdStr);

      if (success) {
        _updateCollectionState(targetRole, !isCurrentlyCollected, chatIdStr);

        if (!isCurrentlyCollected) {
          _showRateDialogIfNeeded();
        }
      }
    } catch (e, stackTrace) {
      log.e('收藏操作失败', error: e, stackTrace: stackTrace);
    } finally {
      FLoading.dismiss();
    }
  }

  /// 更新收藏状态
  void _updateCollectionState(Role role, bool isCollected, String chatId) {
    role.collect = isCollected;
    list.refresh();

    _notifyFollowEvent(isCollected, chatId);
    _refreshLikedController();
  }

  /// 通知关注事件
  void _notifyFollowEvent(bool isCollected, String chatId) {
    try {
      final followEvent = isCollected ? FollowEvent.follow : FollowEvent.unfollow;
      Get.find<HomeCtr>().followEvent.value = (
        followEvent,
        chatId,
        DateTime.now().millisecondsSinceEpoch,
      );
    } catch (e, stackTrace) {
      log.e('通知关注事件失败', error: e, stackTrace: stackTrace);
    }
  }

  /// 刷新收藏控制器
  void _refreshLikedController() {
    try {
      if (Get.isRegistered<LikedCtr>()) {
        Get.find<LikedCtr>().onRefresh();
      }
    } catch (e, stackTrace) {
      log.e('刷新收藏列表失败', error: e, stackTrace: stackTrace);
    }
  }

  /// 显示评分对话框（如果需要）
  void _showRateDialogIfNeeded() {
    if (!AppDialog.rateCollectShowd) {
      AppDialog.showRateUs(LocaleKeys.rate_us_like.tr);
      AppDialog.rateCollectShowd = true;
    }
  }
}
