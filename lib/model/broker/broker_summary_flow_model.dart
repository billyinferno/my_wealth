// To parse this JSON data, do
//
//     final brokerSummaryFlowModel = brokerSummaryFlowModelFromJson(jsonString);

import 'dart:convert';

BrokerSummaryFlowModel brokerSummaryFlowModelFromJson(String str) => BrokerSummaryFlowModel.fromJson(json.decode(str));

String brokerSummaryFlowModelToJson(BrokerSummaryFlowModel data) => json.encode(data.toJson());

class BrokerSummaryFlowModel {
    final List<BrokerSummaryFlowData> domestic;
    final List<BrokerSummaryFlowData> foreign;

    BrokerSummaryFlowModel({
        required this.domestic,
        required this.foreign,
    });

    factory BrokerSummaryFlowModel.fromJson(Map<String, dynamic> json) => BrokerSummaryFlowModel(
        domestic: List<BrokerSummaryFlowData>.from(json["domestic"].map((x) => BrokerSummaryFlowData.fromJson(x))),
        foreign: List<BrokerSummaryFlowData>.from(json["foreign"].map((x) => BrokerSummaryFlowData.fromJson(x))),
    );

    Map<String, dynamic> toJson() => {
        "domestic": List<dynamic>.from(domestic.map((x) => x.toJson())),
        "foreign": List<dynamic>.from(foreign.map((x) => x.toJson())),
    };
}

class BrokerSummaryFlowData {
    final DateTime date;
    final int buyValue;
    final int sellValue;
    final int netValue;

    BrokerSummaryFlowData({
        required this.date,
        required this.buyValue,
        required this.sellValue,
        required this.netValue,
    });

    factory BrokerSummaryFlowData.fromJson(Map<String, dynamic> json) => BrokerSummaryFlowData(
        date: DateTime.parse(json["date"]),
        buyValue: json["buy_value"],
        sellValue: json["sell_value"],
        netValue: json["net_value"],
    );

    Map<String, dynamic> toJson() => {
        "date": "${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}",
        "buy_value": buyValue,
        "sell_value": sellValue,
        "net_value": netValue,
    };
}
