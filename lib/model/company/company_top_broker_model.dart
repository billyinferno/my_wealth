// To parse this JSON data, do
//
//     final companyTopBrokerModel = companyTopBrokerModelFromJson(jsonString);

// ignore_for_file: prefer_null_aware_operators

import 'dart:convert';

CompanyTopBrokerModel companyTopBrokerModelFromJson(String str) => CompanyTopBrokerModel.fromJson(json.decode(str));

String companyTopBrokerModelToJson(CompanyTopBrokerModel data) => json.encode(data.toJson());

class CompanyTopBrokerModel {
    CompanyTopBrokerModel({
        required this.brokerMinDate,
        required this.brokerMaxDate,
        required this.brokerData,
    });

    final DateTime? brokerMinDate;
    final DateTime? brokerMaxDate;
    final List<BrokerData> brokerData;

    factory CompanyTopBrokerModel.fromJson(Map<String, dynamic> json) => CompanyTopBrokerModel(
        brokerMinDate: (json["broker_min_date"] == null ? null : DateTime.parse(json["broker_min_date"])),
        brokerMaxDate: (json["broker_max_date"] == null ? null : DateTime.parse(json["broker_max_date"])),
        brokerData: List<BrokerData>.from(json["broker_data"].map((x) => BrokerData.fromJson(x))),
    );

    Map<String, dynamic> toJson() => {
        "broker_min_date": "${brokerMinDate!.year.toString().padLeft(4, '0')}-${brokerMinDate!.month.toString().padLeft(2, '0')}-${brokerMinDate!.day.toString().padLeft(2, '0')}",
        "broker_max_date": "${brokerMaxDate!.year.toString().padLeft(4, '0')}-${brokerMaxDate!.month.toString().padLeft(2, '0')}-${brokerMaxDate!.day.toString().padLeft(2, '0')}",
        "broker_data": List<dynamic>.from(brokerData.map((x) => x.toJson())),
    };
}

class BrokerData {
    BrokerData({
        required this.brokerSummaryId,
        required this.brokerSummaryLot,
        required this.brokerSummaryValue,
        required this.brokerSummaryAverage,
    });

    final String brokerSummaryId;
    final int brokerSummaryLot;
    final double brokerSummaryValue;
    final double brokerSummaryAverage;

    factory BrokerData.fromJson(Map<String, dynamic> json) => BrokerData(
        brokerSummaryId: json["broker_summary_id"],
        brokerSummaryLot: json["broker_summary_lot"],
        brokerSummaryValue: (json["broker_summary_value"] != null ? json["broker_summary_value"].toDouble() : null),
        brokerSummaryAverage: (json["broker_summary_average"] != null ? json["broker_summary_average"].toDouble() : null),
    );

    Map<String, dynamic> toJson() => {
        "broker_summary_id": brokerSummaryId,
        "broker_summary_lot": brokerSummaryLot,
        "broker_summary_value": brokerSummaryValue,
        "broker_summary_average": brokerSummaryAverage,
    };
}
