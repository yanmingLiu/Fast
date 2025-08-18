import 'dart:convert';

class RolePage {
  final List<Role>? records;
  final int? total;
  final int? size;
  final int? current;
  final int? pages;

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
  int? age;
  String? aboutMe;
  Media? media;
  String? avatar;
  String? name;
  String? platform;
  String? renderStyle;
  String? likes;
  List<String>? greetings;
  List<GreetingsVoice>? greetingsVoice;
  String? sessionCount;
  bool? vip;
  int? orderNum;
  List<String>? tags;
  String? scenario;
  double? temperature;
  String? voiceId;
  String? engine;
  int? gender;
  bool? videoChat;
  List<CharacterVideoChat>? characterVideoChat;
  List<String>? genPhotoTags;
  List<String>? genVideoTags;
  bool? genPhoto;
  bool? genVideo;
  bool? gems;
  bool? collect;
  String? lastMessage;
  List<RoleImage>? images;
  List<ChangeClothe>? changeClothes;
  bool? changeTogs;

  Role({
    this.id,
    this.age,
    this.aboutMe,
    this.media,
    this.avatar,
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
    this.scenario,
    this.temperature,
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
    this.images,
    this.changeClothes,
    this.changeTogs,
  });

  factory Role.fromRawJson(String str) => Role.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory Role.fromJson(Map<String, dynamic> json) => Role(
    id: json["id"],
    age: json["yr_age"],
    aboutMe: json["about_me_txt"],
    media: json["media_content"] == null ? null : Media.fromJson(json["media_content"]),
    avatar: json["avatar_video"] ?? json["avtr_img"],
    name: json["usr_name"],
    platform: json["platfrm"],
    renderStyle: json["rend_style"],
    likes: json["like_cnt"],
    greetings: json["greet_msg"] == null ? [] : List<String>.from(json["greet_msg"]!.map((x) => x)),
    greetingsVoice: json["greet_voice"] == null
        ? []
        : List<GreetingsVoice>.from(json["greet_voice"]!.map((x) => GreetingsVoice.fromJson(x))),
    sessionCount: json["sess_count"],
    vip: json["vip_status"],
    orderNum: json["ord_num"],
    tags: json["tag_list"] == null ? [] : List<String>.from(json["tag_list"]!.map((x) => x)),
    scenario: json["scenario"],
    temperature: json["temperature"]?.toDouble(),
    voiceId: json["voice_ident"],
    engine: json["engn"],
    gender: json["gendr"],
    videoChat: json["vid_chat"],
    characterVideoChat: json["char_vid_chat"] == null
        ? []
        : List<CharacterVideoChat>.from(
            json["char_vid_chat"]!.map((x) => CharacterVideoChat.fromJson(x)),
          ),
    genPhotoTags: json["photo_tags"] == null
        ? []
        : List<String>.from(json["photo_tags"]!.map((x) => x)),
    genVideoTags: json["gen_video_tags"] == null
        ? []
        : List<String>.from(json["gen_video_tags"]!.map((x) => x)),
    genPhoto: json["photo_gen"],
    genVideo: json["video_gen"],
    gems: json["gem_bal"],
    collect: json["collect"],
    lastMessage: json["last_message"],
    images: json['images'] == null
        ? []
        : List<RoleImage>.from(json['images']!.map((x) => RoleImage.fromJson(x))),
    changeClothes: json["change_clothes"] == null
        ? []
        : List<ChangeClothe>.from(json["change_clothes"]!.map((x) => ChangeClothe.fromJson(x))),
    changeTogs: json["change_togs"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "yr_age": age,
    "about_me_txt": aboutMe,
    "media_content": media?.toJson(),
    "avtr_img": avatar,
    "usr_name": name,
    "platfrm": platform,
    "rend_style": renderStyle,
    "like_cnt": likes,
    "greet_msg": greetings == null ? [] : List<dynamic>.from(greetings!.map((x) => x)),
    "greet_voice": greetingsVoice == null
        ? []
        : List<dynamic>.from(greetingsVoice!.map((x) => x.toJson())),
    "sess_count": sessionCount,
    "vip_status": vip,
    "ord_num": orderNum,
    "tag_list": tags == null ? [] : List<dynamic>.from(tags!.map((x) => x)),
    "scenario": scenario,
    "temperature": temperature,
    "voice_ident": voiceId,
    "engn": engine,
    "gendr": gender,
    "vid_chat": videoChat,
    "char_vid_chat": characterVideoChat == null
        ? []
        : List<dynamic>.from(characterVideoChat!.map((x) => x.toJson())),
    "photo_tags": genPhotoTags == null ? [] : List<dynamic>.from(genPhotoTags!.map((x) => x)),
    "gen_video_tags": genVideoTags == null ? [] : List<dynamic>.from(genVideoTags!.map((x) => x)),
    "photo_gen": genPhoto,
    "video_gen": genVideo,
    "gem_bal": gems,
    "collect": collect,
    "last_message": lastMessage,
    'images': images == null ? [] : List<dynamic>.from(images!.map((x) => x.toJson())),
    "change_clothes": changeClothes == null
        ? []
        : List<dynamic>.from(changeClothes!.map((x) => x.toJson())),
    "change_togs": changeTogs,
  };

  Role copyWith({
    String? id,
    int? age,
    String? aboutMe,
    Media? media,
    String? avatar,
    String? name,
    String? platform,
    String? renderStyle,
    String? likes,
    List<String>? greetings,
    List<GreetingsVoice>? greetingsVoice,
    String? sessionCount,
    bool? vip,
    int? orderNum,
    List<String>? tags,
    String? scenario,
    double? temperature,
    String? voiceId,
    String? engine,
    int? gender,
    bool? videoChat,
    List<CharacterVideoChat>? characterVideoChat,
    List<String>? genPhotoTags,
    List<String>? genVideoTags,
    bool? genPhoto,
    bool? genVideo,
    bool? gems,
    bool? collect,
    String? lastMessage,
    List<RoleImage>? images,
    List<ChangeClothe>? changeClothes,
    bool? changeTogs,
  }) {
    return Role(
      id: id ?? this.id,
      age: age ?? this.age,
      aboutMe: aboutMe ?? this.aboutMe,
      media: media ?? this.media,
      avatar: avatar ?? this.avatar,
      name: name ?? this.name,
      platform: platform ?? this.platform,
      renderStyle: renderStyle ?? this.renderStyle,
      likes: likes ?? this.likes,
      greetings: greetings ?? this.greetings,
      greetingsVoice: greetingsVoice ?? this.greetingsVoice,
      sessionCount: sessionCount ?? this.sessionCount,
      vip: vip ?? this.vip,
      orderNum: orderNum ?? this.orderNum,
      tags: tags ?? this.tags,
      scenario: scenario ?? this.scenario,
      temperature: temperature ?? this.temperature,
      voiceId: voiceId ?? this.voiceId,
      engine: engine ?? this.engine,
      gender: gender ?? this.gender,
      videoChat: videoChat ?? this.videoChat,
      characterVideoChat: characterVideoChat ?? this.characterVideoChat,
      genPhotoTags: genPhotoTags ?? this.genPhotoTags,
      genVideoTags: genVideoTags ?? this.genVideoTags,
      genPhoto: genPhoto ?? this.genPhoto,
      genVideo: genVideo ?? this.genVideo,
      gems: gems ?? this.gems,
      collect: collect ?? this.collect,
      lastMessage: lastMessage ?? this.lastMessage,
      images: images ?? this.images,
      changeClothes: changeClothes ?? this.changeClothes,
      changeTogs: changeTogs ?? this.changeTogs,
    );
  }
}

class CharacterVideoChat {
  final int? id;
  final String? characterId;
  final String? tag;
  final int? duration;
  final String? url;
  final String? gifUrl;

