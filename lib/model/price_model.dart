// To parse this JSON data, do
//
//     final priceModel = priceModelFromJson(jsonString);

import 'dart:convert';

PriceModel priceModelFromJson(String str) => PriceModel.fromJson(json.decode(str));

String priceModelToJson(PriceModel data) => json.encode(data.toJson());

class PriceModel {
    PriceModel({
        required this.id,
        required this.priceDate,
        required this.priceValue,
    });

    final int id;
    final DateTime priceDate;
    final double priceValue;

    factory PriceModel.fromJson(Map<String, dynamic> json) => PriceModel(
        id: json["id"],
        priceDate: DateTime.parse(json["price_date"]),
        priceValue: json["price_value"].toDouble(),
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "price_date": priceDate.toIso8601String(),
        "price_value": priceValue,
    };
}
