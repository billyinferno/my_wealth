// To parse this JSON data, do
//
//     final portofolioSummaryModel = portofolioSummaryModelFromJson(jsonString);

import 'dart:convert';

PortofolioSummaryModel portofolioSummaryModelFromJson(String str) => PortofolioSummaryModel.fromJson(json.decode(str));

String portofolioSummaryModelToJson(PortofolioSummaryModel data) => json.encode(data.toJson());

class PortofolioSummaryModel {
    PortofolioSummaryModel({
        required this.portofolioCompanyType,
        required this.portofolioTotalProduct,
        required this.portofolioTotalShare,
        required this.portofolioTotalCost,
        required this.portofolioTotalValue,
    });

    final String portofolioCompanyType;
    final String portofolioTotalProduct;
    final double portofolioTotalShare;
    final double portofolioTotalCost;
    final double portofolioTotalValue;

    factory PortofolioSummaryModel.fromJson(Map<String, dynamic> json) => PortofolioSummaryModel(
        portofolioCompanyType: json["portofolio_company_type"],
        portofolioTotalProduct: json["portofolio_total_product"],
        portofolioTotalShare: json["portofolio_total_share"].toDouble(),
        portofolioTotalCost: json["portofolio_total_cost"].toDouble(),
        portofolioTotalValue: json["portofolio_total_value"].toDouble(),
    );

    Map<String, dynamic> toJson() => {
        "portofolio_company_type": portofolioCompanyType,
        "portofolio_total_product": portofolioTotalProduct,
        "portofolio_total_share": portofolioTotalShare,
        "portofolio_total_cost": portofolioTotalCost,
        "portofolio_total_value": portofolioTotalValue,
    };
}
