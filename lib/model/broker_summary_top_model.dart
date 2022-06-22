// To parse this JSON data, do
//
//     final brokerSummaryTopModel = brokerSummaryTopModelFromJson(jsonString);

import 'dart:convert';

BrokerSummaryTopModel brokerSummaryTopModelFromJson(String str) => BrokerSummaryTopModel.fromJson(json.decode(str));

String brokerSummaryTopModelToJson(BrokerSummaryTopModel data) => json.encode(data.toJson());

class BrokerSummaryTopModel {
    BrokerSummaryTopModel({
        required this.brokerSummaryDate,
        required this.brokerSummaryAll,
        required this.brokerSummaryForeign,
        required this.brokerSummaryDomestic,
    });

    final DateTime brokerSummaryDate;
    final BrokerSummaryAllClass brokerSummaryAll;
    final BrokerSummaryAllClass brokerSummaryForeign;
    final BrokerSummaryAllClass brokerSummaryDomestic;

    factory BrokerSummaryTopModel.fromJson(Map<String, dynamic> json) => BrokerSummaryTopModel(
        brokerSummaryDate: DateTime.parse(json["broker_summary_date"]),
        brokerSummaryAll: BrokerSummaryAllClass.fromJson(json["broker_summary_all"]),
        brokerSummaryForeign: BrokerSummaryAllClass.fromJson(json["broker_summary_foreign"]),
        brokerSummaryDomestic: BrokerSummaryAllClass.fromJson(json["broker_summary_domestic"]),
    );

    Map<String, dynamic> toJson() => {
        "broker_summary_date": brokerSummaryDate.toIso8601String(),
        "broker_summary_all": brokerSummaryAll.toJson(),
        "broker_summary_foreign": brokerSummaryForeign.toJson(),
        "broker_summary_domestic": brokerSummaryDomestic.toJson(),
    };
}

class BrokerSummaryAllClass {
    BrokerSummaryAllClass({
        required this.brokerSummaryBuy,
        required this.brokerSummarySell,
    });

    final List<BrokerSummaryBuyElement> brokerSummaryBuy;
    final List<BrokerSummaryBuyElement> brokerSummarySell;

    factory BrokerSummaryAllClass.fromJson(Map<String, dynamic> json) => BrokerSummaryAllClass(
        brokerSummaryBuy: List<BrokerSummaryBuyElement>.from(json["broker_summary_buy"].map((x) => BrokerSummaryBuyElement.fromJson(x))),
        brokerSummarySell: List<BrokerSummaryBuyElement>.from(json["broker_summary_sell"].map((x) => BrokerSummaryBuyElement.fromJson(x))),
    );

    Map<String, dynamic> toJson() => {
        "broker_summary_buy": List<dynamic>.from(brokerSummaryBuy.map((x) => x.toJson())),
        "broker_summary_sell": List<dynamic>.from(brokerSummarySell.map((x) => x.toJson())),
    };
}

class BrokerSummaryBuyElement {
    BrokerSummaryBuyElement({
        required this.brokerSummaryCode,
        required this.brokerSummaryLastPrice,
        required this.brokerSummaryLot,
        required this.brokerSummaryAverage,
        required this.brokerSummaryCount,
    });

    final String brokerSummaryCode;
    final int brokerSummaryLastPrice;
    final int brokerSummaryLot;
    final int brokerSummaryAverage;
    final String brokerSummaryCount;

    factory BrokerSummaryBuyElement.fromJson(Map<String, dynamic> json) => BrokerSummaryBuyElement(
        brokerSummaryCode: json["broker_summary_code"],
        brokerSummaryLastPrice: json["broker_summary_last_price"],
        brokerSummaryLot: json["broker_summary_lot"],
        brokerSummaryAverage: json["broker_summary_average"],
        brokerSummaryCount: json["broker_summary_total"],
    );

    Map<String, dynamic> toJson() => {
        "broker_summary_code": brokerSummaryCode,
        "broker_summary_last_price": brokerSummaryLastPrice,
        "broker_summary_lot": brokerSummaryLot,
        "broker_summary_average": brokerSummaryAverage,
        "broker_summary_total": brokerSummaryCount
    };
}
