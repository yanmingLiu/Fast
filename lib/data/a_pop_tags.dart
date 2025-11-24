import 'dart:convert';

class APopTagRes {
  final String? labelType;
  final List<APopTag>? tags;

  APopTagRes({this.labelType, this.tags});

  factory APopTagRes.fromRawJson(String str) =>
      APopTagRes.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory APopTagRes.fromJson(Map<String, dynamic> json) => APopTagRes(
        labelType: json["label_type"],
        tags: json["kzedme"] == null
            ? []
            : List<APopTag>.from(
                json["kzedme"]!.map((x) => APopTag.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "label_type": labelType,
        "kzedme": tags == null
            ? []
            : List<dynamic>.from(tags!.map((x) => x.toJson())),
      };
}

class APopTag {
  final int? id;
  final String? name;
  String? labelType;
  bool? remark;

  APopTag({this.id, this.name, this.labelType, this.remark});

  factory APopTag.fromRawJson(String str) => APopTag.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory APopTag.fromJson(Map<String, dynamic> json) => APopTag(
      id: json["id"], name: json["cxchkf"], labelType: json["label_type"]);

  Map<String, dynamic> toJson() =>
      {"id": id, "cxchkf": name, "label_type": labelType};
}
