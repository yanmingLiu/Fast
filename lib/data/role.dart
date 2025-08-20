import 'dart:convert';

class RolePage {
  List<Role>? records;
  int? total;
  int? size;
  int? current;
  int? pages;

  RolePage({this.records, this.total, this.size, this.current, this.pages});

  factory RolePage.fromRawJson(String str) => RolePage.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory RolePage.fromJson(Map<String, dynamic> json) => RolePage(
    records: json["records"] == null
        ? []
        : List<Role>.from(json["records"]!.map((x) => Role.fromJson(x))),
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

class Role {
  String? id;
  dynamic age;
  String? aboutMe;
  Media? media;
  List<RoleImage>? images;
  String? avatar;
  dynamic avatarVideo;
  String? name;
  String? platform;
  String? renderStyle;
  String? likes;
  List<String>? greetings;
  List<dynamic>? greetingsVoice;
  String? sessionCount;
  bool? vip;
  int? orderNum;
  List<String>? tags;
  dynamic tagType;
  String? scenario;
  dynamic voiceId;
  dynamic engine;
  int? gender;
  bool? videoChat;
  dynamic characterVideoChat;
  dynamic genPhotoTags;
  dynamic genVideoTags;
  bool? genPhoto;
  bool? genVideo;
  bool? gems;
  bool? collect;
  String? lastMessage;
  String? intro;
  dynamic changeClothing;
  dynamic changeClothes;
  int? updateTime;
  int? chatNum;
  int? msgNum;
  String? mode;
  int? cid;
  dynamic cardNum;
  dynamic unlockCardNum;
  dynamic price;

  Role({
    this.id,
    this.age,
    this.aboutMe,
    this.media,
    this.images,
    this.avatar,
    this.avatarVideo,
    this.name,
    this.platform,
    this.renderStyle,
    this.likes,
    this.greetings,
    this.greetingsVoice,
    this.sessionCount,
    this.vip,
    this.orderNum,
    this.tags,
    this.tagType,
    this.scenario,
    this.voiceId,
    this.engine,
    this.gender,
    this.videoChat,
    this.characterVideoChat,
    this.genPhotoTags,
    this.genVideoTags,
    this.genPhoto,
    this.genVideo,
    this.gems,
    this.collect,
    this.lastMessage,
    this.intro,
    this.changeClothing,
    this.changeClothes,
    this.updateTime,
    this.chatNum,
    this.msgNum,
    this.mode,
    this.cid,
    this.cardNum,
    this.unlockCardNum,
    this.price,
  });

  factory Role.fromRawJson(String str) => Role.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory Role.fromJson(Map<String, dynamic> json) => Role(
    id: json["id"],
    age: json["age"],
    aboutMe: json["about_me"],
    media: json["media"] == null ? null : Media.fromJson(json["media"]),
    images: json["images"] == null
        ? []
        : List<RoleImage>.from(json["images"]!.map((x) => RoleImage.fromJson(x))),
    avatar: json["avatar"],
    avatarVideo: json["avatar_video"],
    name: json["name"],
    platform: json["platform"],
    renderStyle: json["render_style"],
    likes: json["likes"],
    greetings: json["greetings"] == null ? [] : List<String>.from(json["greetings"]!.map((x) => x)),
    greetingsVoice: json["greetings_voice"] == null
        ? []
        : List<dynamic>.from(json["greetings_voice"]!.map((x) => x)),
    sessionCount: json["session_count"],
    vip: json["vip"],
    orderNum: json["order_num"],
    tags: json["tags"] == null ? [] : List<String>.from(json["tags"]!.map((x) => x)),
    tagType: json["tag_type"],
    scenario: json["scenario"],
    voiceId: json["voice_id"],
    engine: json["engine"],
    gender: json["gender"],
    videoChat: json["video_chat"],
    characterVideoChat: json["character_video_chat"],
    genPhotoTags: json["gen_photo_tags"],
    genVideoTags: json["gen_video_tags"],
    genPhoto: json["gen_photo"],
    genVideo: json["gen_video"],
    gems: json["gems"],
    collect: json["collect"],
    lastMessage: json["last_message"],
    intro: json["intro"],
    changeClothing: json["change_clothing"],
    changeClothes: json["change_clothes"],
    updateTime: json["update_time"],
    chatNum: json["chat_num"],
    msgNum: json["msg_num"],
    mode: json["mode"],
    cid: json["cid"],
    cardNum: json["card_num"],
    unlockCardNum: json["unlock_card_num"],
    price: json["price"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "age": age,
    "about_me": aboutMe,
    "media": media?.toJson(),
    "images": images == null ? [] : List<dynamic>.from(images!.map((x) => x.toJson())),
    "avatar": avatar,
    "avatar_video": avatarVideo,
    "name": name,
    "platform": platform,
    "render_style": renderStyle,
    "likes": likes,
    "greetings": greetings == null ? [] : List<dynamic>.from(greetings!.map((x) => x)),
    "greetings_voice": greetingsVoice == null
        ? []
        : List<dynamic>.from(greetingsVoice!.map((x) => x)),
    "session_count": sessionCount,
    "vip": vip,
    "order_num": orderNum,
    "tags": tags == null ? [] : List<dynamic>.from(tags!.map((x) => x)),
    "tag_type": tagType,
    "scenario": scenario,
    "voice_id": voiceId,
    "engine": engine,
    "gender": gender,
    "video_chat": videoChat,
    "character_video_chat": characterVideoChat,
    "gen_photo_tags": genPhotoTags,
    "gen_video_tags": genVideoTags,
    "gen_photo": genPhoto,
    "gen_video": genVideo,
    "gems": gems,
    "collect": collect,
    "last_message": lastMessage,
    "intro": intro,
    "change_clothing": changeClothing,
    "change_clothes": changeClothes,
    "update_time": updateTime,
    "chat_num": chatNum,
    "msg_num": msgNum,
    "mode": mode,
    "cid": cid,
    "card_num": cardNum,
    "unlock_card_num": unlockCardNum,
    "price": price,
  };
}

class RoleImage {
  int? id;
  DateTime? createTime;
  DateTime? updateTime;
  String? imageUrl;
  String? modelId;
  int? gems;
  int? imgType;
  dynamic imgRemark;
  bool? unlocked;

  RoleImage({
    this.id,
    this.createTime,
    this.updateTime,
    this.imageUrl,
    this.modelId,
    this.gems,
    this.imgType,
    this.imgRemark,
    this.unlocked,
  });

  factory RoleImage.fromRawJson(String str) => RoleImage.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory RoleImage.fromJson(Map<String, dynamic> json) => RoleImage(
    id: json["id"],
    createTime: json["create_time"] == null ? null : DateTime.parse(json["create_time"]),
    updateTime: json["update_time"] == null ? null : DateTime.parse(json["update_time"]),
    imageUrl: json["image_url"],
    modelId: json["model_id"],
    gems: json["gems"],
    imgType: json["img_type"],
    imgRemark: json["img_remark"],
    unlocked: json["unlocked"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "create_time": createTime?.toIso8601String(),
    "update_time": updateTime?.toIso8601String(),
    "image_url": imageUrl,
    "model_id": modelId,
    "gems": gems,
    "img_type": imgType,
    "img_remark": imgRemark,
    "unlocked": unlocked,
  };
}

class Media {
  List<String>? characterImages;

  Media({this.characterImages});

  factory Media.fromRawJson(String str) => Media.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory Media.fromJson(Map<String, dynamic> json) => Media(
    characterImages: json["character_images"] == null
        ? []
        : List<String>.from(json["character_images"]!.map((x) => x)),
  );

  Map<String, dynamic> toJson() => {
    "character_images": characterImages == null
        ? []
        : List<dynamic>.from(characterImages!.map((x) => x)),
  };
}
