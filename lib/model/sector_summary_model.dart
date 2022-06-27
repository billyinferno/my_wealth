// To parse this JSON data, do
//
//     final sectorSummaryModel = sectorSummaryModelFromJson(jsonString);

import 'dart:convert';

SectorSummaryModel sectorSummaryModelFromJson(String str) => SectorSummaryModel.fromJson(json.decode(str));

String sectorSummaryModelToJson(SectorSummaryModel data) => json.encode(data.toJson());

class SectorSummaryModel {
    SectorSummaryModel({
        required this.sectorName,
        required this.sectorAverage,
    });

    final String sectorName;
    final SectorAverage sectorAverage;

    factory SectorSummaryModel.fromJson(Map<String, dynamic> json) => SectorSummaryModel(
        sectorName: json["sector_name"],
        sectorAverage: SectorAverage.fromJson(json["sector_average"]),
    );

    Map<String, dynamic> toJson() => {
        "sector_name": sectorName,
        "sector_average": sectorAverage.toJson(),
    };
}

class SectorAverage {
    SectorAverage({
        required this.the1D,
        required this.the1W,
        required this.the1M,
        required this.the3M,
        required this.the6M,
        required this.theYTD,
        required this.the1Y,
        required this.the3Y,
        required this.the5Y,
    });

    final double the1D;
    final double the1W;
    final double the1M;
    final double the3M;
    final double the6M;
    final double theYTD;
    final double the1Y;
    final double the3Y;
    final double the5Y;

    factory SectorAverage.fromJson(Map<String, dynamic> json) => SectorAverage(
        the1D: json["1d"].toDouble(),
        the1W: json["1w"].toDouble(),
        the1M: json["1m"].toDouble(),
        the3M: json["3m"].toDouble(),
        the6M: json["6m"].toDouble(),
        theYTD: json["ytd"].toDouble(),
        the1Y: json["1y"].toDouble(),
        the3Y: json["3y"].toDouble(),
        the5Y: json["5y"].toDouble(),
    );

    Map<String, dynamic> toJson() => {
        "1d": the1D,
        "1w": the1W,
        "1m": the1M,
        "3m": the3M,
        "6m": the6M,
        "ytd": theYTD,
        "1y": the1Y,
        "3y": the3Y,
        "5y": the5Y,
    };
}
