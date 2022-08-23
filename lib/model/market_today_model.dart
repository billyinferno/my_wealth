// To parse this JSON data, do
//
//     final marketTodayModel = marketTodayModelFromJson(jsonString);

import 'dart:convert';

MarketTodayModel marketTodayModelFromJson(String str) => MarketTodayModel.fromJson(json.decode(str));

String marketTodayModelToJson(MarketTodayModel data) => json.encode(data.toJson());

class MarketTodayModel {
    MarketTodayModel({
        required this.sell,
        required this.buy,
    });

    MarketTodayData sell;
    MarketTodayData buy;

    factory MarketTodayModel.fromJson(Map<String, dynamic> json) => MarketTodayModel(
        sell: MarketTodayData.fromJson(json["sell"]),
        buy: MarketTodayData.fromJson(json["buy"]),
    );

    Map<String, dynamic> toJson() => {
        "sell": sell.toJson(),
        "buy": buy.toJson(),
    };
}

class MarketTodayData {
    MarketTodayData({
        required this.brokerSummaryType,
        required this.brokerSummaryTotalLot,
        required this.brokerSummaryTotalValue,
    });

    String brokerSummaryType;
    int brokerSummaryTotalLot;
    int brokerSummaryTotalValue;

    factory MarketTodayData.fromJson(Map<String, dynamic> json) => MarketTodayData(
        brokerSummaryType: json["broker_summary_type"],
        brokerSummaryTotalLot: json["broker_summary_total_lot"],
        brokerSummaryTotalValue: json["broker_summary_total_value"],
    );

    Map<String, dynamic> toJson() => {
        "broker_summary_type": brokerSummaryType,
        "broker_summary_total_lot": brokerSummaryTotalLot,
        "broker_summary_total_value": brokerSummaryTotalValue,
    };
}
