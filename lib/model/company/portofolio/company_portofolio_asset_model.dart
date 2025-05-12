// To parse this JSON data, do
//
//     final companyPortofolioAssetModel = companyPortofolioAssetModelFromJson(jsonString);

import 'dart:convert';

CompanyPortofolioAssetModel companyPortofolioAssetModelFromJson(String str) => CompanyPortofolioAssetModel.fromJson(json.decode(str));

String companyPortofolioAssetModelToJson(CompanyPortofolioAssetModel data) => json.encode(data.toJson());

class CompanyPortofolioAssetModel {
    final String companyId;
    final DateTime? portofolioDate;
    final List<Portofolio> portofolio;

    CompanyPortofolioAssetModel({
        required this.companyId,
        required this.portofolioDate,
        required this.portofolio,
    });

    factory CompanyPortofolioAssetModel.fromJson(Map<String, dynamic> json) => CompanyPortofolioAssetModel(
        companyId: json["company_id"],
        portofolioDate: (json["portofolio_date"] != null ? DateTime.parse(json["portofolio_date"]) : null),
        portofolio: List<Portofolio>.from(json["portofolio"].map((x) => Portofolio.fromJson(x))),
    );

    Map<String, dynamic> toJson() => {
        "company_id": companyId,
        "portofolio_date": (portofolioDate != null ? "${portofolioDate!.year.toString().padLeft(4, '0')}-${portofolioDate!.month.toString().padLeft(2, '0')}-${portofolioDate!.day.toString().padLeft(2, '0')}" : null),
        "portofolio": List<dynamic>.from(portofolio.map((x) => x.toJson())),
    };
}

class Portofolio {
    final String name;
    final String code;
    final int type;
    final double value;

    Portofolio({
        required this.name,
        required this.code,
        required this.type,
        required this.value,
    });

    factory Portofolio.fromJson(Map<String, dynamic> json) => Portofolio(
        name: json["name"].toString().replaceAll(RegExp(r'&amp;'), '&'),
        code: (json["code"] ?? ''),
        type: json["type"],
        value: (json["value"] != null ? json["value"].toDouble() : 0),
    );

    Map<String, dynamic> toJson() => {
        "name": name,
        "code": code,
        "type": type,
        "value": value,
    };
}
