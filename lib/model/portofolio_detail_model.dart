// To parse this JSON data, do
//
//     final portofolioDetailModel = portofolioDetailModelFromJson(jsonString);

import 'dart:convert';

PortofolioDetailModel portofolioDetailModelFromJson(String str) => PortofolioDetailModel.fromJson(json.decode(str));

String portofolioDetailModelToJson(PortofolioDetailModel data) => json.encode(data.toJson());

class PortofolioDetailModel {
    PortofolioDetailModel({
        required this.companyName,
        required this.companyCode,
        required this.companyType,
        required this.watchlistSubTotalShare,
        required this.watchlistSubTotalCost,
        required this.watchlistSubTotalValue,
    });

    final String companyName;
    final String companyCode;
    final String companyType;
    final double watchlistSubTotalShare;
    final double watchlistSubTotalCost;
    final double watchlistSubTotalValue;

    factory PortofolioDetailModel.fromJson(Map<String, dynamic> json) => PortofolioDetailModel(
        companyName: json["company_name"],
        companyCode: json["company_code"],
        companyType: json["company_type"],
        watchlistSubTotalShare: json["watchlist_sub_total_share"].toDouble(),
        watchlistSubTotalCost: json["watchlist_sub_total_cost"].toDouble(),
        watchlistSubTotalValue: json["watchlist_sub_total_value"].toDouble(),
    );

    Map<String, dynamic> toJson() => {
        "company_name": companyName,
        "company_code": companyCode,
        "company_type": companyType,
        "watchlist_sub_total_share": watchlistSubTotalShare,
        "watchlist_sub_total_cost": watchlistSubTotalCost,
        "watchlist_sub_total_value": watchlistSubTotalValue,
    };
}
