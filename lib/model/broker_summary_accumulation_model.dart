// To parse this JSON data, do
//
//     final brokerSummaryAccumulationModel = brokerSummaryAccumulationModelFromJson(jsonString);

import 'dart:convert';

BrokerSummaryAccumulationModel brokerSummaryAccumulationModelFromJson(String str) => BrokerSummaryAccumulationModel.fromJson(json.decode(str));

String brokerSummaryAccumulationModelToJson(BrokerSummaryAccumulationModel data) => json.encode(data.toJson());

class BrokerSummaryAccumulationModel {
    BrokerSummaryAccumulationModel({
        required this.brokerSummaryCode,
        required this.brokerSummaryAvgCurrentLot,
        required this.brokerSummaryAvgLot,
    });

    String brokerSummaryCode;
    double brokerSummaryAvgCurrentLot;
    double brokerSummaryAvgLot;

    factory BrokerSummaryAccumulationModel.fromJson(Map<String, dynamic> json) => BrokerSummaryAccumulationModel(
        brokerSummaryCode: json["broker_summary_code"],
        brokerSummaryAvgCurrentLot: json["broker_summary_avg_current_lot"].toDouble(),
        brokerSummaryAvgLot: json["broker_summary_avg_lot"].toDouble(),
    );

    Map<String, dynamic> toJson() => {
        "broker_summary_code": brokerSummaryCode,
        "broker_summary_avg_current_lot": brokerSummaryAvgCurrentLot,
        "broker_summary_avg_lot": brokerSummaryAvgLot,
    };
}
