// To parse this JSON data, do
//
//     final watchlistPriceFirstAndLastDateModel = watchlistPriceFirstAndLastDateModelFromJson(jsonString);

import 'dart:convert';

WatchlistPriceFirstAndLastDateModel watchlistPriceFirstAndLastDateModelFromJson(String str) => WatchlistPriceFirstAndLastDateModel.fromJson(json.decode(str));

String watchlistPriceFirstAndLastDateModelToJson(WatchlistPriceFirstAndLastDateModel data) => json.encode(data.toJson());

class WatchlistPriceFirstAndLastDateModel {
    final DateTime firstdate;
    final DateTime enddate;

    WatchlistPriceFirstAndLastDateModel({
        required this.firstdate,
        required this.enddate,
    });

    factory WatchlistPriceFirstAndLastDateModel.fromJson(Map<String, dynamic> json) => WatchlistPriceFirstAndLastDateModel(
        firstdate: DateTime.parse(json["firstdate"]),
        enddate: DateTime.parse(json["enddate"]),
    );

    Map<String, dynamic> toJson() => {
        "firstdate": firstdate.toIso8601String(),
        "enddate": enddate.toIso8601String(),
    };
}
