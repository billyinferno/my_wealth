// To parse this JSON data, do
//
//     final favouritesModel = favouritesModelFromJson(jsonString);

import 'dart:convert';
import 'package:my_wealth/utils/extensions/string.dart';

FavouritesModel favouritesModelFromJson(String str) => FavouritesModel.fromJson(json.decode(str));

String favouritesModelToJson(FavouritesModel data) => json.encode(data.toJson());

class FavouritesModel {
    FavouritesModel({
        required this.favouritesId,
        required this.favouritesCompanyId,
        required this.favouritesCompanyName,
        required this.favouritesNetAssetValue,
        required this.favouritesPrevAssetValue,
        required this.favouritesCompanyDailyReturn,
        required this.favouritesLastUpdate,
    });

    final int favouritesId;
    final int favouritesCompanyId;
    final String favouritesCompanyName;
    final double favouritesNetAssetValue;
    final double favouritesPrevAssetValue;
    final double favouritesCompanyDailyReturn;
    final DateTime favouritesLastUpdate;

    factory FavouritesModel.fromJson(Map<String, dynamic> json) => FavouritesModel(
        favouritesId: json["favourites_id"],
        favouritesCompanyId: json["favourites_company_id"],
        favouritesCompanyName: json["favourites_company_name"].toString().toTitleCase(),
        favouritesNetAssetValue: (json["favourites_net_asset_value"] == null ? 0 : json["favourites_net_asset_value"].toDouble()),
        favouritesPrevAssetValue: (json["favourites_prev_asset_value"] == null ? 0 : json["favourites_prev_asset_value"].toDouble()),
        favouritesCompanyDailyReturn: (json["favourites_company_daily_return"] == null ? 0 : json["favourites_company_daily_return"].toDouble()),
        favouritesLastUpdate: DateTime.parse(json["favourites_last_update"]),
    );

    Map<String, dynamic> toJson() => {
        "favourites_id": favouritesId,
        "favourites_company_id": favouritesCompanyId,
        "favourites_company_name": favouritesCompanyName,
        "favourites_net_asset_value": favouritesNetAssetValue,
        "favourites_prev_asset_value": favouritesPrevAssetValue,
        "favourites_company_daily_return": favouritesCompanyDailyReturn,
        "favourites_last_update": favouritesLastUpdate.toIso8601String(),
    };
}
