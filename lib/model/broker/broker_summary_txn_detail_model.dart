// To parse this JSON data, do
//
//     final brokerSummaryTxnDetailModel = brokerSummaryTxnDetailModelFromJson(jsonString);

// ignore_for_file: prefer_null_aware_operators

import 'dart:convert';

BrokerSummaryTxnDetailModel brokerSummaryTxnDetailModelFromJson(String str) => BrokerSummaryTxnDetailModel.fromJson(json.decode(str));

String brokerSummaryTxnDetailModelToJson(BrokerSummaryTxnDetailModel data) => json.encode(data.toJson());

class BrokerSummaryTxnDetailModel {
    BrokerSummaryTxnDetailModel({
        required this.brokerSummaryId,
        required this.brokerSummaryCode,
        required this.brokerSummaryFromDate,
        required this.brokerSummaryToDate,
        required this.brokerSummaryDomestic,
        required this.brokerSummaryForeign,
        required this.brokerSummaryAll,
    });

    final String brokerSummaryId;
    final String brokerSummaryCode;
    final DateTime brokerSummaryFromDate;
    final DateTime brokerSummaryToDate;
    final BrokerSummaryTxnDetailAllModel brokerSummaryDomestic;
    final BrokerSummaryTxnDetailAllModel brokerSummaryForeign;
    final BrokerSummaryTxnDetailAllModel brokerSummaryAll;

    factory BrokerSummaryTxnDetailModel.fromJson(Map<String, dynamic> json) => BrokerSummaryTxnDetailModel(
        brokerSummaryId: json["broker_summary_id"],
        brokerSummaryCode: json["broker_summary_code"],
        brokerSummaryFromDate: DateTime.parse(json["broker_summary_from_date"]),
        brokerSummaryToDate: DateTime.parse(json["broker_summary_to_date"]),
        brokerSummaryDomestic: BrokerSummaryTxnDetailAllModel.fromJson(json["broker_summary_domestic"]),
        brokerSummaryForeign: BrokerSummaryTxnDetailAllModel.fromJson(json["broker_summary_foreign"]),
        brokerSummaryAll: BrokerSummaryTxnDetailAllModel.fromJson(json["broker_summary_all"]),
    );

    Map<String, dynamic> toJson() => {
        "broker_summary_id": brokerSummaryId,
        "broker_summary_code": brokerSummaryCode,
        "broker_summary_from_date": brokerSummaryFromDate.toIso8601String(),
        "broker_summary_to_date": brokerSummaryToDate.toIso8601String(),
        "broker_summary_domestic": brokerSummaryDomestic.toJson(),
        "broker_summary_foreign": brokerSummaryForeign.toJson(),
        "broker_summary_all": brokerSummaryAll.toJson(),
    };
}

class BrokerSummaryTxnDetailAllModel {
    BrokerSummaryTxnDetailAllModel({
        required this.brokerSummaryBuy,
        required this.brokerSummarySell,
    });

    final List<BrokerSummaryTxnBuySellElement> brokerSummaryBuy;
    final List<BrokerSummaryTxnBuySellElement> brokerSummarySell;

    factory BrokerSummaryTxnDetailAllModel.fromJson(Map<String, dynamic> json) => BrokerSummaryTxnDetailAllModel(
        brokerSummaryBuy: List<BrokerSummaryTxnBuySellElement>.from(json["broker_summary_buy"].map((x) => BrokerSummaryTxnBuySellElement.fromJson(x))),
        brokerSummarySell: List<BrokerSummaryTxnBuySellElement>.from(json["broker_summary_sell"].map((x) => BrokerSummaryTxnBuySellElement.fromJson(x))),
    );

    Map<String, dynamic> toJson() => {
        "broker_summary_buy": List<dynamic>.from(brokerSummaryBuy.map((x) => x.toJson())),
        "broker_summary_sell": List<dynamic>.from(brokerSummarySell.map((x) => x.toJson())),
    };
}

class BrokerSummaryTxnBuySellElement {
    BrokerSummaryTxnBuySellElement({
        required this.brokerSummaryDate,
        required this.brokerSummaryLot,
        required this.brokerSummaryValue,
        required this.brokerSummaryAverage,
    });

    final DateTime brokerSummaryDate;
    final int brokerSummaryLot;
    final double brokerSummaryValue;
    final double brokerSummaryAverage;

    factory BrokerSummaryTxnBuySellElement.fromJson(Map<String, dynamic> json) => BrokerSummaryTxnBuySellElement(
        brokerSummaryDate: DateTime.parse(json["broker_summary_date"]),
        brokerSummaryLot: json["broker_summary_lot"],
        brokerSummaryValue: (json["broker_summary_value"] != null ? json["broker_summary_value"].toDouble() : null),
        brokerSummaryAverage: (json["broker_summary_average"] != null ? json["broker_summary_average"].toDouble() : null),
    );

    Map<String, dynamic> toJson() => {
        "broker_summary_date": "${brokerSummaryDate.year.toString().padLeft(4, '0')}-${brokerSummaryDate.month.toString().padLeft(2, '0')}-${brokerSummaryDate.day.toString().padLeft(2, '0')}",
        "broker_summary_lot": brokerSummaryLot,
        "broker_summary_value": brokerSummaryValue,
        "broker_summary_average": brokerSummaryAverage,
    };
}

class BrokerSummaryTxnCombineModel {
  final int brokerSummaryBuyLot;
  final double brokerSummaryBuyValue;
  final double brokerSummaryBuyAverage;
  final int brokerSummarySellLot;
  final double brokerSummarySellValue;
  final double brokerSummarySellAverage;

  BrokerSummaryTxnCombineModel({
    required this.brokerSummaryBuyLot,
    required this.brokerSummaryBuyValue,
    required this.brokerSummaryBuyAverage,
    required this.brokerSummarySellLot,
    required this.brokerSummarySellValue,
    required this.brokerSummarySellAverage,
  });
}