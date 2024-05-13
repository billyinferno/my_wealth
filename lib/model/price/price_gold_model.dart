// To parse this JSON data, do
//
//     final priceGoldModel = priceGoldModelFromJson(jsonString);

import 'dart:convert';

PriceGoldModel priceGoldModelFromJson(String str) => PriceGoldModel.fromJson(json.decode(str));

String priceGoldModelToJson(PriceGoldModel data) => json.encode(data.toJson());

class PriceGoldModel {
    final DateTime priceGoldDate;
    final double priceGoldIdr;
    final double priceGoldUsd;

    PriceGoldModel({
        required this.priceGoldDate,
        required this.priceGoldIdr,
        required this.priceGoldUsd,
    });

    factory PriceGoldModel.fromJson(Map<String, dynamic> json) => PriceGoldModel(
        priceGoldDate: DateTime.parse(json["price_gold_date"]),
        priceGoldIdr: json["price_gold_idr"]?.toDouble(),
        priceGoldUsd: json["price_gold_usd"]?.toDouble(),
    );

    Map<String, dynamic> toJson() => {
        "price_gold_date": "${priceGoldDate.year.toString().padLeft(4, '0')}-${priceGoldDate.month.toString().padLeft(2, '0')}-${priceGoldDate.day.toString().padLeft(2, '0')}",
        "price_gold_idr": priceGoldIdr,
        "price_gold_usd": priceGoldUsd,
    };
}
