// To parse this JSON data, do
//
//     final portofolioDetailModel = portofolioDetailModelFromJson(jsonString);

import 'dart:convert';

PortofolioDetailModel portofolioDetailModelFromJson(String str) => PortofolioDetailModel.fromJson(json.decode(str));

String portofolioDetailModelToJson(PortofolioDetailModel data) => json.encode(data.toJson());

class PortofolioDetailModel {
    PortofolioDetailModel({
        required this.watchlistId,
        required this.companyName,
        required this.companyCode,
        required this.companyType,
        required this.companyNetAssetValue,
        required this.companyDailyReturn,
        required this.watchlistSubTotalShare,
        required this.watchlistSubTotalCost,
        required this.watchlistSubTotalValue,
        required this.watchlistSubTotalRealised,
        required this.watchlistSubTotalUnrealised,
    });

    final int watchlistId;
    final String companyName;
    final String companyCode;
    final String companyType;
    final double companyNetAssetValue;
    final double? companyDailyReturn;
    final double watchlistSubTotalShare;
    final double watchlistSubTotalCost;
    final double watchlistSubTotalValue;
    final double watchlistSubTotalRealised;
    final double watchlistSubTotalUnrealised;

    factory PortofolioDetailModel.fromJson(Map<String, dynamic> json) => PortofolioDetailModel(
        watchlistId: json["watchlist_id"],
        companyName: json["company_name"],
        companyCode: json["company_code"],
        companyType: json["company_type"],
        companyNetAssetValue: (json["company_net_asset_value"] == null ? -1 : json["company_net_asset_value"].toDouble()),
        companyDailyReturn: (json["company_daily_return"] == null ? 0 : json["company_daily_return"].toDouble()),
        watchlistSubTotalShare: json["watchlist_sub_total_share"].toDouble(),
        watchlistSubTotalCost: json["watchlist_sub_total_cost"].toDouble(),
        watchlistSubTotalValue: json["watchlist_sub_total_value"].toDouble(),
        watchlistSubTotalRealised: json["watchlist_sub_total_realised"].toDouble(),
        watchlistSubTotalUnrealised: json["watchlist_sub_total_unrealised"].toDouble(),
    );

    Map<String, dynamic> toJson() => {
        "watchlist_id": watchlistId,
        "company_name": companyName,
        "company_code": companyCode,
        "company_type": companyType,
        "company_net_asset_value": companyNetAssetValue,
        "company_daily_return": companyDailyReturn,
        "watchlist_sub_total_share": watchlistSubTotalShare,
        "watchlist_sub_total_cost": watchlistSubTotalCost,
        "watchlist_sub_total_value": watchlistSubTotalValue,
        "watchlist_sub_total_realised": watchlistSubTotalRealised,
        "watchlist_sub_total_unrealised": watchlistSubTotalUnrealised,
    };
}
