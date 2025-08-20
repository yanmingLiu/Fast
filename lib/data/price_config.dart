import 'dart:convert';

class PriceConfig {
  final int? sceneChange;
  final int? textMessage;
  final int? audioMessage;
  final int? photoMessage;
  final int? videoMessage;
  final int? generateImage;
  final int? generateVideo;
  final int? profileChange;
  final int? callAiCharacters;

  PriceConfig({
    this.sceneChange,
    this.textMessage,
    this.audioMessage,
    this.photoMessage,
    this.videoMessage,
    this.generateImage,
    this.generateVideo,
    this.profileChange,
    this.callAiCharacters,
  });

  factory PriceConfig.fromRawJson(String str) => PriceConfig.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory PriceConfig.fromJson(Map<String, dynamic> json) => PriceConfig(
    sceneChange: json["scene_change"],
    textMessage: json["text_message"],
    audioMessage: json["audio_message"],
    photoMessage: json["photo_message"],
    videoMessage: json["video_message"],
    generateImage: json["generate_image"],
    generateVideo: json["generate_video"],
    profileChange: json["profile_change"],
    callAiCharacters: json["call_ai_characters"],
  );

  Map<String, dynamic> toJson() => {
    "scene_change": sceneChange,
    "text_message": textMessage,
    "audio_message": audioMessage,
    "photo_message": photoMessage,
    "video_message": videoMessage,
    "generate_image": generateImage,
    "generate_video": generateVideo,
    "profile_change": profileChange,
    "call_ai_characters": callAiCharacters,
  };
}
