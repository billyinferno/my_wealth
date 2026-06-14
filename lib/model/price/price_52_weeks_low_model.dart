// To parse this JSON data, do
//
//     final price52WeeksLowModel = price52WeeksLowModelFromJson(jsonString);

import 'dart:convert';

Price52WeeksLowModel price52WeeksLowModelFromJson(String str) => Price52WeeksLowModel.fromJson(json.decode(str));

String price52WeeksLowModelToJson(Price52WeeksLowModel data) => json.encode(data.toJson());

class Price52WeeksLowModel {
    final String code;
    final int minPrice;
    final DateTime date;

    Price52WeeksLowModel({
        required this.code,
        required this.minPrice,
        required this.date,
    });

    factory Price52WeeksLowModel.fromJson(Map<String, dynamic> json) => Price52WeeksLowModel(
        code: json["code"],
        minPrice: json["min_price"],
        date: DateTime.parse(json["date"]),
    );

    Map<String, dynamic> toJson() => {
        "code": code,
        "min_price": minPrice,
        "date": "${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}",
    };
}
