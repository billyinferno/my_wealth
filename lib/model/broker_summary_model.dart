// To parse this JSON data, do
//
//     final brokerSummaryModel = brokerSummaryModelFromJson(jsonString);

import 'dart:convert';

BrokerSummaryModel brokerSummaryModelFromJson(String str) => BrokerSummaryModel.fromJson(json.decode(str));

String brokerSummaryModelToJson(BrokerSummaryModel data) => json.encode(data.toJson());

class BrokerSummaryModel {
    BrokerSummaryModel({
        required this.brokerSummaryCode,
        required this.brokerSummaryFromDate,
        required this.brokerSummaryToDate,
        required this.brokerSummaryDomestic,
        required this.brokerSummaryForeign,
        required this.brokerSummaryAll,
    });

    final String brokerSummaryCode;
    final DateTime brokerSummaryFromDate;
    final DateTime brokerSummaryToDate;
    final BrokerSummaryBuySellModel brokerSummaryDomestic;
    final BrokerSummaryBuySellModel brokerSummaryForeign;
    final BrokerSummaryBuySellModel brokerSummaryAll;

    factory BrokerSummaryModel.fromJson(Map<String, dynamic> json) => BrokerSummaryModel(
        brokerSummaryCode: json["broker_summary_code"],
        brokerSummaryFromDate: DateTime.parse(json["broker_summary_from_date"]),
        brokerSummaryToDate: DateTime.parse(json["broker_summary_to_date"]),
        brokerSummaryDomestic: BrokerSummaryBuySellModel.fromJson(json["broker_summary_domestic"]),
        brokerSummaryForeign: BrokerSummaryBuySellModel.fromJson(json["broker_summary_foreign"]),
        brokerSummaryAll: BrokerSummaryBuySellModel.fromJson(json["broker_summary_all"]),
    );

    Map<String, dynamic> toJson() => {
        "broker_summary_code": brokerSummaryCode,
        "broker_summary_from_date": brokerSummaryFromDate.toIso8601String(),
        "broker_summary_to_date": brokerSummaryToDate.toIso8601String(),
        "broker_summary_domestic": brokerSummaryDomestic.toJson(),
        "broker_summary_foreign": brokerSummaryForeign.toJson(),
        "broker_summary_all": brokerSummaryAll.toJson(),
    };
}

class BrokerSummaryBuySellModel {
    BrokerSummaryBuySellModel({
        required this.brokerSummaryBuy,
        required this.brokerSummarySell,
    });

    final List<BrokerSummaryBuySellElement> brokerSummaryBuy;
    final List<BrokerSummaryBuySellElement> brokerSummarySell;

    factory BrokerSummaryBuySellModel.fromJson(Map<String, dynamic> json) => BrokerSummaryBuySellModel(
        brokerSummaryBuy: List<BrokerSummaryBuySellElement>.from(json["broker_summary_buy"].map((x) => BrokerSummaryBuySellElement.fromJson(x))),
        brokerSummarySell: List<BrokerSummaryBuySellElement>.from(json["broker_summary_sell"].map((x) => BrokerSummaryBuySellElement.fromJson(x))),
    );

    Map<String, dynamic> toJson() => {
        "broker_summary_buy": List<dynamic>.from(brokerSummaryBuy.map((x) => x.toJson())),
        "broker_summary_sell": List<dynamic>.from(brokerSummarySell.map((x) => x.toJson())),
    };
}

class BrokerSummaryBuySellElement {
    BrokerSummaryBuySellElement({
        required this.brokerSummaryID,
        required this.brokerSummaryLot,
        required this.brokerSummaryValue,
        required this.brokerSummaryAverage,
    });

    final String? brokerSummaryID;
    final int? brokerSummaryLot;
    final int? brokerSummaryValue;
    final int? brokerSummaryAverage;

    factory BrokerSummaryBuySellElement.fromJson(Map<String, dynamic> json) => BrokerSummaryBuySellElement(
        brokerSummaryID: json["broker_summary_id"],
        brokerSummaryLot: json["broker_summary_lot"],
        brokerSummaryValue: json["broker_summary_value"],
        brokerSummaryAverage: json["broker_summary_average"],
    );

    Map<String, dynamic> toJson() => {
        "broker_summary_id": brokerSummaryID!,
        "broker_summary_lot": brokerSummaryLot!,
        "broker_summary_value": brokerSummaryValue!,
        "broker_summary_average": brokerSummaryAverage!,
    };
}
