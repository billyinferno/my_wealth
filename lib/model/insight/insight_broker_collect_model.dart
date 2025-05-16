// To parse this JSON data, do
//
//     final insightBrokerCollectModel = insightBrokerCollectModelFromJson(jsonString);

import 'dart:convert';

InsightBrokerCollectModel insightBrokerCollectModelFromJson(String str) => InsightBrokerCollectModel.fromJson(json.decode(str));

String insightBrokerCollectModelToJson(InsightBrokerCollectModel data) => json.encode(data.toJson());

class InsightBrokerCollectModel {
    final String brokerSummaryId;
    final int summaryTotalBuy;
    final int summaryTotalBuyValue;
    final int summaryCountBuy;
    final int summaryTotalSell;
    final int summaryTotalSellValue;
    final int summaryCountSell;
    final int summaryTotalLeft;
    final List<BrokerCollectCompany> data;

    InsightBrokerCollectModel({
        required this.brokerSummaryId,
        required this.summaryTotalBuy,
        required this.summaryTotalBuyValue,
        required this.summaryCountBuy,
        required this.summaryTotalSell,
        required this.summaryTotalSellValue,
        required this.summaryCountSell,
        required this.summaryTotalLeft,
        required this.data,
    });

    factory InsightBrokerCollectModel.fromJson(Map<String, dynamic> json) => InsightBrokerCollectModel(
        brokerSummaryId: json["broker_summary_id"],
        summaryTotalBuy: json["summary_total_buy"],
        summaryTotalBuyValue: json["summary_total_buy_value"],
        summaryCountBuy: json["summary_count_buy"],
        summaryTotalSell: json["summary_total_sell"],
        summaryTotalSellValue: json["summary_total_sell_value"],
        summaryCountSell: json["summary_count_sell"],
        summaryTotalLeft: json["summary_total_left"],
        data: List<BrokerCollectCompany>.from(json["data"].map((x) => BrokerCollectCompany.fromJson(x))),
    );

    Map<String, dynamic> toJson() => {
        "broker_summary_id": brokerSummaryId,
        "summary_total_buy": summaryTotalBuy,
        "summary_total_buy_value": summaryTotalBuyValue,
        "summary_count_buy": summaryCountBuy,
        "summary_total_sell": summaryTotalSell,
        "summary_total_sell_value": summaryTotalSellValue,
        "summary_count_sell": summaryCountSell,
        "summary_total_left": summaryTotalLeft,
        "data": List<dynamic>.from(data.map((x) => x.toJson())),
    };
}

class BrokerCollectCompany {
    final String code;
    final String name;
    final bool fca;
    final int lastPrice;
    final int totalBuy;
    final int totalBuyValue;
    final double totalBuyAvg;
    final int countBuy;
    final int totalSell;
    final int totalSellValue;
    final double totalSellAvg;
    final int countSell;
    final int totalLeft;
    final double totalPercentage;

    BrokerCollectCompany({
        required this.code,
        required this.name,
        required this.fca,
        required this.lastPrice,
        required this.totalBuy,
        required this.totalBuyValue,
        required this.totalBuyAvg,
        required this.countBuy,
        required this.totalSell,
        required this.totalSellValue,
        required this.totalSellAvg,
        required this.countSell,
        required this.totalLeft,
        required this.totalPercentage,
    });

    factory BrokerCollectCompany.fromJson(Map<String, dynamic> json) => BrokerCollectCompany(
        code: json["code"],
        name: json["name"],
        fca: (json["fca"] ?? false),
        lastPrice: (json["last_price"] ?? 0),
        totalBuy: json["total_buy"],
        totalBuyValue: json["total_buy_value"],
        totalBuyAvg: (json["total_buy_avg"] != null ? json["total_buy_avg"]?.toDouble() : 0),
        countBuy: json["count_buy"],
        totalSell: json["total_sell"],
        totalSellValue: json["total_sell_value"],
        totalSellAvg: (json["total_sell_avg"] != null ? json["total_sell_avg"]?.toDouble() : 0),
        countSell: json["count_sell"],
        totalLeft: json["total_left"],
        totalPercentage: (json["total_percentage"] != null ? json["total_percentage"]?.toDouble() : 0),
    );

    Map<String, dynamic> toJson() => {
        "code": code,
        "name": name,
        "fca": fca,
        "last_price": lastPrice,
        "total_buy": totalBuy,
        "total_buy_value": totalBuyValue,
        "total_buy_avg": totalBuyAvg,
        "count_buy": countBuy,
        "total_sell": totalSell,
        "total_sell_value": totalSellValue,
        "total_sell_avg": totalSellAvg,
        "count_sell": countSell,
        "total_left": totalLeft,
        "total_percentage": totalPercentage,
    };
}
