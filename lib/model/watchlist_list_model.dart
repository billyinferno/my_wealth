// To parse this JSON data, do
//
//     final watchlistListModel = watchlistListModelFromJson(jsonString);
import 'dart:convert';
import 'package:my_wealth/utils/extensions/string.dart';
import 'package:my_wealth/model/watchlist_detail_list_model.dart';

WatchlistListModel watchlistListModelFromJson(String str) => WatchlistListModel.fromJson(json.decode(str));

String watchlistListModelToJson(WatchlistListModel data) => json.encode(data.toJson());

class WatchlistListModel {
    WatchlistListModel({
        required this.watchlistId,
        required this.watchlistCompanyId,
        required this.watchlistCompanyName,
        this.watchlistCompanyNetAssetValue,
        this.watchlistCompanyPrevPrice,
        required this.watchlistDetail,
    });

    final int watchlistId;
    final int watchlistCompanyId;
    final String watchlistCompanyName;
    final double? watchlistCompanyNetAssetValue;
    final double? watchlistCompanyPrevPrice;
    final List<WatchlistDetailListModel> watchlistDetail;

    factory WatchlistListModel.fromJson(Map<String, dynamic> json) => WatchlistListModel(
        watchlistId: json["watchlist_id"],
        watchlistCompanyId: json["watchlist_company_id"],
        watchlistCompanyName: json["watchlist_company_name"].toString().toTitleCase(),
        watchlistCompanyNetAssetValue: (json["watchlist_company_net_asset_value"] == null ? 0 : json["watchlist_company_net_asset_value"].toDouble()),
        watchlistCompanyPrevPrice: (json["watchlist_company_prev_price"] == null ? 0 : json["watchlist_company_prev_price"].toDouble()),
        watchlistDetail: List<WatchlistDetailListModel>.from(json["watchlist_detail"].map((x) => WatchlistDetailListModel.fromJson(x))),
    );

    Map<String, dynamic> toJson() => {
        "watchlist_id": watchlistId,
        "watchlist_company_id": watchlistCompanyId,
        "watchlist_company_name": watchlistCompanyName,
        "watchlist_company_net_asset_value": watchlistCompanyNetAssetValue!,
        "watchlist_company_prev_price": watchlistCompanyPrevPrice!,
        "watchlist_detail": List<dynamic>.from(watchlistDetail.map((x) => x.toJson())),
    };
}
