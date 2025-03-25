// To parse this JSON data, do
//
//     final indexPriceModel = indexPriceModelFromJson(jsonString);

import 'dart:convert';

import 'package:flutter/material.dart';

IndexPriceModel indexPriceModelFromJson(String str) => IndexPriceModel.fromJson(json.decode(str));

String indexPriceModelToJson(IndexPriceModel data) => json.encode(data.toJson());

class IndexPriceModel {
    IndexPriceModel({
        required this.indexPriceDate,
        required this.indexPriceValue,
        this.indexPriceDiff = 0,
        this.indexDayDiff = 0,
        this.indexColor = Colors.transparent,
    });

    final DateTime indexPriceDate;
    final double indexPriceValue;
    final double indexPriceDiff;
    final double indexDayDiff;
    final Color indexColor;

    factory IndexPriceModel.fromJson(Map<String, dynamic> json) => IndexPriceModel(
        indexPriceDate: DateTime.parse(json["index_price_date"]),
        indexPriceValue: json["index_price_value"].toDouble(),
    );

    Map<String, dynamic> toJson() => {
        "index_price_date": indexPriceDate.toIso8601String(),
        "index_price_value": indexPriceValue,
    };
}
