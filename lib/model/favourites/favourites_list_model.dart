// To parse this JSON data, do
//
//     final favouritesListModel = favouritesListModelFromJson(jsonString);
import 'dart:convert';

FavouritesListModel favouritesListModelFromJson(String str) => FavouritesListModel.fromJson(json.decode(str));

String favouritesListModelToJson(FavouritesListModel data) => json.encode(data.toJson());

class FavouritesListModel {
    FavouritesListModel({
        required this.favouritesCompanyId,
        required this.favouritesCompanyName,
        required this.favouritesCompanyType,
        required this.favouritesSymbol,
        required this.favouritesNetAssetValue,
        this.favouritesCompanyYearlyRating,
        this.favouritesCompanyYearlyRisk,
        this.favouritesCompanyDailyReturn,
        this.favouritesCompanyWeeklyReturn,
        this.favouritesCompanyMonthlyReturn,
        this.favouritesCompanyQuarterlyReturn,
        this.favouritesCompanySemiAnnualReturn,
        this.favouritesCompanyYTDReturn,
        this.favouritesCompanyYearlyReturn,
        this.favouritesLastUpdate,
        this.favouritesFCA,
        this.favouritesId,
        this.favouritesUserId,
    });

    final int favouritesCompanyId;
    final String favouritesCompanyName;
    final String favouritesCompanyType;
    final String favouritesSymbol;
    final double favouritesNetAssetValue;
    final double? favouritesCompanyYearlyRating;
    final double? favouritesCompanyYearlyRisk;
    final double? favouritesCompanyDailyReturn;
    final double? favouritesCompanyWeeklyReturn;
    final double? favouritesCompanyMonthlyReturn;
    final double? favouritesCompanyQuarterlyReturn;
    final double? favouritesCompanySemiAnnualReturn;
    final double? favouritesCompanyYTDReturn;
    final double? favouritesCompanyYearlyReturn;
    final DateTime? favouritesLastUpdate;
    final bool? favouritesFCA;
    final int? favouritesId;
    final int? favouritesUserId;

    factory FavouritesListModel.fromJson(Map<String, dynamic> json) => FavouritesListModel(
        favouritesCompanyId: json["favourites_company_id"],
        favouritesCompanyName: json["favourites_company_name"].toString(),
        favouritesSymbol: json["favourites_symbol"].toString(),
        favouritesCompanyType: json["favourites_company_type"],
        favouritesNetAssetValue: (json["favourites_net_asset_value"] == null ? 0 : json["favourites_net_asset_value"].toDouble()),
        favouritesCompanyYearlyRating: (json["favourites_company_yearly_rating"] == null ? 0 : json["favourites_company_yearly_rating"].toDouble()),
        favouritesCompanyYearlyRisk: (json["favourites_company_yearly_risk"] == null ? 0 : json["favourites_company_yearly_risk"].toDouble()),
        favouritesCompanyDailyReturn: (json["favourites_company_daily_return"] == null ? 0 : json["favourites_company_daily_return"].toDouble()),
        favouritesCompanyWeeklyReturn: (json["favourites_company_weekly_return"] == null ? 0 : json["favourites_company_weekly_return"].toDouble()),
        favouritesCompanyMonthlyReturn: (json["favourites_company_monthly_return"] == null ? 0 : json["favourites_company_monthly_return"].toDouble()),
        favouritesCompanyQuarterlyReturn: (json["favourites_company_quarterly_return"] == null ? 0 : json["favourites_company_quarterly_return"].toDouble()),
        favouritesCompanySemiAnnualReturn: (json["favourites_company_semi_annual_return"] == null ? 0 : json["favourites_company_semi_annual_return"].toDouble()),
        favouritesCompanyYTDReturn: (json["favourites_company_ytd_return"] == null ? 0 : json["favourites_company_ytd_return"].toDouble()),
        favouritesCompanyYearlyReturn: (json["favourites_company_yearly_return"] == null ? 0 : json["favourites_company_yearly_return"].toDouble()),
        favouritesLastUpdate: (json["favourites_last_update"] == null ? null : DateTime.parse(json["favourites_last_update"])),
        favouritesFCA: (json["favourties_company_fca"] ?? false),
        favouritesId: json["favourites_id"],
        favouritesUserId: json["favourites_user_id"],
    );

    Map<String, dynamic> toJson() => {
        "favourites_company_id": favouritesCompanyId,
        "favourites_company_name": favouritesCompanyName,
        "favourites_symbol": favouritesSymbol,
        "favourites_company_type": favouritesCompanyType,
        "favourites_net_asset_value": favouritesNetAssetValue,
        "favourites_company_yearly_rating":favouritesCompanyYearlyRating,
        "favourites_company_yearly_risk":favouritesCompanyYearlyRisk,
        "favourites_company_daily_return":favouritesCompanyDailyReturn,
        "favourites_company_weekly_return":favouritesCompanyWeeklyReturn,
        "favourites_company_monthly_return":favouritesCompanyMonthlyReturn,
        "favourites_company_quarterly_return":favouritesCompanyQuarterlyReturn,
        "favourites_company_semi_annual_return":favouritesCompanySemiAnnualReturn,
        "favourites_company_ytd_return":favouritesCompanyYTDReturn,
        "favourites_company_yearly_return":favouritesCompanyYearlyReturn,
        "favourites_last_update": (favouritesLastUpdate?.toIso8601String()),
        "favourties_company_fca": favouritesFCA,
        "favourites_id": favouritesId,
        "favourites_user_id": favouritesUserId,
    };
}
