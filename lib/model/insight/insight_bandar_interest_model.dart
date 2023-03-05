// To parse this JSON data, do
//
//     final insightBandarInterestModel = insightBandarInterestModelFromJson(jsonString);

import 'dart:convert';

InsightBandarInterestModel insightBandarInterestModelFromJson(String str) => InsightBandarInterestModel.fromJson(json.decode(str));

String insightBandarInterestModelToJson(InsightBandarInterestModel data) => json.encode(data.toJson());

class InsightBandarInterestModel {
    InsightBandarInterestModel({
        required this.atl,
        required this.nonAtl,
    });

    final List<BandarInterestAttributes> atl;
    final List<BandarInterestAttributes> nonAtl;

    factory InsightBandarInterestModel.fromJson(Map<String, dynamic> json) => InsightBandarInterestModel(
        atl: List<BandarInterestAttributes>.from(json["atl"].map((x) => BandarInterestAttributes.fromJson(x))),
        nonAtl: List<BandarInterestAttributes>.from(json["non_atl"].map((x) => BandarInterestAttributes.fromJson(x))),
    );

    Map<String, dynamic> toJson() => {
        "atl": List<dynamic>.from(atl.map((x) => x.toJson())),
        "non_atl": List<dynamic>.from(nonAtl.map((x) => x.toJson())),
    };
}

class BandarInterestAttributes {
    BandarInterestAttributes({
        required this.code,
        required this.name,
        required this.companyId,
        required this.lastPrice,
        required this.adjustedLowPrice,
        required this.adjustedHighPrice,
        required this.ma5,
        required this.ma8,
        required this.ma13,
        required this.ma20,
        required this.diffPrice,
        required this.min30Price,
        required this.isAtl30,
        required this.atl30Diff,
        required this.volume,
        required this.oneDay,
        required this.oneWeek,
        required this.oneMonth,
        required this.ytd,
        required this.diffHiLo,
    });

    final String code;
    final String name;
    final int companyId;
    final int lastPrice;
    final int adjustedLowPrice;
    final int adjustedHighPrice;
    final int ma5;
    final int ma8;
    final int ma13;
    final int ma20;
    final double diffPrice;
    final int min30Price;
    final bool isAtl30;
    final double atl30Diff;
    final String volume;
    final double oneDay;
    final double oneWeek;
    final double oneMonth;
    final double ytd;
    final double diffHiLo;

    factory BandarInterestAttributes.fromJson(Map<String, dynamic> json) => BandarInterestAttributes(
        code: json["code"],
        name: json["name"],
        companyId: json["company_id"],
        lastPrice: json["last_price"],
        adjustedLowPrice: json["adjusted_low_price"],
        adjustedHighPrice: json["adjusted_high_price"],
        ma5: json["ma5"],
        ma8: json["ma8"],
        ma13: json["ma13"],
        ma20: json["ma20"],
        diffPrice: json["diff_price"].toDouble(),
        min30Price: json["min30_price"],
        isAtl30: json["is_atl30"],
        atl30Diff: json["atl30_diff"].toDouble(),
        volume: json["volume"],
        oneDay: json["one_day"].toDouble(),
        oneWeek: json["one_week"].toDouble(),
        oneMonth: json["one_month"].toDouble(),
        ytd: json["ytd"].toDouble(),
        diffHiLo: json["diff_hi_lo"].toDouble(),
    );

    Map<String, dynamic> toJson() => {
        "code": code,
        "name": name,
        "company_id": companyId,
        "last_price": lastPrice,
        "adjusted_low_price": adjustedLowPrice,
        "adjusted_high_price": adjustedHighPrice,
        "ma5": ma5,
        "ma8": ma8,
        "ma13": ma13,
        "ma20": ma20,
        "diff_price": diffPrice,
        "min30_price": min30Price,
        "is_atl30": isAtl30,
        "atl30_diff": atl30Diff,
        "volume": volume,
        "one_day": oneDay,
        "one_week": oneWeek,
        "one_month": oneMonth,
        "ytd": ytd,
        "diff_hi_lo": diffHiLo,
    };
}
