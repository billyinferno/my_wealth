// To parse this JSON data, do
//
//     final favouritesListModel = favouritesListModelFromJson(jsonString);
import 'dart:convert';
import 'package:my_wealth/utils/extensions/string.dart';

FavouritesListModel favouritesListModelFromJson(String str) => FavouritesListModel.fromJson(json.decode(str));

String favouritesListModelToJson(FavouritesListModel data) => json.encode(data.toJson());

class FavouritesListModel {
    FavouritesListModel({
        required this.favouritesCompanyId,
        required this.favouritesCompanyName,
        required this.favouritesCompanyType,
        required this.favouritesNetAssetValue,
        this.favouritesCompanyYearlyRating,
        this.favouritesCompanyYearlyRisk,
        this.favouritesLastUpdate,
        this.favouritesId,
        this.favouritesUserId,
    });

    final int favouritesCompanyId;
    final String favouritesCompanyName;
    final String favouritesCompanyType;
    final double favouritesNetAssetValue;
    final double? favouritesCompanyYearlyRating;
    final double? favouritesCompanyYearlyRisk;
    final DateTime? favouritesLastUpdate;
    final int? favouritesId;
    final int? favouritesUserId;

    factory FavouritesListModel.fromJson(Map<String, dynamic> json) => FavouritesListModel(
        favouritesCompanyId: json["favourites_company_id"],
        favouritesCompanyName: json["favourites_company_name"].toString().toTitleCase(),
        favouritesCompanyType: json["favourites_company_type"],
        favouritesNetAssetValue: (json["favourites_net_asset_value"] == null ? 0 : json["favourites_net_asset_value"].toDouble()),
        favouritesCompanyYearlyRating: (json["favourites_company_yearly_rating"] == null ? 0 : json["favourites_company_yearly_rating"].toDouble()),
        favouritesCompanyYearlyRisk: (json["favourites_company_yearly_risk"] == null ? 0 : json["favourites_company_yearly_risk"].toDouble()),
        favouritesLastUpdate: (json["favourites_last_update"] == null ? null : DateTime.parse(json["favourites_last_update"])),
        favouritesId: json["favourites_id"],
        favouritesUserId: json["favourites_user_id"],
    );

    Map<String, dynamic> toJson() => {
        "favourites_company_id": favouritesCompanyId,
        "favourites_company_name": favouritesCompanyName,
        "favourites_company_type": favouritesCompanyType,
        "favourites_net_asset_value": favouritesNetAssetValue,
        "favourites_last_update": (favouritesLastUpdate == null ? null : favouritesLastUpdate!.toIso8601String()),
        "favourites_id": favouritesId,
        "favourites_user_id": favouritesUserId,
    };
}
