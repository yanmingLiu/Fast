import "dart:convert";

class OrderData {
  final int? id;
  final String? orderNo;

  OrderData({this.id, this.orderNo});

  factory OrderData.fromRawJson(String str) => OrderData.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory OrderData.fromJson(Map<String, dynamic> json) =>
      OrderData(id: json["id"], orderNo: json["order_no"]);

  Map<String, dynamic> toJson() => {"id": id, "order_no": orderNo};
}
