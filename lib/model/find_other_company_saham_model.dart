// To parse this JSON data, do
//
//     final findOtherCommpanySahamModel = findOtherCommpanySahamModelFromJson(jsonString);

// ignore_for_file: prefer_null_aware_operators

import 'dart:convert';
import 'package:flutter/cupertino.dart';

FindOtherCommpanySahamModel findOtherCommpanySahamModelFromJson(String str) => FindOtherCommpanySahamModel.fromJson(json.decode(str));

String findOtherCommpanySahamModelToJson(FindOtherCommpanySahamModel data) => json.encode(data.toJson());

class FindOtherCommpanySahamModel {
    FindOtherCommpanySahamModel({
        required this.similar,
        required this.all,
    });

    List<OtherCompanyInfo> similar;
    List<OtherCompanyInfo> all;

    factory FindOtherCommpanySahamModel.fromJson(Map<String, dynamic> json) => FindOtherCommpanySahamModel(
        similar: List<OtherCompanyInfo>.from(json["similar"].map((x) => OtherCompanyInfo.fromJson(x))),
        all: List<OtherCompanyInfo>.from(json["all"].map((x) => OtherCompanyInfo.fromJson(x))),
    );

    Map<String, dynamic> toJson() => {
        "similar": List<dynamic>.from(similar.map((x) => x.toJson())),
        "all": List<dynamic>.from(all.map((x) => x.toJson())),
    };
}

class OtherCompanyInfo {
    OtherCompanyInfo({
        required this.name,
        required this.code,
        this.sectorName,
        this.subSectorName,
        this.industryName,
        this.oneYear,
        this.threeYear,
        this.fiveYear,
        this.tenYear,
    });

    String name;
    String code;
    String? sectorName;
    String? subSectorName;
    String? industryName;
    double? oneYear;
    double? threeYear;
    double? fiveYear;
    double? tenYear;
    final ScrollController controller = ScrollController();

    factory OtherCompanyInfo.fromJson(Map<String, dynamic> json) => OtherCompanyInfo(
        name: json["name"],
        code: json["code"],
        sectorName: json["sector_name"],
        subSectorName: json["sub_sector_name"],
        industryName: json["industry_name"],
        oneYear: (json["one_year"] != null ? json["one_year"].toDouble() : null),
        threeYear: (json["three_year"] != null ? json["three_year"].toDouble() : null),
        fiveYear: (json["five_year"] != null ? json["five_year"].toDouble() : null),
        tenYear: (json["ten_year"] != null ? json["ten_year"].toDouble() : null),
    );

    Map<String, dynamic> toJson() => {
        "name": name,
        "code": code,
        "sector_name": sectorName,
        "sub_sector_name": subSectorName,
        "industry_name": industryName,
        "one_year": oneYear,
        "three_year": threeYear,
        "five_year": fiveYear,
        "ten_year": tenYear,
    };
}
