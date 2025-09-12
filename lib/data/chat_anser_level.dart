import 'dart:convert';

class ChatAnserLevel {
  final int? id;
  final String? userId;
  final int? conversationId;
  final String? charId;
  final int? level;
  final int? num;
  final double? progress;
  final double? upgradeRequirements;
  final int? rewards;

  ChatAnserLevel({
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

  ChatAnserLevel copyWith({
    int? id,
    String? userId,
    int? conversationId,
    String? charId,
    int? level,
    int? num,
    double? progress,
    double? upgradeRequirements,
    int? rewards,
  }) => ChatAnserLevel(
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

  factory ChatAnserLevel.fromRawJson(String str) => ChatAnserLevel.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory ChatAnserLevel.fromJson(Map<String, dynamic> json) => ChatAnserLevel(
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
