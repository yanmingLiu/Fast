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
    togsName: json["imftoj"],
    togsType: json["hsxufq"],
    img: json["img"],
    cdesc: json["cdesc"],
    itemPrice: json["koybww"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "togs_name": togsName,
    "hsxufq": togsType,
    "img": img,
    "cdesc": cdesc,
    "koybww": itemPrice,
  };
}

class ChangeClothe {
  final int? id;
  final int? clothingType;
  final String? modelId;

  ChangeClothe({this.id, this.clothingType, this.modelId});

  factory ChangeClothe.fromRawJson(String str) => ChangeClothe.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory ChangeClothe.fromJson(Map<String, dynamic> json) =>
      ChangeClothe(id: json["id"], clothingType: json["clothing_type"], modelId: json["loylzj"]);

  Map<String, dynamic> toJson() => {"id": id, "clothing_type": clothingType, "loylzj": modelId};
}
