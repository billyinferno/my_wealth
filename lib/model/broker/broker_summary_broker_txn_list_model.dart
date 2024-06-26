// To parse this JSON data, do
//
//     final brokerSummaryListModel = brokerSummaryListModelFromJson(jsonString);

// ignore_for_file: prefer_null_aware_operators

import 'dart:convert';

BrokerSummaryBrokerTxnListModel brokerSummaryListModelFromJson(String str) => BrokerSummaryBrokerTxnListModel.fromJson(json.decode(str));

String brokerSummaryListModelToJson(BrokerSummaryBrokerTxnListModel data) => json.encode(data.toJson());

class BrokerSummaryBrokerTxnListModel {
    BrokerSummaryBrokerTxnListModel({
        required this.brokerSummaryId,
        required this.brokerSummaryFromDate,
        required this.brokerSummaryToDate,
        required this.brokerSummaryFirmName,
        required this.brokerSummaryVolume,
        required this.brokerSummaryValue,
        required this.brokerSummaryFrequency,
        required this.brokerSummaryCodeList,
    });

    final String brokerSummaryId;
    final DateTime brokerSummaryFromDate;
    final DateTime brokerSummaryToDate;
    final String brokerSummaryFirmName;
    final int brokerSummaryVolume;
    final double brokerSummaryValue;
    final int brokerSummaryFrequency;
    final List<BrokerSummaryCodeListModel> brokerSummaryCodeList;

    factory BrokerSummaryBrokerTxnListModel.fromJson(Map<String, dynamic> json) => BrokerSummaryBrokerTxnListModel(
        brokerSummaryId: json["broker_summary_id"],
        brokerSummaryFromDate: DateTime.parse(json["broker_summary_from_date"]),
        brokerSummaryToDate: DateTime.parse(json["broker_summary_to_date"]),
        brokerSummaryFirmName: json["broker_summary_firm_name"],
        brokerSummaryVolume: json["broker_summary_volume"],
        brokerSummaryValue: (json["broker_summary_value"] != null ? json["broker_summary_value"].toDouble() : null),
        brokerSummaryFrequency: json["broker_summary_frequency"],
        brokerSummaryCodeList: List<BrokerSummaryCodeListModel>.from(json["broker_summary_code_list"].map((x) => BrokerSummaryCodeListModel.fromJson(x))),
    );

    Map<String, dynamic> toJson() => {
        "broker_summary_id": brokerSummaryId,
        "broker_summary_from_date": brokerSummaryFromDate.toIso8601String(),
        "broker_summary_to_date": brokerSummaryToDate.toIso8601String(),
        "broker_summary_firm_name": brokerSummaryFirmName,
        "broker_summary_volume": brokerSummaryVolume,
        "broker_summary_value": brokerSummaryValue,
        "broker_summary_frequency": brokerSummaryFrequency,
        "broker_summary_code_list": List<dynamic>.from(brokerSummaryCodeList.map((x) => x.toJson())),
    };
}

class BrokerSummaryCodeListModel {
    BrokerSummaryCodeListModel({
        required this.brokerSummaryCompanyId,
        required this.brokerSummaryCode,
        required this.brokerSummaryName,
        required this.brokerSummaryFavouriteId,
        required this.brokerSummaryFCA,
        required this.brokerSummaryLastPrice,
        required this.brokerSummaryAdjustedClosingPrice,
        required this.brokerSummaryLot,
        required this.brokerSummaryValue,
        required this.brokerSummaryCount,
    });

    final int brokerSummaryCompanyId;
    final String brokerSummaryCode;
    final String brokerSummaryName;
    final int brokerSummaryFavouriteId;
    final bool brokerSummaryFCA;
    final int brokerSummaryLastPrice;
    final int brokerSummaryAdjustedClosingPrice;
    final int brokerSummaryLot;
    final double brokerSummaryValue;
    final String brokerSummaryCount;

    factory BrokerSummaryCodeListModel.fromJson(Map<String, dynamic> json) => BrokerSummaryCodeListModel(
        brokerSummaryCompanyId: json["broker_summary_company_id"],
        brokerSummaryCode: json["broker_summary_code"],
        brokerSummaryName: json["broker_summary_name"],
        brokerSummaryFavouriteId: json["broker_summary_favourite_id"],
        brokerSummaryFCA: json["broker_summary_fca"],
        brokerSummaryLastPrice: json["broker_summary_last_price"],
        brokerSummaryAdjustedClosingPrice: json["broker_summary_adjusted_closing_price"],
        brokerSummaryLot: json["broker_summary_lot"],
        brokerSummaryValue: (json["broker_summary_value"] != null ? json["broker_summary_value"].toDouble() : null),
        brokerSummaryCount: json["broker_summary_count"],
    );

    Map<String, dynamic> toJson() => {
        "broker_summary_company_id": brokerSummaryCompanyId,
        "broker_summary_code": brokerSummaryCode,
        "broker_summary_name": brokerSummaryName,
        "broker_summary_favourite_id": brokerSummaryFavouriteId,
        "broker_summary_fca": brokerSummaryFCA,
        "broker_summary_last_price": brokerSummaryLastPrice,
        "broker_summary_adjusted_closing_price": brokerSummaryAdjustedClosingPrice,
        "broker_summary_lot": brokerSummaryLot,
        "broker_summary_value": brokerSummaryValue,
        "broker_summary_count": brokerSummaryCount,
    };
}
