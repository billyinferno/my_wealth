// To parse this JSON data, do
//
//     final watchlistListModel = watchlistListModelFromJson(jsonString);
import 'dart:convert';
import 'package:my_wealth/model/watchlist/watchlist_detail_list_model.dart';

WatchlistListModel watchlistListModelFromJson(String str) => WatchlistListModel.fromJson(json.decode(str));

String watchlistListModelToJson(WatchlistListModel data) => json.encode(data.toJson());

class WatchlistListModel {
    WatchlistListModel({
        required this.watchlistId,
        required this.watchlistCompanyId,
        required this.watchlistCompanyName,
        required this.watchlistCompanySymbol,
        required this.watchlistCompanyNetAssetValue,
        required this.watchlistCompanyPrevPrice,
        required this.watchlistCompanyLastUpdate,
        required this.watchlistFavouriteId,
        required this.watchlistDetail,
    });

    final int watchlistId;
    final int watchlistCompanyId;
    final String watchlistCompanyName;
    final String? watchlistCompanySymbol;
    final double? watchlistCompanyNetAssetValue;
    final double? watchlistCompanyPrevPrice;
    final DateTime? watchlistCompanyLastUpdate;
    final int watchlistFavouriteId;
    final List<WatchlistDetailListModel> watchlistDetail;

    factory WatchlistListModel.fromJson(Map<String, dynamic> json) => WatchlistListModel(
        watchlistId: json["watchlist_id"],
        watchlistCompanyId: json["watchlist_company_id"],
        watchlistCompanyName: json["watchlist_company_name"].toString(),
        watchlistCompanySymbol: json["watchlist_company_symbol"].toString(),
        watchlistCompanyNetAssetValue: (json["watchlist_company_net_asset_value"] == null ? 0 : json["watchlist_company_net_asset_value"].toDouble()),
        watchlistCompanyPrevPrice: (json["watchlist_company_prev_price"] == null ? 0 : json["watchlist_company_prev_price"].toDouble()),
        watchlistCompanyLastUpdate: (json["watchlist_company_last_update"] == null ? null : DateTime.parse(json["watchlist_company_last_update"])),
        watchlistFavouriteId: json["watchlist_favourite_id"],
        watchlistDetail: List<WatchlistDetailListModel>.from(json["watchlist_detail"].map((x) => WatchlistDetailListModel.fromJson(x))),
    );

    Map<String, dynamic> toJson() => {
        "watchlist_id": watchlistId,
        "watchlist_company_id": watchlistCompanyId,
        "watchlist_company_name": watchlistCompanyName,
        "watchlist_company_symbol": watchlistCompanySymbol,
        "watchlist_company_net_asset_value": watchlistCompanyNetAssetValue!,
        "watchlist_company_prev_price": watchlistCompanyPrevPrice!,
        "watchlist_company_last_update": (watchlistCompanyLastUpdate ?? watchlistCompanyLastUpdate!.toIso8601String()),
        "watchlist_favourite_id": watchlistFavouriteId,
        "watchlist_detail": List<dynamic>.from(watchlistDetail.map((x) => x.toJson())),
    };
}
