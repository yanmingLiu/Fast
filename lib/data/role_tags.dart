import 'dart:convert';

class RoleTagRes {
  final String? labelType;
  final List<RoleTag>? tags;

  RoleTagRes({this.labelType, this.tags});

  factory RoleTagRes.fromRawJson(String str) => RoleTagRes.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory RoleTagRes.fromJson(Map<String, dynamic> json) => RoleTagRes(
    labelType: json["label_type"],
    tags: json["tags"] == null
        ? []
        : List<RoleTag>.from(json["tags"]!.map((x) => RoleTag.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "label_type": labelType,
    "tags": tags == null ? [] : List<dynamic>.from(tags!.map((x) => x.toJson())),
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
      RoleTag(id: json["id"], name: json["name"], labelType: json["label_type"]);

  Map<String, dynamic> toJson() => {"id": id, "name": name, "label_type": labelType};
}
