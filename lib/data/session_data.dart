import 'dart:convert';

class SessionDataRes {
  List<SessionData>? records;
  int? total;
  int? size;
  int? current;
  int? pages;

  SessionDataRes({this.records, this.total, this.size, this.current, this.pages});

  factory SessionDataRes.fromRawJson(String str) => SessionDataRes.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory SessionDataRes.fromJson(Map<String, dynamic> json) => SessionDataRes(
    records: json["records"] == null
        ? []
        : List<SessionData>.from(json["records"]!.map((x) => SessionData.fromJson(x))),
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

class SessionData {
  int? id;
  String? avatar;
  String? userId;
  String? title;
  bool? pinned;
  dynamic pinnedTime;
  String? characterId;
  dynamic model;
  int? templateId;
  String? voiceModel;
  dynamic lastMessage;
  int? updateTime;
  int? createTime;
  bool? collect;
  String? mode;
  dynamic background;
  int? cid;
  String? scene;
  int? profileId;
  String? chatModel;

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
    this.updateTime,
    this.createTime,
    this.collect,
    this.mode,
    this.background,
    this.cid,
    this.scene,
    this.profileId,
    this.chatModel,
  });

  factory SessionData.fromRawJson(String str) => SessionData.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory SessionData.fromJson(Map<String, dynamic> json) => SessionData(
    id: json["id"],
    avatar: json["ilubju"],
    userId: json["pttgjv"],
    title: json["title"],
    pinned: json["pinned"],
    pinnedTime: json["pinned_time"],
    characterId: json["jrtqer"],
    model: json["model"],
    templateId: json["jdpgll"],
    voiceModel: json["voice_model"],
    lastMessage: json["wjhrab"],
    updateTime: json["kjckes"],
    createTime: json["uvpftb"],
    collect: json["collect"],
    mode: json["mode"],
    background: json["background"],
    cid: json["xxhseg"],
    scene: json["npdrdn"],
    profileId: json["rbiyym"],
    chatModel: json["eoormy"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "ilubju": avatar,
    "pttgjv": userId,
    "title": title,
    "pinned": pinned,
    "pinned_time": pinnedTime,
    "jrtqer": characterId,
    "model": model,
    "jdpgll": templateId,
    "voice_model": voiceModel,
    "wjhrab": lastMessage,
    "kjckes": updateTime,
    "uvpftb": createTime,
    "collect": collect,
    "mode": mode,
    "background": background,
    "xxhseg": cid,
    "npdrdn": scene,
    "rbiyym": profileId,
    "eoormy": chatModel,
  };
}
