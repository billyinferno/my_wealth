// To parse this JSON data, do
//
//     final favouritesModel = favouritesModelFromJson(jsonString);

import 'dart:convert';

FavouritesModel favouritesModelFromJson(String str) => FavouritesModel.fromJson(json.decode(str));

String favouritesModelToJson(FavouritesModel data) => json.encode(data.toJson());

class FavouritesModel {
    FavouritesModel({
        required this.favouritesId,
        required this.favouritesCompanyId,
        required this.favouritesCompanyName,
        required this.favouritesSymbol,
        required this.favouritesNetAssetValue,
        required this.favouritesPrevAssetValue,
        required this.favouritesCompanyDailyReturn,
        required this.favouritesCompanyWeeklyReturn,
        required this.favouritesCompanyMonthlyReturn,
        required this.favouritesCompanyQuarterlyReturn,
        required this.favouritesCompanySemiAnnualReturn,
        required this.favouritesCompanyYTDReturn,
        required this.favouritesCompanyYearlyReturn,
        required this.favouritesLastUpdate,
    });

    final int favouritesId;
    final int favouritesCompanyId;
    final String favouritesCompanyName;
    final String favouritesSymbol;
    final double favouritesNetAssetValue;
    final double favouritesPrevAssetValue;
    final double favouritesCompanyDailyReturn;
    final double favouritesCompanyWeeklyReturn;
    final double favouritesCompanyMonthlyReturn;
    final double favouritesCompanyQuarterlyReturn;
    final double favouritesCompanySemiAnnualReturn;
    final double favouritesCompanyYTDReturn;
    final double favouritesCompanyYearlyReturn;
    final DateTime favouritesLastUpdate;

    factory FavouritesModel.fromJson(Map<String, dynamic> json) => FavouritesModel(
        favouritesId: json["favourites_id"],
        favouritesCompanyId: json["favourites_company_id"],
        favouritesCompanyName: json["favourites_company_name"].toString(),
        favouritesSymbol: json["favourites_symbol"].toString(),
        favouritesNetAssetValue: (json["favourites_net_asset_value"] == null ? 0 : json["favourites_net_asset_value"].toDouble()),
        favouritesPrevAssetValue: (json["favourites_prev_asset_value"] == null ? 0 : json["favourites_prev_asset_value"].toDouble()),
        favouritesCompanyDailyReturn: (json["favourites_company_daily_return"] == null ? 0 : json["favourites_company_daily_return"].toDouble()),
        favouritesCompanyWeeklyReturn: (json["favourites_company_weekly_return"] == null ? 0 : json["favourites_company_weekly_return"].toDouble()),
        favouritesCompanyMonthlyReturn: (json["favourites_company_monthly_return"] == null ? 0 : json["favourites_company_monthly_return"].toDouble()),
        favouritesCompanyQuarterlyReturn: (json["favourites_company_quarterly_return"] == null ? 0 : json["favourites_company_quarterly_return"].toDouble()),
        favouritesCompanySemiAnnualReturn: (json["favourites_company_semi_annual_return"] == null ? 0 : json["favourites_company_semi_annual_return"].toDouble()),
        favouritesCompanyYTDReturn: (json["favourites_company_ytd_return"] == null ? 0 : json["favourites_company_ytd_return"].toDouble()),
        favouritesCompanyYearlyReturn: (json["favourites_company_yearly_return"] == null ? 0 : json["favourites_company_yearly_return"].toDouble()),
        favouritesLastUpdate: DateTime.parse(json["favourites_last_update"]),
    );

    Map<String, dynamic> toJson() => {
        "favourites_id": favouritesId,
        "favourites_company_id": favouritesCompanyId,
        "favourites_company_name": favouritesCompanyName,
        "favourites_symbol": favouritesSymbol,
        "favourites_net_asset_value": favouritesNetAssetValue,
        "favourites_prev_asset_value": favouritesPrevAssetValue,
        "favourites_company_daily_return": favouritesCompanyDailyReturn,
        "favourites_company_weekly_return": favouritesCompanyWeeklyReturn,
        "favourites_company_monthly_return": favouritesCompanyMonthlyReturn,
        "favourites_company_quarterly_return": favouritesCompanyQuarterlyReturn,
        "favourites_company_semi_annual_return": favouritesCompanySemiAnnualReturn,
        "favourites_company_ytd_return": favouritesCompanyYTDReturn,
        "favourites_company_yearly_return": favouritesCompanyYearlyReturn,
        "favourites_last_update": favouritesLastUpdate.toIso8601String(),
    };
}
