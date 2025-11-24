import 'dart:convert';

class APopToyData {
  final int? id;
  final String? tipName;
  final int? tipType;
  final String? img;
  final String? gdesc;
  final int? itemPrice;

  APopToyData(
      {this.id,
      this.tipName,
      this.tipType,
      this.img,
      this.gdesc,
      this.itemPrice});

  factory APopToyData.fromRawJson(String str) =>
      APopToyData.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory APopToyData.fromJson(Map<String, dynamic> json) => APopToyData(
        id: json["id"],
        tipName: json["digxuw"],
        tipType: json["dvonxk"],
        img: json["img"],
        gdesc: json["gdesc"],
        itemPrice: json["koybww"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "digxuw": tipName,
        "dvonxk": tipType,
        "img": img,
        "gdesc": gdesc,
        "koybww": itemPrice,
      };
}
