import 'dart:convert';

class ToysData {
  final int? id;
  final String? tipName;
  final int? tipType;
  final String? img;
  final String? gdesc;
  final int? itemPrice;

  ToysData({this.id, this.tipName, this.tipType, this.img, this.gdesc, this.itemPrice});

  factory ToysData.fromRawJson(String str) => ToysData.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory ToysData.fromJson(Map<String, dynamic> json) => ToysData(
    id: json["id"],
    tipName: json["gname"],
    tipType: json["gtype"],
    img: json["img"],
    gdesc: json["gdesc"],
    itemPrice: json["price"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "gname": tipName,
    "gtype": tipType,
    "img": img,
    "gdesc": gdesc,
    "price": itemPrice,
  };
}
