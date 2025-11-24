import 'dart:convert';

class Accouont {
  String? id;
  String? deviceId;
  String? token;
  String? platform;
  int? gems;
  dynamic audioSwitch;
  dynamic subscriptionEnd;
  String? nickname;
  String? idfa;
  String? adid;
  String? androidId;
  String? gpsAdid;
  bool? autoTranslate;
  bool? enableAutoTranslate;
  String? sourceLanguage;
  String? targetLanguage;
  int createImg;
  int createVideo;

  Accouont({
    this.id,
    this.deviceId,
    this.token,
    this.platform,
    this.gems,
    this.audioSwitch,
    this.subscriptionEnd,
    this.nickname,
    this.idfa,
    this.adid,
    this.androidId,
    this.gpsAdid,
    this.autoTranslate,
    this.enableAutoTranslate,
    this.sourceLanguage,
    this.targetLanguage,
    this.createImg = 0,
    this.createVideo = 0,
  });

  factory Accouont.fromRawJson(String str) =>
      Accouont.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory Accouont.fromJson(Map<String, dynamic> json) => Accouont(
        id: json["id"],
        deviceId: json["puevny"],
        token: json["wuwgwa"],
        platform: json["iptgpo"],
        gems: json["caggef"],
        audioSwitch: json["audio_switch"],
        subscriptionEnd: json["tahwnw"],
        nickname: json["twschm"],
        idfa: json["rqelpt"],
        adid: json["yzxxkn"],
        androidId: json["android_id"],
        gpsAdid: json["gps_adid"],
        autoTranslate: json["yrzytz"],
        enableAutoTranslate: json["braouc"],
        sourceLanguage: json["wtfivi"],
        targetLanguage: json["kvrjki"],
        createImg: json["bswwcu"] ?? 0,
        createVideo: json["wfvibl"] ?? 0,
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "puevny": deviceId,
        "wuwgwa": token,
        "iptgpo": platform,
        "caggef": gems,
        "audio_switch": audioSwitch,
        "tahwnw": subscriptionEnd,
        "twschm": nickname,
        "rqelpt": idfa,
        "yzxxkn": adid,
        "android_id": androidId,
        "gps_adid": gpsAdid,
        "yrzytz": autoTranslate,
        "braouc": enableAutoTranslate,
        "wtfivi": sourceLanguage,
        "kvrjki": targetLanguage,
        "bswwcu": createImg,
        "wfvibl": createVideo,
      };
}
