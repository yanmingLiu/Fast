import 'package:fast_ai/gen/assets.gen.dart';
import 'package:fast_ai/generated/locales.g.dart';
import 'package:fast_ai/services/app_user.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

enum VipFrom {
  locktext,
  lockpic,
  lockvideo,
  lockaudio,
  send,
  homevip,
  mevip,
  chatvip,
  launch,
  relaunch,
  viprole,
  call,
  acceptcall,
  creimg,
  crevideo,
  undrphoto,
  postpic,
  postvideo,
  undrchar,
  videochat,
  trans,
  dailyrd,
  scenario,
}

enum ConsumeFrom {
  home,
  chat,
  send,
  profile,
  text,
  audio,
  call,
  unlcokText,
  undr,
  creaimg,
  creavideo,
  album,
  gift_toy,
  gift_clo,
  aiphoto,
  img2v,
  mask,
}

extension GlobFromExt on ConsumeFrom {
  int get gems {
    switch (this) {
      case ConsumeFrom.text:
        return AppUser().priceConfig?.textMessage ?? 2;

      case ConsumeFrom.call:
        return AppUser().priceConfig?.callAiCharacters ?? 10;
      default:
        return 0;
    }
  }
}

enum MsgSource {
  text('TEXT_GEN'),
  video('VIDEO'),
  audio('AUDIO'),
  photo('PHOTO'),
  gift('GIFT'),
  clothe('CLOTHE'),

  sendText('sendText'),
  waitAnswer('waitAnswer'),
  tips('tips'),
  scenario('scenario'),
  intro('intro'),
  welcome('welcome'),
  maskTips('maskTips'),
  error('error');

  final String value;
  const MsgSource(this.value);

  static final Map<String, MsgSource> _map = {for (var e in MsgSource.values) e.value: e};

  static MsgSource? fromSource(String? source) => _map[source];
}

enum MsgLockLevel {
  normal,
  private;

  String get value => name.toUpperCase();
}

enum ClothingState { init, chooseImage, generated }

enum CreateType { photo, video }

enum CallState { calling, incoming, listening, answering, answered, micOff }

enum FollowEvent { follow, unfollow }

enum Gender {
  male(0),
  female(1),
  nonBinary(2),
  unknown(-1);

  final int code;
  const Gender(this.code);

  static final Map<int, Gender> _codeMap = {for (var g in Gender.values) g.code: g};

  /// 根据数值反查 Gender
  static Gender fromValue(int? code) => _codeMap[code] ?? Gender.unknown;

  /// 显示名称（可根据需要本地化）
  String get display {
    switch (this) {
      case Gender.male:
        return LocaleKeys.male.tr;
      case Gender.female:
        return LocaleKeys.female.tr;
      case Gender.nonBinary:
        return LocaleKeys.non_binary.tr;
      case Gender.unknown:
        return 'unknown';
    }
  }

  Widget get icon {
    switch (this) {
      case Gender.male:
        return Assets.images.male.image(width: 16);
      case Gender.female:
        return Assets.images.female.image(width: 16);
      case Gender.nonBinary:
        return Assets.images.nonbinary.image(width: 16);
      case Gender.unknown:
        return Icon(Icons.question_mark);
    }
  }
}
