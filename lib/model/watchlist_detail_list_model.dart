// To parse this JSON data, do
//
//     final watchlistDetailListModel = watchlistDetailListModelFromJson(jsonString);

import 'dart:convert';

WatchlistDetailListModel watchlistDetailListModelFromJson(String str) => WatchlistDetailListModel.fromJson(json.decode(str));

String watchlistDetailListModelToJson(WatchlistDetailListModel data) => json.encode(data.toJson());

class WatchlistDetailListModel {
    WatchlistDetailListModel({
        required this.watchlistDetailId,
        required this.watchlistDetailShare,
        required this.watchlistDetailPrice,
        required this.watchlistDetailDate,
    });

    final int watchlistDetailId;
    final double watchlistDetailShare;
    final double watchlistDetailPrice;
    final DateTime watchlistDetailDate;

    factory WatchlistDetailListModel.fromJson(Map<String, dynamic> json) => WatchlistDetailListModel(
        watchlistDetailId: json["watchlist_detail_id"],
        watchlistDetailShare: json["watchlist_detail_share"].toDouble(),
        watchlistDetailPrice: json["watchlist_detail_price"].toDouble(),
        watchlistDetailDate: DateTime.parse(json["watchlist_detail_date"]),
    );

    Map<String, dynamic> toJson() => {
        "watchlist_detail_id": watchlistDetailId,
        "watchlist_detail_share": watchlistDetailShare,
        "watchlist_detail_price": watchlistDetailPrice,
        "watchlist_detail_date": watchlistDetailDate.toIso8601String(),
    };
}
