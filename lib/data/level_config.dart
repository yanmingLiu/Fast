import 'dart:convert';

class LevelConfig {
  final int? id;
  final int? level;
  final int? reward;
  final String? title;

  LevelConfig({this.id, this.level, this.reward, this.title});

  factory LevelConfig.fromRawJson(String str) => LevelConfig.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory LevelConfig.fromJson(Map<String, dynamic> json) => LevelConfig(
    id: json['id'],
    level: json['level'],
    reward: json['reward'],
    title: json['title'],
  );

  Map<String, dynamic> toJson() => {'id': id, 'level': level, 'reward': reward, 'title': title};
}
