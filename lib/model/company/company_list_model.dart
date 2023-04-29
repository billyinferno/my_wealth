// To parse this JSON data, do
//
//     final companyListModel = companyListModelFromJson(jsonString);

import 'dart:convert';

CompanyListModel companyListModelFromJson(String str) => CompanyListModel.fromJson(json.decode(str));

String companyListModelToJson(CompanyListModel data) => json.encode(data.toJson());

class CompanyListModel {
    final int companyId;
    final String companyName;
    final String companyType;
    final String companySymbol;

    CompanyListModel({
        required this.companyId,
        required this.companyName,
        required this.companyType,
        required this.companySymbol,
    });

    factory CompanyListModel.fromJson(Map<String, dynamic> json) => CompanyListModel(
        companyId: json["company_id"],
        companyName: json["company_name"],
        companyType: json["company_type"],
        companySymbol: json["company_symbol"],
    );

    Map<String, dynamic> toJson() => {
        "company_id": companyId,
        "company_name": companyName,
        "company_type": companyType,
        "company_symbol": companySymbol,
    };
}
