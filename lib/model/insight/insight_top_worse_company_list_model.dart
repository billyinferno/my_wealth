// To parse this JSON data, do
//
//     final topWorseCompanyListModel = topWorseCompanyListModelFromJson(jsonString);

import 'dart:convert';

TopWorseCompanyListModel topWorseCompanyListModelFromJson(String str) => TopWorseCompanyListModel.fromJson(json.decode(str));

String topWorseCompanyListModelToJson(TopWorseCompanyListModel data) => json.encode(data.toJson());

class TopWorseCompanyListModel {
    TopWorseCompanyListModel({
        required this.companyList,
    });

    final CompanyList companyList;

    factory TopWorseCompanyListModel.fromJson(Map<String, dynamic> json) => TopWorseCompanyListModel(
        companyList: CompanyList.fromJson(json["company_list"]),
    );

    Map<String, dynamic> toJson() => {
        "company_list": companyList.toJson(),
    };
}

class CompanyList {
    CompanyList({
        required this.the1D,
        required this.the1W,
        required this.theMTD,
        required this.the1M,
        required this.the3M,
        required this.the6M,
        required this.the1Y,
        required this.the3Y,
        required this.the5Y,
        required this.theYTD,
    });

    final List<CompanyInfo> the1D;
    final List<CompanyInfo> the1W;
    final List<CompanyInfo> theMTD;
    final List<CompanyInfo> the1M;
    final List<CompanyInfo> the3M;
    final List<CompanyInfo> the6M;
    final List<CompanyInfo> the1Y;
    final List<CompanyInfo> the3Y;
    final List<CompanyInfo> the5Y;
    final List<CompanyInfo> theYTD;

    factory CompanyList.fromJson(Map<String, dynamic> json) => CompanyList(
        the1D: List<CompanyInfo>.from(json["1d"].map((x) => CompanyInfo.fromJson(x))),
        the1W: List<CompanyInfo>.from(json["1w"].map((x) => CompanyInfo.fromJson(x))),
        theMTD: List<CompanyInfo>.from(json["mtd"].map((x) => CompanyInfo.fromJson(x))),
        the1M: List<CompanyInfo>.from(json["1m"].map((x) => CompanyInfo.fromJson(x))),
        the3M: List<CompanyInfo>.from(json["3m"].map((x) => CompanyInfo.fromJson(x))),
        the6M: List<CompanyInfo>.from(json["6m"].map((x) => CompanyInfo.fromJson(x))),
        the1Y: List<CompanyInfo>.from(json["1y"].map((x) => CompanyInfo.fromJson(x))),
        the3Y: List<CompanyInfo>.from(json["3y"].map((x) => CompanyInfo.fromJson(x))),
        the5Y: List<CompanyInfo>.from(json["5y"].map((x) => CompanyInfo.fromJson(x))),
        theYTD: List<CompanyInfo>.from(json["ytd"].map((x) => CompanyInfo.fromJson(x))),
    );

    Map<String, dynamic> toJson() => {
        "1d": List<dynamic>.from(the1D.map((x) => x.toJson())),
        "1w": List<dynamic>.from(the1W.map((x) => x.toJson())),
        "mtd": List<dynamic>.from(theMTD.map((x) => x.toJson())),
        "1m": List<dynamic>.from(the1M.map((x) => x.toJson())),
        "3m": List<dynamic>.from(the3M.map((x) => x.toJson())),
        "6m": List<dynamic>.from(the6M.map((x) => x.toJson())),
        "1y": List<dynamic>.from(the1Y.map((x) => x.toJson())),
        "3y": List<dynamic>.from(the3Y.map((x) => x.toJson())),
        "5y": List<dynamic>.from(the5Y.map((x) => x.toJson())),
        "ytd": List<dynamic>.from(theYTD.map((x) => x.toJson())),
    };
}

class CompanyInfo {
    CompanyInfo({
        required this.companySahamId,
        required this.name,
        required this.code,
        required this.gain,
    });

    final int companySahamId;
    final String name;
    final String code;
    final double gain;

    factory CompanyInfo.fromJson(Map<String, dynamic> json) => CompanyInfo(
        companySahamId: json["company_saham_id"],
        name: json["name"],
        code: json["code"],
        gain: json["gain"].toDouble(),
    );

    Map<String, dynamic> toJson() => {
        "company_saham_id": companySahamId,
        "name": name,
        "code": code,
        "gain": gain,
    };
}
