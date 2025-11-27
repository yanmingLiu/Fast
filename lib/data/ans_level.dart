import 'dart:convert';

class AnsLevel {
  final int? id;
  final String? userId;
  final int? conversationId;
  final String? charId;
  final int? level;
  final int? num;
  final double? progress;
  final double? upgradeRequirements;
  final int? rewards;

  AnsLevel({
    this.id,
    this.userId,
    this.conversationId,
    this.charId,
    this.level,
    this.num,
    this.progress,
    this.upgradeRequirements,
    this.rewards,
  });

  AnsLevel copyWith({
    int? id,
    String? userId,
    int? conversationId,
    String? charId,
    int? level,
    int? num,
    double? progress,
    double? upgradeRequirements,
    int? rewards,
  }) =>
      AnsLevel(
        id: id ?? this.id,
        userId: userId ?? this.userId,
        conversationId: conversationId ?? this.conversationId,
        charId: charId ?? this.charId,
        level: level ?? this.level,
        num: num ?? this.num,
        progress: progress ?? this.progress,
        upgradeRequirements: upgradeRequirements ?? this.upgradeRequirements,
        rewards: rewards ?? this.rewards,
      );

  factory AnsLevel.fromRawJson(String str) =>
      AnsLevel.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory AnsLevel.fromJson(Map<String, dynamic> json) => AnsLevel(
        id: json['id'],
        userId: json['pttgjv'],
        conversationId: json['ybvhjk'],
        charId: json['char_id'],
        level: json['level'],
        num: json['num'],
        progress: json['progress'],
        upgradeRequirements: json['upgrade_requirements'],
        rewards: json['wouomy'],
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'pttgjv': userId,
        'ybvhjk': conversationId,
        'char_id': charId,
        'level': level,
        'num': num,
        'progress': progress,
        'upgrade_requirements': upgradeRequirements,
        'wouomy': rewards,
      };
}
