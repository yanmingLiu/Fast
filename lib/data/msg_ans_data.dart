import 'dart:convert';

import 'package:fast_ai/data/ans_level.dart';

class MsgAnsData {
  final String? convId;
  final String? msgId;
  final Answer? answer;

  MsgAnsData({this.convId, this.msgId, this.answer});

  factory MsgAnsData.fromRawJson(String str) =>
      MsgAnsData.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory MsgAnsData.fromJson(Map<String, dynamic> json) => MsgAnsData(
        convId: json['fnivfn'],
        msgId: json['yzujoc'],
        answer: json['ophbla'] == null ? null : Answer.fromJson(json['ophbla']),
      );

  Map<String, dynamic> toJson() =>
      {'fnivfn': convId, 'yzujoc': msgId, 'ophbla': answer?.toJson()};
}

class Answer {
  final String? content;
  final String? src;
  final String? lockLvl;
  final String? lockMed;
  final String? voiceUrl;
  final int? voiceDur;
  final String? resUrl;
  final int? duration;
  final String? thumbUrl;
  final String? translateContent;
  final bool? upgrade;
  final int? rewards;
  final AnsLevel? appUserChatLevel;

  Answer({
    this.content,
    this.src,
    this.lockLvl,
    this.lockMed,
    this.voiceUrl,
    this.voiceDur,
    this.resUrl,
    this.duration,
    this.thumbUrl,
    this.translateContent,
    this.upgrade,
    this.rewards,
    this.appUserChatLevel,
  });

  factory Answer.fromRawJson(String str) => Answer.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory Answer.fromJson(Map<String, dynamic> json) => Answer(
        content: json['content'],
        src: json['mvusjp'],
        lockLvl: json['ytwtbr'],
        lockMed: json['sayucj'],
        voiceUrl: json['wtaibz'],
        voiceDur: json['foaqje'],
        resUrl: json['res_url'],
        duration: json['xyyrws'],
        thumbUrl: json['gejhdy'],
        translateContent: json['translate_content'],
        upgrade: json['dclesw'],
        rewards: json['wouomy'],
        appUserChatLevel:
            json['yiasvv'] == null ? null : AnsLevel.fromJson(json['yiasvv']),
      );

  Map<String, dynamic> toJson() => {
        'content': content,
        'mvusjp': src,
        'ytwtbr': lockLvl,
        'sayucj': lockMed,
        'wtaibz': voiceUrl,
        'foaqje': voiceDur,
        'res_url': resUrl,
        'xyyrws': duration,
        'gejhdy': thumbUrl,
        'translate_content': translateContent,
        'dclesw': upgrade,
        'wouomy': rewards,
        'yiasvv': appUserChatLevel,
      };
}
