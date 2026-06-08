// To parse this JSON data, do
//
//     final priceDiffSahamModel = priceDiffSahamModelFromJson(jsonString);

import 'dart:convert';

PriceDiffSahamModel priceDiffSahamModelFromJson(String str) => PriceDiffSahamModel.fromJson(json.decode(str));

String priceDiffSahamModelToJson(PriceDiffSahamModel data) => json.encode(data.toJson());

class PriceDiffSahamModel {
    final DateTime date;
    final double lastPrice;
    final double avgPrice;
    final double minPrice;
    final double maxPrice;

    PriceDiffSahamModel({
        required this.date,
        required this.lastPrice,
        required this.avgPrice,
        required this.minPrice,
        required this.maxPrice,
    });

    factory PriceDiffSahamModel.fromJson(Map<String, dynamic> json) => PriceDiffSahamModel(
        date: DateTime.parse(json["date"]),
        lastPrice: json["last_price"]?.toDouble(),
        avgPrice: json["avg_price"]?.toDouble(),
        minPrice: json["min_price"]?.toDouble(),
        maxPrice: json["max_price"]?.toDouble(),
    );

    Map<String, dynamic> toJson() => {
        "date": "${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}",
        "last_price": lastPrice,
        "avg_price": avgPrice,
        "min_price": minPrice,
        "max_price": maxPrice,
    };
}
