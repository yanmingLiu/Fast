import "dart:convert";

class BaseData<T> {
  final bool? success;
  final int? code;
  final String? message;
  final T? data;

  BaseData({this.success, this.code, this.message, this.data});

  factory BaseData.fromRawJson(String str, T Function(dynamic json)? fromJsonT) {
    return BaseData.fromJson(json.decode(str), fromJsonT);
  }

  String toRawJson() => json.encode(toJson());

  factory BaseData.fromJson(Map<String, dynamic> json, T Function(dynamic json)? fromJsonT) {
    return BaseData(
      success: json["success"],
      code: json["code"],
      message: json["cnainu"],
      data: _parseData<T>(json["data"], fromJsonT),
    );
  }

  Map<String, dynamic> toJson() => {
    "success": success,
    "code": code,
    "cnainu": message,
    "data": data,
  };

  static T? _parseData<T>(Object? json, T Function(dynamic json)? fromJsonT) {
    if (json == null) {
      return null;
    }

    if (fromJsonT != null) {
      // 如果是自定义类型，使用传入的解析函数
      return fromJsonT(json);
    }

    // 判断T是否是列表类型
    if (T == List && json is List) {
      // 返回列表，尝试使用内部类型的解析
      return json.map((item) => item as T).toList() as T;
    }

    // 默认的情况下，直接返回原始类型
    return json as T;
  }
}
