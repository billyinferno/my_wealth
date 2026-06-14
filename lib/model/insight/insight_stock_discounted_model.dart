// To parse this JSON data, do
//
//     final insightStockDiscountedModel = insightStockDiscountedModelFromJson(jsonString);

import 'dart:convert';

InsightStockDiscountedModel insightStockDiscountedModelFromJson(String str) => InsightStockDiscountedModel.fromJson(json.decode(str));

String insightStockDiscountedModelToJson(InsightStockDiscountedModel data) => json.encode(data.toJson());

class InsightStockDiscountedModel {
    final String code;
    final double lastPrice;
    final double priceNeutral;
    final double pbr;
    final double pbvNeutral;
    final double pbvDiff;
    final double priceDiff;
    final double avgDiff;

    InsightStockDiscountedModel({
        required this.code,
        required this.lastPrice,
        required this.priceNeutral,
        required this.pbr,
        required this.pbvNeutral,
        required this.pbvDiff,
        required this.priceDiff,
        required this.avgDiff,
    });

    factory InsightStockDiscountedModel.fromJson(Map<String, dynamic> json) => InsightStockDiscountedModel(
        code: json["code"],
        lastPrice: json["last_price"]?.toDouble(),
        priceNeutral: json["price_neutral"]?.toDouble(),
        pbr: json["pbr"]?.toDouble(),
        pbvNeutral: json["pbv_neutral"]?.toDouble(),
        pbvDiff: json["pbv_diff"]?.toDouble(),
        priceDiff: json["price_diff"]?.toDouble(),
        avgDiff: json["avg_diff"]?.toDouble(),
    );

    Map<String, dynamic> toJson() => {
        "code": code,
        "last_price": lastPrice,
        "price_neutral": priceNeutral,
        "pbr": pbr,
        "pbv_neutral": pbvNeutral,
        "pbv_diff": pbvDiff,
        "price_diff": priceDiff,
        "avg_diff": avgDiff,
    };
}
