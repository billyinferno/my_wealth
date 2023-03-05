// To parse this JSON data, do
//
//     final watchlistHistoryModel = watchlistHistoryModelFromJson(jsonString);

import 'dart:convert';

WatchlistHistoryModel watchlistHistoryModelFromJson(String str) => WatchlistHistoryModel.fromJson(json.decode(str));

String watchlistHistoryModelToJson(WatchlistHistoryModel data) => json.encode(data.toJson());

class WatchlistHistoryModel {
    WatchlistHistoryModel({
        required this.companyName,
        required this.watchlistCompanyId,
        required this.watchlistType,
        required this.watchlistDetailShare,
        required this.watchlistDetailPrice,
        required this.watchlistDetailDate,
    });

    String companyName;
    int watchlistCompanyId;
    String watchlistType;
    double watchlistDetailShare;
    double watchlistDetailPrice;
    DateTime watchlistDetailDate;

    factory WatchlistHistoryModel.fromJson(Map<String, dynamic> json) => WatchlistHistoryModel(
        companyName: json["company_name"],
        watchlistCompanyId: json["watchlist_company_id"],
        watchlistType: json["watchlist_type"],
        watchlistDetailShare: json["watchlist_detail_share"]?.toDouble(),
        watchlistDetailPrice: json["watchlist_detail_price"]?.toDouble(),
        watchlistDetailDate: DateTime.parse(json["watchlist_detail_date"]).toLocal(),
    );

    Map<String, dynamic> toJson() => {
        "company_name": companyName,
        "watchlist_company_id": watchlistCompanyId,
        "watchlist_type": watchlistType,
        "watchlist_detail_share": watchlistDetailShare,
        "watchlist_detail_price": watchlistDetailPrice,
        "watchlist_detail_date": watchlistDetailDate.toIso8601String(),
    };
}
