// To parse this JSON data, do
//
//     final watchlistPerformanceYearModel = watchlistPerformanceYearModelFromJson(jsonString);

// ignore_for_file: prefer_null_aware_operators

import 'dart:convert';

WatchlistPerformanceYearModel watchlistPerformanceYearModelFromJson(String str) => WatchlistPerformanceYearModel.fromJson(json.decode(str));

String watchlistPerformanceYearModelToJson(WatchlistPerformanceYearModel data) => json.encode(data.toJson());

class WatchlistPerformanceYearModel {
    final String priceDate;
    final double? watchlistTotalShare;
    final double? watchlistTotalAmount;
    final double? watchlistTotalAvg;
    final double priceAvg;

    WatchlistPerformanceYearModel({
        required this.priceDate,
        this.watchlistTotalShare,
        this.watchlistTotalAmount,
        this.watchlistTotalAvg,
        required this.priceAvg,
    });

    factory WatchlistPerformanceYearModel.fromJson(Map<String, dynamic> json) => WatchlistPerformanceYearModel(
        priceDate: json["price_date"],
        watchlistTotalShare: (json["watchlist_total_share"] == null ? null : json["watchlist_total_share"].toDouble()),
        watchlistTotalAmount: (json["watchlist_total_amount"] == null ? null : json["watchlist_total_amount"].toDouble()),
        watchlistTotalAvg: (json["watchlist_total_avg"] == null ? null : json["watchlist_total_avg"].toDouble()),
        priceAvg: (json["price_avg"] == null ? 0 : json["price_avg"].toDouble()),
    );

    Map<String, dynamic> toJson() => {
        "price_date": priceDate,
        "watchlist_total_share": watchlistTotalShare,
        "watchlist_total_amount": watchlistTotalAmount,
        "watchlist_total_avg": watchlistTotalAvg,
        "price_avg": priceAvg,
    };
}
