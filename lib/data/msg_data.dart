import 'dart:convert';

import 'package:fast_ai/data/chat_anser_level.dart';
import 'package:fast_ai/values/app_values.dart';

class MsgRes {
  List<MsgData>? records;
  int? total;
  int? size;
  int? current;
  int? pages;

  MsgRes({this.records, this.total, this.size, this.current, this.pages});

  factory MsgRes.fromRawJson(String str) => MsgRes.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory MsgRes.fromJson(Map<String, dynamic> json) => MsgRes(
    records: json["records"] == null
        ? []
        : List<MsgData>.from(json["records"]!.map((x) => MsgData.fromJson(x))),
    total: json["total"],
    size: json["size"],
    current: json["current"],
    pages: json["pages"],
  );

  Map<String, dynamic> toJson() => {
    "records": records == null ? [] : List<dynamic>.from(records!.map((x) => x.toJson())),
    "total": total,
    "size": size,
    "current": current,
    "pages": pages,
  };
}

class MsgData {
  String? answer;
  int? atokens;
  int? audioDuration;
  String? audioUrl;
  String? characterId;
  int? conversationId;
  int? createTime;
  int? deleted;
  String? id;
  String? imgUrl;
  int? likes;
  String? mediaLock;
  String? model;
  int? modifyTime;
  String? msgId;
  String? params;
  String? platform;
  int? qtokens;
  String? question;
  int? templateId;
  String? textLock;
  String? userId;
  int? videoDuration;
  String? videoUrl;
  String? thumbLink;
  String? voiceUrl;
  int? voiceDur;
  ChatAnserLevel? appUserChatLevel;
  bool? upgrade;
  int? rewards;
  String? translateAnswer;
  int? giftId;
  String? giftImg;
  String? src;

  bool? onAnswer;
  bool isRead = false;
  bool showTranslate = false;
  bool typewriterAnimated = false;

  MsgSource _source = MsgSource.text; // 用私有变量来存储 source 的值

  MsgSource get source {
    if (videoUrl != null) {
      return MsgSource.video;
    }
    if (imgUrl != null) {
      return MsgSource.photo;
    }
    if (audioUrl != null) {
      return MsgSource.audio;
    }
    return MsgSource.fromSource(src) ?? _source;
  }

  set source(MsgSource value) {
    _source = value;
  }

  MsgData({
    this.answer,
    this.atokens,
    this.audioDuration,
    this.audioUrl,
    this.characterId,
    this.conversationId,
    this.createTime,
    this.deleted,
    this.id,
    this.imgUrl,
    this.likes,
    this.mediaLock,
    this.model,
    this.modifyTime,
    this.msgId,
    this.params,
    this.platform,
    this.qtokens,
    this.question,
    this.templateId,
    this.textLock,
    this.userId,
    this.videoDuration,
    this.videoUrl,
    this.onAnswer = false,
    this.voiceUrl,
    this.voiceDur,
    this.appUserChatLevel,
    this.upgrade,
    this.rewards,
    this.translateAnswer,
    this.thumbLink,
    this.giftId,
    this.giftImg,
    this.src,
  });

  factory MsgData.fromRawJson(String str) => MsgData.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory MsgData.fromJson(Map<String, dynamic> json) => MsgData(
    answer: json["ophbla"],
    atokens: json["atokens"],
    audioDuration: json["audio_duration"],
    audioUrl: json["audio_url"],
    characterId: json["char_id"],
    conversationId: json["ybvhjk"],
    createTime: json["creat_time"],
    deleted: json["deleted"],
    id: json["id"],
    imgUrl: json["img_url"],
    likes: json["like_cnt"],
    mediaLock: json["media_lock"],
    model: json["model"],
    modifyTime: json["modify_time"],
    msgId: json["msg_identifier"],
    params: json["params"],
    platform: json["platfrm"],
    qtokens: json["qtokens"],
    question: json["vnvqou"],
    templateId: json["tmpl_id"],
    textLock: json["text_lock"],
    userId: json["usr_id"],
    videoDuration: json["video_duration"],
    videoUrl: json["video_url"],
    thumbLink: json["thumb_link"] ?? json["gejhdy"],
    voiceUrl: json["voice_link"],
    voiceDur: json["voice_dur"],
    appUserChatLevel: json["yiasvv"] == null ? null : ChatAnserLevel.fromJson(json["yiasvv"]),
    upgrade: json["dclesw"],
    rewards: json["wouomy"],
    translateAnswer: json["vmmqud"],
    giftId: json["gift_id"],
    giftImg: json["gift_img"],
    src: json["mvusjp"],
  );

  Map<String, dynamic> toJson() => {
    "ophbla": answer,
    "atokens": atokens,
    "audio_duration": audioDuration,
    "audio_url": audioUrl,
    "char_id": characterId,
    "ybvhjk": conversationId,
    "creat_time": createTime,
    "deleted": deleted,
    "id": id,
    "img_url": imgUrl,
    "like_cnt": likes,
    "media_lock": mediaLock,
    "model": model,
    "modify_time": modifyTime,
    "msg_identifier": msgId,
    "params": params,
    "platfrm": platform,
    "qtokens": qtokens,
    "vnvqou": question,
    "tmpl_id": templateId,
    "text_lock": textLock,
    "usr_id": userId,
    "video_duration": videoDuration,
    "video_url": videoUrl,
    "voice_link": voiceUrl,
    "voice_dur": voiceDur,
    "yiasvv": appUserChatLevel?.toJson(),
    "dclesw": upgrade,
    "wouomy": rewards,
    "vmmqud": translateAnswer,
    "thumb_link": thumbLink,
    "gift_id": giftId,
    "gift_img": giftImg,
    "mvusjp": src,
  };

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is MsgData && other.id == id && other.source == source;
  }

  @override
  int get hashCode => id.hashCode;
}
