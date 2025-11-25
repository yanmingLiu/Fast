import 'dart:io';

import 'package:android_id/android_id.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:fast_ai/data/accouont.dart';
import 'package:fast_ai/services/f_service.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get_storage/get_storage.dart';
import 'package:uuid/v4.dart';

class FCache {
  static final FCache _instance = FCache._internal();

  FCache._internal();

  factory FCache() {
    return _instance;
  }

  final _storage = const FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
    iOptions: IOSOptions(),
  );

  final _box = GetStorage();

  ///获取设备ID
  Future<String> phoneId({bool isOrigin = false}) async {
    var devicesId = await _storage.read(key: 'fast_id_7mN4bH6tS');
    if (devicesId == null || devicesId.isEmpty) {
      devicesId = await _genPhoneId();
      await _storage.write(key: 'fast_id_7mN4bH6tS', value: devicesId);
    }

    return isOrigin ? devicesId : '${FService().platform}.$devicesId';
  }

  ///获取手机端用户设备标识
  Future<String> _genPhoneId() async {
    String gen() {
      String? deviceNo = const UuidV4().generate();
      return deviceNo;
    }

    if (Platform.isAndroid) {
      const androidIdPlugin = AndroidId();
      final String? androidId = await androidIdPlugin.getId();
      return androidId ?? gen();
    } else if (Platform.isIOS) {
      final DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
      final iosInfo = await deviceInfo.iosInfo;
      return iosInfo.identifierForVendor?.isNotEmpty == true
          ? iosInfo.identifierForVendor!
          : gen();
    } else {
      return gen();
    }
  }

  /// clk
  bool get isBig => _box.read<bool>('5zR7wE1qX') ?? false;
  set isBig(bool value) => _box.write('5zR7wE1qX', value);

  /// start restart app
  bool get isRestart => _box.read<bool>('restart_k8V2gT5rA') ?? false;
  set isRestart(bool value) => _box.write('restart_k8V2gT5rA', value);

  /// chatBgImage
  String get chatBgImagePath => _box.read<String>('chat_3jU6yI8oZ') ?? '';
  set chatBgImagePath(String value) => _box.write('chat_3jU6yI8oZ', value);

  /// user
  Accouont? get user {
    final map = _box.read('user_x7kP2r9mQ');
    final user = map == null ? null : Accouont.fromJson(map!);
    return user;
  }

  set user(Accouont? value) {
    if (value == null) {
      return;
    }
    final map = value.toJson();
    _box.write('user_x7kP2r9mQ', map);
  }

  // send msg couont
  int get sendMsgCount => _box.read<int>('send_d5F9sP2wQ') ?? 0;
  set sendMsgCount(int value) => _box.write('send_d5F9sP2wQ', value);

  // locale
  String get locale => _box.read<String>('lan_p3C9dY2jF') ?? '';
  set locale(String value) => _box.write('lan_p3C9dY2jF', value);

  // hasShownTranslationDialog
  bool get hasShownTranslationDialog =>
      _box.read<bool>('tr_t4L6nB2vK') ?? false;
  set hasShownTranslationDialog(bool value) =>
      _box.write('tr_t4L6nB2vK', value);

  // installTime
  int get installTime => _box.read<int>('an_3fT7k2pQ') ?? 0;
  set installTime(int value) => _box.write('an_3fT7k2pQ', value);

  // lastRewardDate
  int get lastRewardDate => _box.read<int>('re_8sD3fG5hJ') ?? 0;
  set lastRewardDate(int value) => _box.write('re_8sD3fG5hJ', value);

  // 首次点击聊天输入框
  bool get firstClickChatInputBox => _box.read<bool>('dsagfa1561gfag') ?? true;
  set firstClickChatInputBox(bool value) => _box.write('dsagfa1561gfag', value);

  /// translation msg ids
  Set<String> get translationMsgIds {
    final List<dynamic>? data = _box.read('tr_23456789');
    return data?.cast<String>().toSet() ?? <String>{};
  }

  set translationMsgIds(Set<String> value) =>
      _box.write('tr_23456789', value.toList()); // 存储时转为List

  // 同一个 AI 连续发送 2 次消息拉起评分
  bool get isRateMsg => _box.read<bool>('Sn8tC3b') ?? false;
  set isRateMsg(bool value) => _box.write('Sn8tC3b', value);

  // 根据 角色 id 记录发送消息的次数Map<String,int> key 是角色 id value 是发送消息的次数
  Map<String, int> get sendMsgCountMap {
    final dynamic storedValue = _box.read('dfh4543fdgasd2d');
    if (storedValue is Map<String, dynamic>) {
      return storedValue.cast<String, int>();
    }
    return {};
  }

  set sendMsgCountMap(Map<String, int> value) =>
      _box.write('dfh4543fdgasd2d', value);

  // rate collect showd
  bool get isRateCollectShowd => _box.read<bool>('Lx7qA4z') ?? false;
  set isRateCollectShowd(bool value) => _box.write('Lx7qA4z', value);

  // rate level 2 showd
  bool get isRateLevel2Showd => _box.read<bool>('Bn3oY7d') ?? false;
  set isRateLevel2Showd(bool value) => _box.write('Bn3oY7d', value);
}
