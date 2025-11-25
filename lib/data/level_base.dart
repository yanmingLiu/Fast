import 'dart:convert';

class LevelBase {
  final int? id;
  final int? level;
  final int? reward;
  final String? title;

  LevelBase({this.id, this.level, this.reward, this.title});

  factory LevelBase.fromRawJson(String str) =>
      LevelBase.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory LevelBase.fromJson(Map<String, dynamic> json) => LevelBase(
        id: json['id'],
        level: json['level'],
        reward: json['reward'],
        title: json['title'],
      );

  Map<String, dynamic> toJson() =>
      {'id': id, 'level': level, 'reward': reward, 'title': title};
}