  CharacterVideoChat({this.id, this.characterId, this.tag, this.duration, this.url, this.gifUrl});

  factory CharacterVideoChat.fromRawJson(String str) =>
      CharacterVideoChat.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory CharacterVideoChat.fromJson(Map<String, dynamic> json) => CharacterVideoChat(
    id: json["id"],
    characterId: json["char_id"],
    tag: json["tag"],
    duration: json["dur"] is double ? json["dur"].toInt() : json["dur"],
    url: json["web_link"],
    gifUrl: json["gif_url"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "char_id": characterId,
    "tag": tag,
    "dur": duration,
    "web_link": url,
    "gif_url": gifUrl,
  };
}

class GreetingsVoice {
  final String? url;
  final int? duration;

  GreetingsVoice({this.url, this.duration});

  factory GreetingsVoice.fromRawJson(String str) => GreetingsVoice.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory GreetingsVoice.fromJson(Map<String, dynamic> json) => GreetingsVoice(
    url: json["web_link"],
    duration: json["dur"] is double ? json["dur"].toInt() : json["dur"],
  );

  Map<String, dynamic> toJson() => {"web_link": url, "dur": duration};
}

class Media {
  final List<String>? characterImages;

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

class RoleImage {
  int? id;
  String? imageUrl;
  String? modelId;
  int? gemTally;
  bool? unlocked;

  RoleImage({this.id, this.imageUrl, this.modelId, this.gemTally, this.unlocked});

  factory RoleImage.fromRawJson(String str) => RoleImage.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory RoleImage.fromJson(Map<String, dynamic> json) => RoleImage(
    id: json['id'],
    imageUrl: json['image_url'],
    modelId: json['model_id'],
    gemTally: json['gem_bal'],
    unlocked: json['unlocked'],
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'image_url': imageUrl,
    'model_id': modelId,
    'gem_bal': gemTally,
    'unlocked': unlocked,
  };

  RoleImage copyWith({int? id, String? imageUrl, String? modelId, int? gemTally, bool? unlocked}) {
    return RoleImage(
      id: id ?? this.id,
      imageUrl: imageUrl ?? this.imageUrl,
      modelId: modelId ?? this.modelId,
      gemTally: gemTally ?? this.gemTally,
      unlocked: unlocked ?? this.unlocked,
    );
  }
}

class ChangeClothe {
  final int? id;
  final int? clothingType;
  final String? modelId;

  ChangeClothe({this.id, this.clothingType, this.modelId});

  factory ChangeClothe.fromRawJson(String str) => ChangeClothe.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory ChangeClothe.fromJson(Map<String, dynamic> json) =>
      ChangeClothe(id: json["id"], clothingType: json["clothing_type"], modelId: json["pdlurn"]);

  Map<String, dynamic> toJson() => {"id": id, "clothing_type": clothingType, "pdlurn": modelId};
}
