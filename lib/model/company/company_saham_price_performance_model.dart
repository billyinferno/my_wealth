// To parse this JSON data, do
//
//     final companySahamPricePerformanceModel = companySahamPricePerformanceModelFromJson(jsonString);

import 'dart:convert';

CompanySahamPricePerformanceModel companySahamPricePerformanceModelFromJson(String str) => CompanySahamPricePerformanceModel.fromJson(json.decode(str));

String companySahamPricePerformanceModelToJson(CompanySahamPricePerformanceModel data) => json.encode(data.toJson());

class CompanySahamPricePerformanceModel {
    final String code;
    final PricePerformance pricePerformance;

    CompanySahamPricePerformanceModel({
        required this.code,
        required this.pricePerformance,
    });

    factory CompanySahamPricePerformanceModel.fromJson(Map<String, dynamic> json) => CompanySahamPricePerformanceModel(
        code: json["code"],
        pricePerformance: PricePerformance.fromJson(json["price_performance"]),
    );

    Map<String, dynamic> toJson() => {
        "code": code,
        "price_performance": pricePerformance.toJson(),
    };
}

class PricePerformance {
    final MinMaxData? the1D;
    final MinMaxData? the1W;
    final MinMaxData? the1M;
    final MinMaxData? the3M;
    final MinMaxData? the6M;
    final MinMaxData? the1Y;
    final MinMaxData? the3Y;
    final MinMaxData? the5Y;
    final MinMaxData? the10Y;
    final MinMaxData? theMTD;
    final MinMaxData? theYTD;

    PricePerformance({
        required this.the1D,
        required this.the1W,
        required this.the1M,
        required this.the3M,
        required this.the6M,
        required this.the1Y,
        required this.the3Y,
        required this.the5Y,
        required this.the10Y,
        required this.theMTD,
        required this.theYTD,
    });

    factory PricePerformance.fromJson(Map<String, dynamic> json) => PricePerformance(
        the1D: json["1D"] == null ? null : MinMaxData.fromJson(json["1D"]),
        the1W: json["1W"] == null ? null : MinMaxData.fromJson(json["1W"]),
        the1M: json["1M"] == null ? null : MinMaxData.fromJson(json["1M"]),
        the3M: json["3M"] == null ? null : MinMaxData.fromJson(json["3M"]),
        the6M: json["6M"] == null ? null : MinMaxData.fromJson(json["6M"]),
        the1Y: json["1Y"] == null ? null : MinMaxData.fromJson(json["1Y"]),
        the3Y: json["3Y"] == null ? null : MinMaxData.fromJson(json["3Y"]),
        the5Y: json["5Y"] == null ? null : MinMaxData.fromJson(json["5Y"]),
        the10Y: json["10Y"] == null ? null : MinMaxData.fromJson(json["10Y"]),
        theMTD: json["MTD"] == null ? null : MinMaxData.fromJson(json["MTD"]),
        theYTD: json["YTD"] == null ? null : MinMaxData.fromJson(json["YTD"]),
    );

    Map<String, dynamic> toJson() => {
        "1D": the1D?.toJson(),
        "1W": the1W?.toJson(),
        "1M": the1M?.toJson(),
        "3M": the3M?.toJson(),
        "6M": the6M?.toJson(),
        "1Y": the1Y?.toJson(),
        "3Y": the3Y?.toJson(),
        "5Y": the5Y?.toJson(),
        "10Y": the10Y?.toJson(),
        "MTD": theMTD?.toJson(),
        "YTD": theYTD?.toJson(),
    };
}

class MinMaxData {
    final int min;
    final int max;

    MinMaxData({
        required this.min,
        required this.max,
    });

    factory MinMaxData.fromJson(Map<String, dynamic> json) => MinMaxData(
        min: json["min"],
        max: json["max"],
    );

    Map<String, dynamic> toJson() => {
        "min": min,
        "max": max,
    };
}
