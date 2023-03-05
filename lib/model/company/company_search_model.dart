// To parse this JSON data, do
//
//     final companySearchModel = companySearchModelFromJson(jsonString);

import 'dart:convert';

CompanySearchModel companySearchModelFromJson(String str) => CompanySearchModel.fromJson(json.decode(str));

String companySearchModelToJson(CompanySearchModel data) => json.encode(data.toJson());

class CompanySearchModel {
    CompanySearchModel({
        required this.companyId,
        required this.companyName,
        this.companyNetAssetValue,
        this.companyPrevPrice,
        required this.companyLastUpdate,
        required this.companyCanAdd,
    });

    final int companyId;
    final String companyName;
    final double? companyNetAssetValue;
    final double? companyPrevPrice;
    final DateTime companyLastUpdate;
    final bool companyCanAdd;

    factory CompanySearchModel.fromJson(Map<String, dynamic> json) => CompanySearchModel(
        companyId: json["company_id"],
        companyName: json["company_name"].toString(),
        companyNetAssetValue: (json["company_net_asset_value"] == null ? 0 : json["company_net_asset_value"].toDouble()),
        companyPrevPrice: (json["company_prev_price"] == null ? 0 : json["company_prev_price"].toDouble()),
        companyLastUpdate: DateTime.parse(json["company_last_update"]),
        companyCanAdd: true,
    );

    Map<String, dynamic> toJson() => {
        "company_id": companyId,
        "company_name": companyName,
        "company_net_asset_value": companyNetAssetValue!,
        "company_last_update": companyLastUpdate.toIso8601String(),
    };
}
