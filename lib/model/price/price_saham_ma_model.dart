// To parse this JSON data, do
//
//     final priceSahamMovingAverage = priceSahamMovingAverageFromJson(jsonString);

import 'dart:convert';

PriceSahamMovingAverageModel priceSahamMovingAverageFromJson(String str) => PriceSahamMovingAverageModel.fromJson(json.decode(str));

String priceSahamMovingAverageToJson(PriceSahamMovingAverageModel data) => json.encode(data.toJson());

class PriceSahamMovingAverageModel {
    PriceSahamMovingAverageModel({
        required this.priceSahamCode,
        required this.priceSahamMa,
    });

    final String priceSahamCode;
    final PriceSahamMaElement priceSahamMa;

    factory PriceSahamMovingAverageModel.fromJson(Map<String, dynamic> json) => PriceSahamMovingAverageModel(
        priceSahamCode: json["price_saham_code"],
        priceSahamMa: PriceSahamMaElement.fromJson(json["price_saham_ma"]),
    );

    Map<String, dynamic> toJson() => {
        "price_saham_code": priceSahamCode,
        "price_saham_ma": priceSahamMa.toJson(),
    };
}

class PriceSahamMaElement {
    PriceSahamMaElement({
        required this.priceSahamMa5,
        required this.priceSahamMa8,
        required this.priceSahamMa13,
        required this.priceSahamMa20,
        required this.priceSahamMa30,
        required this.priceSahamMa50,
    });

    final int? priceSahamMa5;
    final int? priceSahamMa8;
    final int? priceSahamMa13;
    final int? priceSahamMa20;
    final int? priceSahamMa30;
    final int? priceSahamMa50;

    factory PriceSahamMaElement.fromJson(Map<String, dynamic> json) => PriceSahamMaElement(
        priceSahamMa5: json["price_saham_ma5"],
        priceSahamMa8: json["price_saham_ma8"],
        priceSahamMa13: json["price_saham_ma13"],
        priceSahamMa20: json["price_saham_ma20"],
        priceSahamMa30: json["price_saham_ma30"],
        priceSahamMa50: json["price_saham_ma50"],
    );

    Map<String, dynamic> toJson() => {
        "price_saham_ma5": priceSahamMa5,
        "price_saham_ma8": priceSahamMa8,
        "price_saham_ma13": priceSahamMa13,
        "price_saham_ma20": priceSahamMa20,
        "price_saham_ma30": priceSahamMa30,
        "price_saham_ma50": priceSahamMa50,
    };
}
