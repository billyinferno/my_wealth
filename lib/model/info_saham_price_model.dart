// To parse this JSON data, do
//
//     final infoSahamPriceModel = infoSahamPriceModelFromJson(jsonString);

import 'dart:convert';

InfoSahamPriceModel infoSahamPriceModelFromJson(String str) => InfoSahamPriceModel.fromJson(json.decode(str));

String infoSahamPriceModelToJson(InfoSahamPriceModel data) => json.encode(data.toJson());

class InfoSahamPriceModel {
    InfoSahamPriceModel({
        required this.date,
        required this.lastPrice,
        required this.prevClosingPrice,
        required this.adjustedClosingPrice,
        required this.adjustedOpenPrice,
        required this.adjustedHighPrice,
        required this.adjustedLowPrice,
        required this.volume,
    });

    final DateTime date;
    final int lastPrice;
    final int prevClosingPrice;
    final int adjustedClosingPrice;
    final int adjustedOpenPrice;
    final int adjustedHighPrice;
    final int adjustedLowPrice;
    final int volume;

    factory InfoSahamPriceModel.fromJson(Map<String, dynamic> json) => InfoSahamPriceModel(
        date: DateTime.parse(json["date"]),
        lastPrice: json["last_price"],
        prevClosingPrice: json["prev_closing_price"],
        adjustedClosingPrice: json["adjusted_closing_price"],
        adjustedOpenPrice: json["adjusted_open_price"],
        adjustedHighPrice: json["adjusted_high_price"],
        adjustedLowPrice: json["adjusted_low_price"],
        volume: json["volume"],
    );

    Map<String, dynamic> toJson() => {
        "date": "${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}",
        "last_price": lastPrice,
        "prev_closing_price": prevClosingPrice,
        "adjusted_closing_price": adjustedClosingPrice,
        "adjusted_open_price": adjustedOpenPrice,
        "adjusted_high_price": adjustedHighPrice,
        "adjusted_low_price": adjustedLowPrice,
        "volume": volume,
    };
}
