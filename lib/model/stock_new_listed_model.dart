// To parse this JSON data, do
//
//     final stockNewListedModel = stockNewListedModelFromJson(jsonString);

import 'dart:convert';

StockNewListedModel stockNewListedModelFromJson(String str) => StockNewListedModel.fromJson(json.decode(str));

String stockNewListedModelToJson(StockNewListedModel data) => json.encode(data.toJson());

class StockNewListedModel {
    StockNewListedModel({
        required this.id,
        required this.code,
        required this.name,
        required this.listedShares,
        required this.numOfShares,
        required this.nominal,
        required this.offering,
        required this.fundRaised,
        required this.listedDate,
        required this.currentPrice,
    });

    final int id;
    final String code;
    final String name;
    final int? listedShares;
    final int? numOfShares;
    final int? nominal;
    final int? offering;
    final int? fundRaised;
    final DateTime? listedDate;
    final int? currentPrice;

    factory StockNewListedModel.fromJson(Map<String, dynamic> json) => StockNewListedModel(
        id: json["id"],
        code: json["code"],
        name: json["name"],
        listedShares: (json["listed_shares"] ?? 0),
        numOfShares: (json["num_of_shares"] ?? 0),
        nominal: (json["nominal"] ?? 0),
        offering: (json["offering"] ?? 0),
        fundRaised: (json["fund_raised"] ?? 0),
        listedDate: (json["listed_date"] != null ? DateTime.parse(json["listed_date"]).toLocal() : null),
        currentPrice: (json["current_price"] ?? 0),
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "code": code,
        "name": name,
        "listed_shares": listedShares,
        "num_of_shares": numOfShares,
        "nominal": nominal,
        "offering": offering,
        "fund_raised": fundRaised,
        "listed_date": (listedDate != null ? "${listedDate!.year.toString().padLeft(4, '0')}-${listedDate!.month.toString().padLeft(2, '0')}-${listedDate!.day.toString().padLeft(2, '0')}" : null),
        "current_price": currentPrice,
    };
}
