// To parse this JSON data, do
//
//     final companyWeekdayPerformanceModel = companyWeekdayPerformanceModelFromJson(jsonString);

import 'dart:convert';

CompanyWeekdayPerformanceModel companyWeekdayPerformanceModelFromJson(String str) => CompanyWeekdayPerformanceModel.fromJson(json.decode(str));

String companyWeekdayPerformanceModelToJson(CompanyWeekdayPerformanceModel data) => json.encode(data.toJson());

class CompanyWeekdayPerformanceModel {
    final String code;
    final double ceil;
    final Map<String, WeekdayData> data;

    CompanyWeekdayPerformanceModel({
        required this.code,
        required this.ceil,
        required this.data,
    });

    factory CompanyWeekdayPerformanceModel.fromJson(Map<String, dynamic> json) => CompanyWeekdayPerformanceModel(
        code: json["code"],
        ceil: (json["ceil"] == null ? 0 : json["ceil"]?.toDouble()),
        data: Map.from(json["data"]).map((k, v) => MapEntry<String, WeekdayData>(k, WeekdayData.fromJson(v))),
    );

    Map<String, dynamic> toJson() => {
        "code": code,
        "ceil": ceil,
        "data": Map.from(data).map((k, v) => MapEntry<String, dynamic>(k, v.toJson())),
    };
}

class WeekdayData {
    final double average;
    final Map<String, int> list;

    WeekdayData({
        required this.average,
        required this.list,
    });

    factory WeekdayData.fromJson(Map<String, dynamic> json) => WeekdayData(
        average: (json["average"] == null ? 0 : json["average"]?.toDouble()),
        list: Map.from(json["list"]).map((k, v) => MapEntry<String, int>(k, v)),
    );

    Map<String, dynamic> toJson() => {
        "average": average,
        "list": Map.from(list).map((k, v) => MapEntry<String, dynamic>(k, v)),
    };
}
