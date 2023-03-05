// To parse this JSON data, do
//
//     final indexBeaterModel = indexBeaterModelFromJson(jsonString);

import 'dart:convert';

IndexBeaterModel indexBeaterModelFromJson(String str) => IndexBeaterModel.fromJson(json.decode(str));

String indexBeaterModelToJson(IndexBeaterModel data) => json.encode(data.toJson());

class IndexBeaterModel {
    IndexBeaterModel({
        required this.code,
        required this.name,
        required this.lastPrice,
        this.prevClosingPrice,
        required this.oneDay,
        required this.oneWeek,
        required this.mtd,
        required this.oneMonth,
        required this.threeMonth,
        required this.sixMonth,
        required this.ytd,
        required this.oneYear,
    });

    String code;
    String name;
    int lastPrice;
    int? prevClosingPrice;
    double oneDay;
    double oneWeek;
    double mtd;
    double oneMonth;
    double threeMonth;
    double sixMonth;
    double ytd;
    double oneYear;

    factory IndexBeaterModel.fromJson(Map<String, dynamic> json) => IndexBeaterModel(
        code: json["code"],
        name: json["name"],
        lastPrice: json["last_price"],
        prevClosingPrice: (json["prev_closing_price"] ?? json["last_price"]),
        oneDay: (json["one_day"] == null ? 0 : json["one_day"].toDouble()),
        oneWeek: (json["one_week"] == null ? 0 : json["one_week"].toDouble()),
        mtd: (json["mtd"] == null ? 0 : json["mtd"].toDouble()),
        oneMonth: (json["one_month"] == null ? 0 : json["one_month"].toDouble()),
        threeMonth: (json["one_month"] == null ? 0 : json["one_month"].toDouble()),
        sixMonth: (json["six_month"] == null ? 0 : json["six_month"].toDouble()),
        ytd: (json["ytd"] == null ? 0 : json["ytd"].toDouble()),
        oneYear: (json["one_year"] == null ? 0 : json["one_year"].toDouble()),
    );

    Map<String, dynamic> toJson() => {
        "code": code,
        "name": name,
        "last_price": lastPrice,
        "prev_closing_price": prevClosingPrice,
        "one_day": oneDay,
        "one_week": oneWeek,
        "mtd": mtd,
        "one_month": oneMonth,
        "three_month": threeMonth,
        "six_month": sixMonth,
        "ytd": ytd,
        "one_year": oneYear,
    };
}
