// To parse this JSON data, do
//
//     final companySahamSectorIndustryAverageModel = companySahamSectorIndustryAverageModelFromJson(jsonString);

import 'dart:convert';

CompanySahamSectorIndustryAverageModel companySahamSectorIndustryAverageModelFromJson(String str) => CompanySahamSectorIndustryAverageModel.fromJson(json.decode(str));

String companySahamSectorIndustryAverageModelToJson(CompanySahamSectorIndustryAverageModel data) => json.encode(data.toJson());

class CompanySahamSectorIndustryAverageModel {
    final String code;
    final Data data;

    CompanySahamSectorIndustryAverageModel({
        required this.code,
        required this.data,
    });

    factory CompanySahamSectorIndustryAverageModel.fromJson(Map<String, dynamic> json) => CompanySahamSectorIndustryAverageModel(
        code: json["code"],
        data: Data.fromJson(json["data"]),
    );

    Map<String, dynamic> toJson() => {
        "code": code,
        "data": data.toJson(),
    };
}

class Data {
    final double avgSector;
    final double avgSubSector;
    final double avgIndustry;
    final double avgSubIndustry;

    Data({
        required this.avgSector,
        required this.avgSubSector,
        required this.avgIndustry,
        required this.avgSubIndustry,
    });

    factory Data.fromJson(Map<String, dynamic> json) => Data(
        avgSector: json["avg_sector"]?.toDouble(),
        avgSubSector: json["avg_sub_sector"]?.toDouble(),
        avgIndustry: json["avg_industry"]?.toDouble(),
        avgSubIndustry: json["avg_sub_industry"]?.toDouble(),
    );

    Map<String, dynamic> toJson() => {
        "avg_sector": avgSector,
        "avg_sub_sector": avgSubSector,
        "avg_industry": avgIndustry,
        "avg_sub_industry": avgSubIndustry,
    };
}
