// To parse this JSON data, do
//
//     final findOtherCommpanySahamModel = findOtherCommpanySahamModelFromJson(jsonString);

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
    });

    String name;
    String code;
    String? sectorName;
    String? subSectorName;
    String? industryName;
    final ScrollController controller = ScrollController();

    factory OtherCompanyInfo.fromJson(Map<String, dynamic> json) => OtherCompanyInfo(
        name: json["name"],
        code: json["code"],
        sectorName: json["sector_name"],
        subSectorName: json["sub_sector_name"],
        industryName: json["industry_name"],
    );

    Map<String, dynamic> toJson() => {
        "name": name,
        "code": code,
        "sector_name": sectorName,
        "sub_sector_name": subSectorName,
        "industry_name": industryName,
    };
}
