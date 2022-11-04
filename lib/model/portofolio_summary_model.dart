// To parse this JSON data, do
//
//     final portofolioSummaryModel = portofolioSummaryModelFromJson(jsonString);

import 'dart:convert';

PortofolioSummaryModel portofolioSummaryModelFromJson(String str) => PortofolioSummaryModel.fromJson(json.decode(str));

String portofolioSummaryModelToJson(PortofolioSummaryModel data) => json.encode(data.toJson());

class PortofolioSummaryModel {
    PortofolioSummaryModel({
        required this.portofolioCompanyDescription,
        required this.portofolioCompanyType,
        required this.portofolioTotalProduct,
        required this.portofolioTotalShare,
        required this.portofolioTotalCost,
        required this.portofolioTotalValue,
        required this.portofolioTotalRealised,
        required this.portofolioTotalUnrealised,
    });

    final String portofolioCompanyDescription;
    final String portofolioCompanyType;
    final String portofolioTotalProduct;
    final double portofolioTotalShare;
    final double portofolioTotalCost;
    final double portofolioTotalValue;
    final double portofolioTotalRealised;
    final double portofolioTotalUnrealised;

    factory PortofolioSummaryModel.fromJson(Map<String, dynamic> json) => PortofolioSummaryModel(
        portofolioCompanyDescription: json["portofolio_company_description"],
        portofolioCompanyType: json["portofolio_company_type"],
        portofolioTotalProduct: json["portofolio_total_product"],
        portofolioTotalShare: json["portofolio_total_share"].toDouble(),
        portofolioTotalCost: json["portofolio_total_cost"].toDouble(),
        portofolioTotalValue: json["portofolio_total_value"].toDouble(),
        portofolioTotalRealised: json["portofolio_total_realised"].toDouble(),
        portofolioTotalUnrealised: json["portofolio_total_unrealised"].toDouble()
    );

    Map<String, dynamic> toJson() => {
        "portofolio_company_description": portofolioCompanyDescription,
        "portofolio_company_type": portofolioCompanyType,
        "portofolio_total_product": portofolioTotalProduct,
        "portofolio_total_share": portofolioTotalShare,
        "portofolio_total_cost": portofolioTotalCost,
        "portofolio_total_value": portofolioTotalValue,
        "portofolio_total_realised": portofolioTotalRealised,
        "portofolio_total_unrealised": portofolioTotalUnrealised,
    };
}
