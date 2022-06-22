// To parse this JSON data, do
//
//     final brokerModel = brokerModelFromJson(jsonString);

import 'dart:convert';

BrokerModel brokerModelFromJson(String str) => BrokerModel.fromJson(json.decode(str));

String brokerModelToJson(BrokerModel data) => json.encode(data.toJson());

class BrokerModel {
    BrokerModel({
        required this.brokerSummaryId,
        required this.brokerFirmId,
        required this.brokerFirmName,
        required this.brokerVolume,
        required this.brokerValue,
        required this.brokerFrequency,
        required this.brokerDate,
    });

    final int brokerSummaryId;
    final String brokerFirmId;
    final String brokerFirmName;
    final int brokerVolume;
    final int brokerValue;
    final int brokerFrequency;
    final DateTime brokerDate;

    factory BrokerModel.fromJson(Map<String, dynamic> json) => BrokerModel(
        brokerSummaryId: json["broker_summary_id"],
        brokerFirmId: json["broker_firm_id"],
        brokerFirmName: json["broker_firm_name"],
        brokerVolume: json["broker_volume"],
        brokerValue: json["broker_value"],
        brokerFrequency: json["broker_frequency"],
        brokerDate: DateTime.parse(json["broker_date"]),
    );

    Map<String, dynamic> toJson() => {
        "broker_summary_id": brokerSummaryId,
        "broker_firm_id": brokerFirmId,
        "broker_firm_name": brokerFirmName,
        "broker_volume": brokerVolume,
        "broker_value": brokerValue,
        "broker_frequency": brokerFrequency,
        "broker_date": brokerDate.toIso8601String(),
    };
}
