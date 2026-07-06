// To parse this JSON data, do
//
//     final brokerSummarySectorTopWorseListModel = brokerSummarySectorTopWorseListModelFromJson(jsonString);

import 'dart:convert';

BrokerSummarySectorTopWorseListModel brokerSummarySectorTopWorseListModelFromJson(String str) => BrokerSummarySectorTopWorseListModel.fromJson(json.decode(str));

String brokerSummarySectorTopWorseListModelToJson(BrokerSummarySectorTopWorseListModel data) => json.encode(data.toJson());

class BrokerSummarySectorTopWorseListModel {
    final BrokerSummarySectorTopWorseListData foreign;
    final BrokerSummarySectorTopWorseListData domestic;
    final BrokerSummarySectorTopWorseListData all;
    BrokerSummarySectorTopWorseListModel({
        required this.foreign,
        required this.domestic,
        required this.all,
    });

    factory BrokerSummarySectorTopWorseListModel.fromJson(Map<String, dynamic> json) => BrokerSummarySectorTopWorseListModel(
        foreign: BrokerSummarySectorTopWorseListData.fromJson(json["foreign"]),
        domestic: BrokerSummarySectorTopWorseListData.fromJson(json["domestic"]),
        all: BrokerSummarySectorTopWorseListData.fromJson(json["all"]),
    );

    Map<String, dynamic> toJson() => {
        "foreign": foreign.toJson(),
        "domestic": domestic.toJson(),
        "all": all.toJson(),
    };
}

class BrokerSummarySectorTopWorseListData {
    final List<BrokerSummarySectorTopWorseListDetail> top;
    final List<BrokerSummarySectorTopWorseListDetail> worse;

    BrokerSummarySectorTopWorseListData({
        required this.top,
        required this.worse,
    });

    factory BrokerSummarySectorTopWorseListData.fromJson(Map<String, dynamic> json) => BrokerSummarySectorTopWorseListData(
        top: List<BrokerSummarySectorTopWorseListDetail>.from(json["top"].map((x) => BrokerSummarySectorTopWorseListDetail.fromJson(x))),
        worse: List<BrokerSummarySectorTopWorseListDetail>.from(json["worse"].map((x) => BrokerSummarySectorTopWorseListDetail.fromJson(x))),
    );

    Map<String, dynamic> toJson() => {
        "top": List<dynamic>.from(top.map((x) => x.toJson())),
        "worse": List<dynamic>.from(worse.map((x) => x.toJson())),
    };
}

class BrokerSummarySectorTopWorseListDetail {
    final String code;
    final int totalBuyLot;
    final int totalBuyValue;
    final int totalSellLot;
    final int totalSellValue;
    final int totalNetLot;
    final int totalNetValue;

    BrokerSummarySectorTopWorseListDetail({
        required this.code,
        required this.totalBuyLot,
        required this.totalBuyValue,
        required this.totalSellLot,
        required this.totalSellValue,
        required this.totalNetLot,
        required this.totalNetValue,
    });

    factory BrokerSummarySectorTopWorseListDetail.fromJson(Map<String, dynamic> json) => BrokerSummarySectorTopWorseListDetail(
        code: json["code"],
        totalBuyLot: json["total_buy_lot"],
        totalBuyValue: json["total_buy_value"],
        totalSellLot: json["total_sell_lot"],
        totalSellValue: json["total_sell_value"],
        totalNetLot: json["total_net_lot"],
        totalNetValue: json["total_net_value"],
    );

    Map<String, dynamic> toJson() => {
        "code": code,
        "total_buy_lot": totalBuyLot,
        "total_buy_value": totalBuyValue,
        "total_sell_lot": totalSellLot,
        "total_sell_value": totalSellValue,
        "total_net_lot": totalNetLot,
        "total_net_value": totalNetValue,
    };
}
