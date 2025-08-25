import 'package:fast_ai/data/clothing_data.dart';
import 'package:fast_ai/data/price_config.dart';
import 'package:fast_ai/data/toys_data.dart';
import 'package:fast_ai/data/user.dart';
import 'package:fast_ai/services/api.dart';
import 'package:fast_ai/services/app_cache.dart';
import 'package:fast_ai/values/app_values.dart';
import 'package:get/get.dart';

import 'app_service.dart';

class AppUser {
  static AppUser? _instance;

  factory AppUser() {
    return _instance ??= AppUser._internal();
  }

  AppUser._internal();

  final balance = 0.obs;
  final isVip = false.obs;
  final unreadCount = 0.obs;
  final autoTranslate = false.obs;

  final createImg = 0.obs;
  final createVideo = 0.obs;

  User? _user;

  User? get user => _user;

  /// 各种价格配置
  PriceConfig? priceConfig;

  // 获取玩具 衣服列表
  List<ToysData> toysConfigs = [];
  List<ClothingData> clotheConfigs = [];

  Future<void> register() async {
    try {
      final cacheUser = AppCache().user;
      if (cacheUser != null) {
        _user = cacheUser;
        return;
      }
      final user = await Api.register();
      if (user != null) {
        cacheUserInfo(user);
      }
    } catch (e) {
      log.e('register error: $e');
    }
  }

  Future<void> getUserInfo() async {
    try {
      final cacheUser = AppCache().user;
      if (cacheUser == null) {
        await register();
      }
      final user = await Api.getUserInfo();
      if (user != null) {
        cacheUserInfo(user);
      }
    } catch (e) {
      log.e('getUserInfo error: $e');
    }
  }

  Future updateUser(String nickname) async {
    final id = _user?.id;
    if (id == null) {
      return _user;
    }
    try {
      final body = {'id': id, 'nickname': nickname};
      final res = await Api.updateUserInfo(body);
      if (res) {
        _user?.nickname = nickname;
        cacheUserInfo(_user);
      }
    } catch (e) {
      log.e('updateUser error: $e');
    }
  }

  void cacheUserInfo(User? user) {
    if (user == null) {
      log.e(' cache user is null');
      return;
    }
    _user = user;
    AppCache().user = user;
    balance.value = user.gems ?? 0;
    isVip.value = (user.subscriptionEnd ?? 0) > DateTime.now().millisecondsSinceEpoch;
    autoTranslate.value = user.autoTranslate ?? false;
    createImg.value = user.createImg;
    createVideo.value = user.createVideo;
  }

  bool isBalanceEnough(ConsumeFrom from) {
    return balance.value >= from.gems;
  }

  Future<void> consume(ConsumeFrom from) async {
    try {
      final result = await Api.consumeReq(from.gems, from.name);
      balance.value = result;
    } catch (e) {
      log.e('$e');
    }
  }

  Future getPriceConfig() async {
    if (priceConfig != null) return;
    var result = await Api.getPriceConfig();
    if (result == null) return;
    priceConfig = result;
  }

  Future<void> loadToysAndClotheConfigs() async {
    toysConfigs = toysConfigs.isNotEmpty ? toysConfigs : await Api.getToysConfigs() ?? [];
    clotheConfigs = clotheConfigs.isNotEmpty ? clotheConfigs : await Api.getClotheConfigs() ?? [];
  }
}
