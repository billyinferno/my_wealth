// To parse this JSON data, do
//
//     final stockSplitListModel = stockSplitListModelFromJson(jsonString);
import 'dart:convert';

StockSplitListModel stockSplitListModelFromJson(String str) => StockSplitListModel.fromJson(json.decode(str));

String stockSplitListModelToJson(StockSplitListModel data) => json.encode(data.toJson());

class StockSplitListModel {
    StockSplitListModel({
        required this.id,
        required this.code,
        required this.name,
        required this.ratio,
        required this.nomimal,
        required this.nominalNew,
        required this.listedShares,
        required this.listingDate,
        required this.lastPrice,
    });

    final int id;
    final String code;
    final String name;
    final String ratio;
    final int? nomimal;
    final int? nominalNew;
    final int? listedShares;
    final DateTime? listingDate;
    final int? lastPrice;

    factory StockSplitListModel.fromJson(Map<String, dynamic> json) => StockSplitListModel(
        id: json["id"],
        code: json["code"],
        name: json["name"],
        ratio: json["ratio"],
        nomimal: (json["nomimal"] ?? 0),
        nominalNew: (json["nominal_new"] ?? 0),
        listedShares: (json["listed_shares"] ?? 0),
        listingDate: (json["listing_date"] != null ? DateTime.parse(json["listing_date"]).toLocal() : null),
        lastPrice: (json["last_price"] ?? 0),
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "code": code,
        "name": name,
        "ratio": ratio,
        "nomimal": nomimal,
        "nominal_new": nominalNew,
        "listed_shares": listedShares,
        "listing_date": (listingDate != null ? "${listingDate!.year.toString().padLeft(4, '0')}-${listingDate!.month.toString().padLeft(2, '0')}-${listingDate!.day.toString().padLeft(2, '0')}" : null),
        "last_price": lastPrice,
    };
}
