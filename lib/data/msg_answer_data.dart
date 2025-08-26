import 'dart:convert';

import 'package:fast_ai/data/msg_data.dart';

class MsgAnswerData {
  final String? convId;
  final String? msgId;
  final Answer? answer;

  MsgAnswerData({this.convId, this.msgId, this.answer});

  factory MsgAnswerData.fromRawJson(String str) => MsgAnswerData.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory MsgAnswerData.fromJson(Map<String, dynamic> json) => MsgAnswerData(
    convId: json['conv_id'],
    msgId: json['msg_id'],
    answer: json['answer'] == null ? null : Answer.fromJson(json['answer']),
  );

  Map<String, dynamic> toJson() => {'conv_id': convId, 'msg_id': msgId, 'answer': answer?.toJson()};
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
  final ChatAnserLevel? appUserChatLevel;

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
    src: json['source'],
    lockLvl: json['lock_level'],
    lockMed: json['lock_level_media'],
    voiceUrl: json['voice_url'],
    voiceDur: json['voice_duration'],
    resUrl: json['res_url'],
    duration: json['duration'],
    thumbUrl: json['thumbnail_url'],
    translateContent: json['translate_content'],
    upgrade: json['upgrade'],
    rewards: json['rewards'],
    appUserChatLevel: json['app_user_chat_level'] == null
        ? null
        : ChatAnserLevel.fromJson(json['app_user_chat_level']),
  );

  Map<String, dynamic> toJson() => {
    'content': content,
    'source': src,
    'lock_level': lockLvl,
    'lock_level_media': lockMed,
    'voice_url': voiceUrl,
    'voice_duration': voiceDur,
    'res_url': resUrl,
    'duration': duration,
    'thumbnail_url': thumbUrl,
    'translate_content': translateContent,
    'upgrade': upgrade,
    'rewards': rewards,
    'app_user_chat_level': appUserChatLevel,
  };
}
