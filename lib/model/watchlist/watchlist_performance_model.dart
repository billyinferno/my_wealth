// To parse this JSON data, do
//
//     final watchlistPerformanceModel = watchlistPerformanceModelFromJson(jsonString);

import 'dart:convert';

WatchlistPerformanceModel watchlistPerformanceModelFromJson(String str) => WatchlistPerformanceModel.fromJson(json.decode(str));

String watchlistPerformanceModelToJson(WatchlistPerformanceModel data) => json.encode(data.toJson());

class WatchlistPerformanceModel {
    WatchlistPerformanceModel({
        required this.buyDate,
        required this.buyTotal,
        required this.buyAmount,
        required this.buyAvg,
        this.realizedPL = 0,
        required this.currentPrice,
    });

    DateTime buyDate;
    double buyTotal;
    double buyAmount;
    double buyAvg;
    double realizedPL;
    double currentPrice;

    factory WatchlistPerformanceModel.fromJson(Map<String, dynamic> json) => WatchlistPerformanceModel(
        buyDate: DateTime.parse(json["buy_date"]),
        buyTotal: json["buy_total"].toDouble(),
        buyAmount: json["buy_amount"].toDouble(),
        buyAvg: json["buy_avg"].toDouble(),
        realizedPL: (json["realized_pl"] != null ? json["realized_pl"].toDouble() : 0),
        currentPrice: json["current_price"].toDouble(),
    );

    Map<String, dynamic> toJson() => {
        "buy_date": "${buyDate.year.toString().padLeft(4, '0')}-${buyDate.month.toString().padLeft(2, '0')}-${buyDate.day.toString().padLeft(2, '0')}",
        "buy_total": buyTotal,
        "buy_amount": buyAmount,
        "buy_avg": buyAvg,
        "realized_pl": realizedPL,
        "current_price": currentPrice,
    };
}
