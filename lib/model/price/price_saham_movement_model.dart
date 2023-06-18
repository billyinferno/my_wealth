// To parse this JSON data, do
//
//     final priceSahamMovementModel = priceSahamMovementModelFromJson(jsonString);

import 'dart:convert';

PriceSahamMovementModel priceSahamMovementModelFromJson(String str) =>
    PriceSahamMovementModel.fromJson(json.decode(str));

String priceSahamMovementModelToJson(PriceSahamMovementModel data) =>
    json.encode(data.toJson());

class PriceSahamMovementModel {
  final String code;
  final List<Price> prices;

  PriceSahamMovementModel({
    required this.code,
    required this.prices,
  });

  factory PriceSahamMovementModel.fromJson(Map<String, dynamic> json) =>
      PriceSahamMovementModel(
        code: json["code"],
        prices: List<Price>.from(json["prices"].map((x) => Price.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "code": code,
        "prices": List<dynamic>.from(prices.map((x) => x.toJson())),
      };
}

class Price {
  final String date;
  final double minPrice;
  final double maxPrice;
  final double avgPrice;

  Price({
    required this.date,
    required this.minPrice,
    required this.maxPrice,
    required this.avgPrice,
  });

  factory Price.fromJson(Map<String, dynamic> json) => Price(
        date: json["date"],
        minPrice: json["min_price"]?.toDouble(),
        maxPrice: json["max_price"]?.toDouble(),
        avgPrice: json["avg_price"]?.toDouble(),
      );

  Map<String, dynamic> toJson() => {
        "date": date,
        "min_price": minPrice,
        "max_price": maxPrice,
        "avg_price": avgPrice,
      };
}
