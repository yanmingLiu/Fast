import 'dart:convert';

class ClothingData {
  final int? id;
  final String? togsName;
  final int? togsType;
  final String? img;
  final dynamic cdesc;
  final int? itemPrice;

  ClothingData({this.id, this.togsName, this.togsType, this.img, this.cdesc, this.itemPrice});

  factory ClothingData.fromRawJson(String str) => ClothingData.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory ClothingData.fromJson(Map<String, dynamic> json) => ClothingData(
    id: json["id"],
    togsName: json["togs_name"],
    togsType: json["togs_type"],
    img: json["img"],
    cdesc: json["cdesc"],
    itemPrice: json["item_price"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "togs_name": togsName,
    "togs_type": togsType,
    "img": img,
    "cdesc": cdesc,
    "item_price": itemPrice,
  };
}
