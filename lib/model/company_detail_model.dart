// To parse this JSON data, do
//
//     final companyDetailModel = companyDetailModelFromJson(jsonString);

// ignore_for_file: prefer_null_aware_operators

import 'dart:convert';
import 'package:my_wealth/model/price_model.dart';

CompanyDetailModel companyDetailModelFromJson(String str) => CompanyDetailModel.fromJson(json.decode(str));

String companyDetailModelToJson(CompanyDetailModel data) => json.encode(data.toJson());

class CompanyDetailModel {
    CompanyDetailModel({
        required this.companyId,
        required this.companyName,
        required this.companyType,
        required this.companySharia,
        this.companyNetAssetValue,
        this.companyPrevPrice,
        this.companyDailyReturn,
        this.companyWeeklyReturn,
        this.companyMonthlyReturn,
        this.companyQuarterlyReturn,
        this.companySemiAnnualReturn,
        this.companyYtdReturn,
        this.companyYearlyReturn,
        this.companyLastUpdate,
        this.companyAssetUnderManagement,
        this.companyTotalUnit,
        this.companyYearlyRating,
        this.companyYearlyRisk,
        required this.companyPrices,
    });

    final int companyId;
    final String companyName;
    final String companyType;
    final bool companySharia;
    final double? companyNetAssetValue;
    final double? companyPrevPrice;
    final double? companyDailyReturn;
    final double? companyWeeklyReturn;
    final double? companyMonthlyReturn;
    final double? companyQuarterlyReturn;
    final double? companySemiAnnualReturn;
    final double? companyYtdReturn;
    final double? companyYearlyReturn;
    final DateTime? companyLastUpdate;
    final double? companyAssetUnderManagement;
    final double? companyTotalUnit;
    final double? companyYearlyRating;
    final double? companyYearlyRisk;
    final List<PriceModel> companyPrices;

    factory CompanyDetailModel.fromJson(Map<String, dynamic> json) {
      return CompanyDetailModel(
        companyId: json["company_id"],
        companyName: json["company_name"],
        companyType: json["company_type"],
        companySharia: json["company_sharia"],
        companyNetAssetValue: (json["company_net_asset_value"] == null ? 0 : json["company_net_asset_value"].toDouble()),
        companyPrevPrice: (json["company_prev_price"] == null ? 0 : json["company_prev_price"].toDouble()),
        companyDailyReturn: (json["company_daily_return"] == null ? 0 : json["company_daily_return"].toDouble()),
        companyWeeklyReturn: (json["company_weekly_return"] == null ? 0 : json["company_weekly_return"].toDouble()),
        companyMonthlyReturn: (json["company_monthly_return"] == null ? 0 : json["company_monthly_return"].toDouble()),
        companyQuarterlyReturn: (json["company_quarterly_return"] == null ? 0 : json["company_quarterly_return"].toDouble()),
        companySemiAnnualReturn: (json["company_semi_annual_return"] == null ? 0 : json["company_semi_annual_return"].toDouble()),
        companyYtdReturn: (json["company_ytd_return"] == null ? 0 : json["company_ytd_return"].toDouble()),
        companyYearlyReturn: (json["company_yearly_return"] == null ? 0 : json["company_yearly_return"].toDouble()),
        companyLastUpdate: (json["company_last_update"] == null ? null : DateTime.parse(json["company_last_update"])),
        companyAssetUnderManagement: (json["company_asset_under_management"] == null ? 0 : json["company_asset_under_management"].toDouble()),
        companyTotalUnit: (json["company_total_unit"] == null ? 0 : json["company_total_unit"].toDouble()),
        companyYearlyRating: (json["company_yearly_rating"] == null ? null : json["company_yearly_rating"].toDouble()),
        companyYearlyRisk: (json["company_yearly_risk"] == null ? null : json["company_yearly_risk"].toDouble()),
        companyPrices: List<PriceModel>.from(json["company_prices"].map((x) => PriceModel.fromJson(x))),
      );
    }

    Map<String, dynamic> toJson() => {
        "company_id": companyId,
        "company_name": companyName,
        "company_type": companyType,
        "company_sharia": companySharia,
        "company_net_asset_value": companyNetAssetValue,
        "company_prev_price": companyPrevPrice,
        "company_daily_return": companyDailyReturn,
        "company_weekly_return": companyWeeklyReturn,
        "company_monthly_return": companyMonthlyReturn,
        "company_quarterly_return": companyQuarterlyReturn,
        "company_semi_annual_return": companySemiAnnualReturn,
        "company_ytd_return": companyYtdReturn,
        "company_yearly_return": companyYearlyReturn,
        "company_last_update": (companyLastUpdate == null ? null : companyLastUpdate!.toIso8601String()),
        "company_asset_under_management": companyAssetUnderManagement,
        "company_total_unit": companyTotalUnit,
        "company_yearly_rating": companyYearlyRating,
        "company_yearly_risk": companyYearlyRisk,
        "company_prices": List<dynamic>.from(companyPrices.map((x) => x.toJson())),
    };
}
