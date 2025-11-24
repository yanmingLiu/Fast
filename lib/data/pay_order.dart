import "dart:convert";

class PayOrder {
  final int? id;
  final String? orderNo;

  PayOrder({this.id, this.orderNo});

  factory PayOrder.fromRawJson(String str) =>
      PayOrder.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory PayOrder.fromJson(Map<String, dynamic> json) =>
      PayOrder(id: json["id"], orderNo: json["order_no"]);

  Map<String, dynamic> toJson() => {"id": id, "order_no": orderNo};
}
