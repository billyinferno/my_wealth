// To parse this JSON data, do
//
//     final brokerSummaryDateModel = brokerSummaryDateModelFromJson(jsonString);

import 'dart:convert';

BrokerSummaryDateModel brokerSummaryDateModelFromJson(String str) => BrokerSummaryDateModel.fromJson(json.decode(str));

String brokerSummaryDateModelToJson(BrokerSummaryDateModel data) => json.encode(data.toJson());

class BrokerSummaryDateModel {
    BrokerSummaryDateModel({
        required this.brokerMinDate,
        required this.brokerMaxDate,
    });

    final DateTime brokerMinDate;
    final DateTime brokerMaxDate;

    factory BrokerSummaryDateModel.fromJson(Map<String, dynamic> json) => BrokerSummaryDateModel(
        brokerMinDate: DateTime.parse(json["broker_min_date"]),
        brokerMaxDate: DateTime.parse(json["broker_max_date"]),
    );

    Map<String, dynamic> toJson() => {
        "broker_min_date": "${brokerMinDate.year.toString().padLeft(4, '0')}-${brokerMinDate.month.toString().padLeft(2, '0')}-${brokerMinDate.day.toString().padLeft(2, '0')}",
        "broker_max_date": "${brokerMaxDate.year.toString().padLeft(4, '0')}-${brokerMaxDate.month.toString().padLeft(2, '0')}-${brokerMaxDate.day.toString().padLeft(2, '0')}",
    };
}
