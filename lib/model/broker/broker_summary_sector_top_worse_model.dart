// To parse this JSON data, do
//
//     final brokerSummarySectorTopWorseModel = brokerSummarySectorTopWorseModelFromJson(jsonString);

import 'dart:convert';

BrokerSummarySectorTopWorseModel brokerSummarySectorTopWorseModelFromJson(String str) => BrokerSummarySectorTopWorseModel.fromJson(json.decode(str));

String brokerSummarySectorTopWorseModelToJson(BrokerSummarySectorTopWorseModel data) => json.encode(data.toJson());

class BrokerSummarySectorTopWorseModel {
    final BrokerSectorTopWorseType foreign;
    final BrokerSectorTopWorseType domestic;

    BrokerSummarySectorTopWorseModel({
        required this.foreign,
        required this.domestic,
    });

    factory BrokerSummarySectorTopWorseModel.fromJson(Map<String, dynamic> json) => BrokerSummarySectorTopWorseModel(
        foreign: BrokerSectorTopWorseType.fromJson(json["foreign"]),
        domestic: BrokerSectorTopWorseType.fromJson(json["domestic"]),
    );

    Map<String, dynamic> toJson() => {
        "foreign": foreign.toJson(),
        "domestic": domestic.toJson(),
    };
}

class BrokerSectorTopWorseType {
    final List<BrokerSectorTopWorseData> top;
    final List<BrokerSectorTopWorseData> worse;

    BrokerSectorTopWorseType({
        required this.top,
        required this.worse,
    });

    factory BrokerSectorTopWorseType.fromJson(Map<String, dynamic> json) => BrokerSectorTopWorseType(
        top: List<BrokerSectorTopWorseData>.from(json["top"].map((x) => BrokerSectorTopWorseData.fromJson(x))),
        worse: List<BrokerSectorTopWorseData>.from(json["worse"].map((x) => BrokerSectorTopWorseData.fromJson(x))),
    );

    Map<String, dynamic> toJson() => {
        "top": List<dynamic>.from(top.map((x) => x.toJson())),
        "worse": List<dynamic>.from(worse.map((x) => x.toJson())),
    };
}

class BrokerSectorTopWorseData {
    final String code;
    final int totalBuyValue;
    final int totalSellValue;
    final int totalNet;

    BrokerSectorTopWorseData({
        required this.code,
        required this.totalBuyValue,
        required this.totalSellValue,
        required this.totalNet,
    });

    factory BrokerSectorTopWorseData.fromJson(Map<String, dynamic> json) => BrokerSectorTopWorseData(
        code: json["code"],
        totalBuyValue: json["total_buy_value"],
        totalSellValue: json["total_sell_value"],
        totalNet: json["total_net"],
    );

    Map<String, dynamic> toJson() => {
        "code": code,
        "total_buy_value": totalBuyValue,
        "total_sell_value": totalSellValue,
        "total_net": totalNet,
    };
}
