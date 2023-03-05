// To parse this JSON data, do
//
//     final indexPriceModel = indexPriceModelFromJson(jsonString);

import 'dart:convert';

IndexPriceModel indexPriceModelFromJson(String str) => IndexPriceModel.fromJson(json.decode(str));

String indexPriceModelToJson(IndexPriceModel data) => json.encode(data.toJson());

class IndexPriceModel {
    IndexPriceModel({
        required this.indexPriceDate,
        required this.indexPriceValue,
    });

    final DateTime indexPriceDate;
    final double indexPriceValue;

    factory IndexPriceModel.fromJson(Map<String, dynamic> json) => IndexPriceModel(
        indexPriceDate: DateTime.parse(json["index_price_date"]),
        indexPriceValue: json["index_price_value"].toDouble(),
    );

    Map<String, dynamic> toJson() => {
        "index_price_date": indexPriceDate.toIso8601String(),
        "index_price_value": indexPriceValue,
    };
}
