// To parse this JSON data, do
//
//     final companySahamSplitModel = companySahamSplitModelFromJson(jsonString);

import 'dart:convert';

CompanySahamSplitModel companySahamSplitModelFromJson(String str) => CompanySahamSplitModel.fromJson(json.decode(str));

String companySahamSplitModelToJson(CompanySahamSplitModel data) => json.encode(data.toJson());

class CompanySahamSplitModel {
    final String code;
    final List<SplitInfo> splits;

    CompanySahamSplitModel({
        required this.code,
        required this.splits,
    });

    factory CompanySahamSplitModel.fromJson(Map<String, dynamic> json) => CompanySahamSplitModel(
        code: json["code"],
        splits: List<SplitInfo>.from(json["splits"].map((x) => SplitInfo.fromJson(x))),
    );

    Map<String, dynamic> toJson() => {
        "code": code,
        "splits": List<dynamic>.from(splits.map((x) => x.toJson())),
    };
}

class SplitInfo {
    final String ratio;
    final double splitFactor;
    final double listedShares;
    final DateTime listingDate;

    SplitInfo({
        required this.ratio,
        required this.splitFactor,
        required this.listedShares,
        required this.listingDate,
    });

    factory SplitInfo.fromJson(Map<String, dynamic> json) => SplitInfo(
        ratio: json["ratio"],
        splitFactor: json["split_factor"]?.toDouble(),
        listedShares: json["listed_shares"]?.toDouble(),
        listingDate: DateTime.parse(json["listing_date"]),
    );

    Map<String, dynamic> toJson() => {
        "ratio": ratio,
        "split_factor": splitFactor,
        "listed_shares": listedShares,
        "listing_date": "${listingDate.year.toString().padLeft(4, '0')}-${listingDate.month.toString().padLeft(2, '0')}-${listingDate.day.toString().padLeft(2, '0')}",
    };
}
