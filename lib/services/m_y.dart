import 'package:fast_ai/data/a_pop_toy_data.dart';
import 'package:fast_ai/data/accouont.dart';
import 'package:fast_ai/data/gems_config.dart';
import 'package:fast_ai/data/r_clo_data.dart';
import 'package:fast_ai/services/f_api.dart';
import 'package:fast_ai/services/f_cache.dart';
import 'package:fast_ai/values/values.dart';
import 'package:get/get.dart';

import 'f_service.dart';

class MY {
  static MY? _instance;

  factory MY() {
    return _instance ??= MY._internal();
  }

  MY._internal();

  bool _isLoading = false;

  final balance = 0.obs;
  final isVip = false.obs;
  final unreadCount = 0.obs;
  final autoTranslate = false.obs;

  final createImg = 0.obs;
  final createVideo = 0.obs;

  Accouont? _user;

  Accouont? get user => _user;

  /// 各种价格配置
  GemsConfig? priceConfig;

  // 获取玩具 衣服列表
  List<APopToyData> toysConfigs = [];
  List<RCloData> clotheConfigs = [];

  Future<void> register() async {
    try {
      final cacheUser = FCache().user;
      if (cacheUser != null) {
        _user = cacheUser;
        return;
      }
      final user = await FApi.register();
      if (user != null) {
        cacheUserInfo(user);
      }
    } catch (e) {
      log.e('register error: $e');
    }
  }

  Future<void> getUserInfo() async {
    if (_isLoading) {
      return;
    }
    _isLoading = true;
    try {
      final cacheUser = FCache().user;
      if (cacheUser == null) {
        await register();
      }
      final user = await FApi.getUserInfo();
      if (user != null) {
        cacheUserInfo(user);
      }
    } catch (e) {
      log.e('getUserInfo error: $e');
    }
    _isLoading = false;
  }

  Future updateUser(String nickname) async {
    final id = _user?.id;
    if (id == null) {
      return _user;
    }
    try {
      final body = {'id': id, 'nickname': nickname};
      final res = await FApi.updateUserInfo(body);
      if (res) {
        _user?.nickname = nickname;
        cacheUserInfo(_user);
      }
    } catch (e) {
      log.e('updateUser error: $e');
    }
  }

  void cacheUserInfo(Accouont? user) {
    if (user == null) {
      log.e(' cache user is null');
      return;
    }
    _user = user;
    FCache().user = user;
    balance.value = user.gems ?? 0;
    isVip.value =
        (user.subscriptionEnd ?? 0) > DateTime.now().millisecondsSinceEpoch;
    autoTranslate.value = user.autoTranslate ?? false;
    createImg.value = user.createImg;
    createVideo.value = user.createVideo;
  }

  bool isBalanceEnough(GemsFrom from) {
    return balance.value >= from.gems;
  }

  Future<void> consume(GemsFrom from) async {
    try {
      final result = await FApi.consumeReq(from.gems, from.name);
      balance.value = result;
    } catch (e) {
      log.e('$e');
    }
  }

  Future getPriceConfig() async {
    if (priceConfig != null) return;
    var result = await FApi.getPriceConfig();
    if (result == null) return;
    priceConfig = result;
  }

  Future<void> loadToysAndClotheConfigs() async {
    toysConfigs = toysConfigs.isNotEmpty
        ? toysConfigs
        : await FApi.getToysConfigs() ?? [];
    clotheConfigs = clotheConfigs.isNotEmpty
        ? clotheConfigs
        : await FApi.getClotheConfigs() ?? [];
  }
}
