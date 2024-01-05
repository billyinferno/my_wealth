// To parse this JSON data, do
//
//     final marketCapModel = marketCapModelFromJson(jsonString);

import 'dart:convert';

MarketCapModel marketCapModelFromJson(String str) => MarketCapModel.fromJson(json.decode(str));

String marketCapModelToJson(MarketCapModel data) => json.encode(data.toJson());

class MarketCapModel {
    MarketCapModel({
        required this.code,
        required this.lastPrice,
        required this.capitalization,
        required this.shareOut,
    });

    String code;
    int lastPrice;
    double capitalization;
    int shareOut;

    factory MarketCapModel.fromJson(Map<String, dynamic> json) => MarketCapModel(
        code: json["code"],
        lastPrice: json["last_price"],
        capitalization: (json["capitalization"] == null ? 0 : json["capitalization"].toDouble()),
        shareOut: json["share_out"],
    );

    Map<String, dynamic> toJson() => {
        "code": code,
        "last_price": lastPrice,
        "capitalization": capitalization,
        "share_out": shareOut,
    };
}
