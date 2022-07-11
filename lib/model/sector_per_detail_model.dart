// To parse this JSON data, do
//
//     final sectorPerDetailModel = sectorPerDetailModelFromJson(jsonString);

import 'dart:convert';

SectorPerDetailModel sectorPerDetailModelFromJson(String str) => SectorPerDetailModel.fromJson(json.decode(str));

String sectorPerDetailModelToJson(SectorPerDetailModel data) => json.encode(data.toJson());

class SectorPerDetailModel {
    SectorPerDetailModel({
        required this.averagePerDaily,
        required this.averagePerPeriodatic,
        required this.averagePerAnnualized,
        required this.codeList,
    });

    final double averagePerDaily;
    final double averagePerPeriodatic;
    final double averagePerAnnualized;
    final List<CodeList> codeList;

    factory SectorPerDetailModel.fromJson(Map<String, dynamic> json) => SectorPerDetailModel(
        averagePerDaily: json["average_per_daily"].toDouble(),
        averagePerPeriodatic: json["average_per_periodatic"].toDouble(),
        averagePerAnnualized: json["average_per_annualized"].toDouble(),
        codeList: List<CodeList>.from(json["code_list"].map((x) => CodeList.fromJson(x))),
    );

    Map<String, dynamic> toJson() => {
        "average_per_daily": averagePerDaily,
        "average_per_periodatic": averagePerPeriodatic,
        "average_per_annualized": averagePerAnnualized,
        "code_list": List<dynamic>.from(codeList.map((x) => x.toJson())),
    };
}

class CodeList {
    CodeList({
        required this.name,
        required this.code,
        required this.perDaily,
        required this.perPeriodatic,
        required this.perAnnualized,
        required this.period,
        required this.year,
    });

    final String name;
    final String code;
    final double? perDaily;
    final double? perPeriodatic;
    final double? perAnnualized;
    final int? period;
    final int? year;

    factory CodeList.fromJson(Map<String, dynamic> json) => CodeList(
        name: json["name"],
        code: json["code"],
        perDaily: (json["per_daily"] ?? json["per_daily"].toDouble()),
        perPeriodatic: (json["per_periodatic"] ?? json["per_periodatic"].toDouble()),
        perAnnualized: (json["per_annualized"] ?? json["per_annualized"].toDouble()),
        period: json["period"],
        year: json["year"],
    );

    Map<String, dynamic> toJson() => {
        "name": name,
        "code": code,
        "per_daily": perDaily,
        "per_periodatic": perPeriodatic,
        "per_annualized": perAnnualized,
        "period": period,
        "year": year,
    };
}
