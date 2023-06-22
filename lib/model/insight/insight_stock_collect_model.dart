// To parse this JSON data, do
//
//     final insightStockCollectModel = insightStockCollectModelFromJson(jsonString);

import 'dart:convert';

InsightStockCollectModel insightStockCollectModelFromJson(String str) => InsightStockCollectModel.fromJson(json.decode(str));

String insightStockCollectModelToJson(InsightStockCollectModel data) => json.encode(data.toJson());

class InsightStockCollectModel {
    final String code;
    final int summaryTotalBuy;
    final int summaryCountBuy;
    final int summaryTotalSell;
    final int summaryCountSell;
    final int summaryTotalLeft;
    final List<InsightStockCollectItem> data;

    InsightStockCollectModel({
        required this.code,
        required this.summaryTotalBuy,
        required this.summaryCountBuy,
        required this.summaryTotalSell,
        required this.summaryCountSell,
        required this.summaryTotalLeft,
        required this.data,
    });

    factory InsightStockCollectModel.fromJson(Map<String, dynamic> json) => InsightStockCollectModel(
        code: json["code"],
        summaryTotalBuy: json["summary_total_buy"],
        summaryCountBuy: json["summary_count_buy"],
        summaryTotalSell: json["summary_total_sell"],
        summaryCountSell: json["summary_count_sell"],
        summaryTotalLeft: json["summary_total_left"],
        data: List<InsightStockCollectItem>.from(json["data"].map((x) => InsightStockCollectItem.fromJson(x))),
    );

    Map<String, dynamic> toJson() => {
        "code": code,
        "summary_total_buy": summaryTotalBuy,
        "summary_count_buy": summaryCountBuy,
        "summary_total_sell": summaryTotalSell,
        "summary_count_sell": summaryCountSell,
        "summary_total_left": summaryTotalLeft,
        "data": List<dynamic>.from(data.map((x) => x.toJson())),
    };
}

class InsightStockCollectItem {
    final String brokerSummaryId;
    final int totalBuy;
    final int countBuy;
    final int totalSell;
    final int countSell;
    final int totalLeft;
    final double totalPercentage;

    InsightStockCollectItem({
        required this.brokerSummaryId,
        required this.totalBuy,
        required this.countBuy,
        required this.totalSell,
        required this.countSell,
        required this.totalLeft,
        required this.totalPercentage,
    });

    factory InsightStockCollectItem.fromJson(Map<String, dynamic> json) => InsightStockCollectItem(
        brokerSummaryId: json["broker_summary_id"],
        totalBuy: json["total_buy"],
        countBuy: json["count_buy"],
        totalSell: json["total_sell"],
        countSell: json["count_sell"],
        totalLeft: json["total_left"],
        totalPercentage: json["total_percentage"]?.toDouble(),
    );

    Map<String, dynamic> toJson() => {
        "broker_summary_id": brokerSummaryId,
        "total_buy": totalBuy,
        "count_buy": countBuy,
        "total_sell": totalSell,
        "count_sell": countSell,
        "total_left": totalLeft,
        "total_percentage": totalPercentage,
    };
}
