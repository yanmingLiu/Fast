import 'dart:convert';

class MaskListRes {
  List<MaskData>? records;
  int? total;
  int? size;
  int? current;
  MaskListRes({this.records, this.total, this.size, this.current});
  factory MaskListRes.fromJson(Map<String, dynamic> json) {
    return MaskListRes(
      records: json['records'] == null
          ? null
          : (json['records'] as List).map((e) => MaskData.fromJson(e)).toList(),
      total: json['total'],
      size: json['size'],
      current: json['current'],
    );
  }
  Map<String, dynamic> toJson() => {
    'records': records?.map((e) => e.toJson()).toList(),
    'total': total,
    'size': size,
    'current': current,
  };
}

class MaskData {
  final int? id;
  final String? userId;
  final String? profileName;
  final int? gender;
  final int? age;
  final String? description;
  final String? otherInfo;

  MaskData({
    this.id,
    this.userId,
    this.profileName,
    this.gender,
    this.age,
    this.description,
    this.otherInfo,
  });

  factory MaskData.fromRawJson(String str) => MaskData.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory MaskData.fromJson(Map<String, dynamic> json) => MaskData(
    id: json["id"],
    userId: json["pttgjv"],
    profileName: json["profile_name"],
    gender: json["kbwvep"],
    age: json["dvfbov"],
    description: json["description"],
    otherInfo: json["other_info"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "pttgjv": userId,
    "profile_name": profileName,
    "kbwvep": gender,
    "dvfbov": age,
    "description": description,
    "other_info": otherInfo,
  };
}
