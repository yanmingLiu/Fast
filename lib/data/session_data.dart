import 'dart:convert';

class SessionDataRes {
  final int? current;
  final int? pages;
  final List<SessionData>? records;
  final int? size;
  final int? total;

  SessionDataRes({this.current, this.pages, this.records, this.size, this.total});

  factory SessionDataRes.fromRawJson(String str) => SessionDataRes.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory SessionDataRes.fromJson(Map<String, dynamic> json) => SessionDataRes(
    current: json["current"],
    pages: json["pages"],
    records: json["records"] == null
        ? []
        : List<SessionData>.from(json["records"]!.map((x) => SessionData.fromJson(x))),
    size: json["size"],
    total: json["total"],
  );

  Map<String, dynamic> toJson() => {
    "current": current,
    "pages": pages,
    "records": records == null ? [] : List<dynamic>.from(records!.map((x) => x.toJson())),
    "size": size,
    "total": total,
  };
}

class SessionData {
  final int? id;
  final String? avatar;
  final String? userId;
  final String? title;
  final bool? pinned;
  final DateTime? pinnedTime;
  final String? characterId;
  final dynamic model;
  final int? templateId;
  final String? voiceModel;
  final String? lastMessage;
  final bool? collect;

  /// 聊天模型 short / long
  String? chatModel;

  /// 场景
  String? scene;

  /// 角色 maskid
  int? profileId;

  SessionData({
    this.id,
    this.avatar,
    this.userId,
    this.title,
    this.pinned,
    this.pinnedTime,
    this.characterId,
    this.model,
    this.templateId,
    this.voiceModel,
    this.lastMessage,
    this.collect,
    this.chatModel,
    this.scene,
    this.profileId,
  });

  factory SessionData.fromRawJson(String str) => SessionData.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory SessionData.fromJson(Map<String, dynamic> json) => SessionData(
    id: json["id"],
    avatar: json["avtr_img"],
    userId: json["usr_id"],
    title: json["title"],
    pinned: json["pinned"],
    pinnedTime: json["pinned_time"] == null ? null : DateTime.parse(json["pinned_time"]),
    characterId: json["char_id"],
    model: json["model"],
    templateId: json["tmpl_id"],
    voiceModel: json["voice_model"],
    lastMessage: json["last_message"],
    collect: json["collect"],
    chatModel: json["zogojt"],
    scene: json["scene"],
    profileId: json["profile_id"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "avtr_img": avatar,
    "usr_id": userId,
    "title": title,
    "pinned": pinned,
    "pinned_time": pinnedTime?.toIso8601String(),
    "char_id": characterId,
    "model": model,
    "tmpl_id": templateId,
    "voice_model": voiceModel,
    "last_message": lastMessage,
    "collect": collect,
    "zogojt": chatModel,
    "scene": scene,
    "profile_id": profileId,
  };
}
