import 'dart:convert';

class RoleTagRes {
  final String? labelType;
  final List<RoleTag>? tags;

  RoleTagRes({this.labelType, this.tags});

  factory RoleTagRes.fromRawJson(String str) => RoleTagRes.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory RoleTagRes.fromJson(Map<String, dynamic> json) => RoleTagRes(
    labelType: json["label_type"],
    tags: json["tag_list"] == null
        ? []
        : List<RoleTag>.from(json["tag_list"]!.map((x) => RoleTag.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "label_type": labelType,
    "tag_list": tags == null ? [] : List<dynamic>.from(tags!.map((x) => x.toJson())),
  };
}

class RoleTag {
  final int? id;
  final String? name;
  String? labelType;
  bool? remark;

  RoleTag({this.id, this.name, this.labelType, this.remark});

  factory RoleTag.fromRawJson(String str) => RoleTag.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory RoleTag.fromJson(Map<String, dynamic> json) =>
      RoleTag(id: json["id"], name: json["usr_name"], labelType: json["label_type"]);

  Map<String, dynamic> toJson() => {"id": id, "usr_name": name, "label_type": labelType};
}
