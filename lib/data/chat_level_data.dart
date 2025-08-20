import 'dart:convert';

class ChatLevelData {
  final int? id;
  final int? level;
  final int? reward;
  final String? title;

  ChatLevelData({this.id, this.level, this.reward, this.title});

  factory ChatLevelData.fromRawJson(String str) => ChatLevelData.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory ChatLevelData.fromJson(Map<String, dynamic> json) => ChatLevelData(
    id: json['id'],
    level: json['level'],
    reward: json['reward'],
    title: json['title'],
  );

  Map<String, dynamic> toJson() => {'id': id, 'level': level, 'reward': reward, 'title': title};
}
