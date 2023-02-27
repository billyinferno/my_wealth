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
        required this.brokerSummaryData,
    });

    String brokerSummaryCode;
    double brokerSummaryAvgCurrentLot;
    double brokerSummaryAvgLot;
    List<BrokerSummaryDatum> brokerSummaryData;

    factory BrokerSummaryAccumulationModel.fromJson(Map<String, dynamic> json) => BrokerSummaryAccumulationModel(
        brokerSummaryCode: json["broker_summary_code"],
        brokerSummaryAvgCurrentLot: (json["broker_summary_avg_current_lot"] != null ? json["broker_summary_avg_current_lot"].toDouble() : 0),
        brokerSummaryAvgLot: (json["broker_summary_avg_lot"] != null ? json["broker_summary_avg_lot"].toDouble() : 0),
        brokerSummaryData: List<BrokerSummaryDatum>.from(json["broker_summary_data"].map((x) => BrokerSummaryDatum.fromJson(x))),
    );

    Map<String, dynamic> toJson() => {
        "broker_summary_code": brokerSummaryCode,
        "broker_summary_avg_current_lot": brokerSummaryAvgCurrentLot,
        "broker_summary_avg_lot": brokerSummaryAvgLot,
        "broker_summary_data": List<dynamic>.from(brokerSummaryData.map((x) => x.toJson())),
    };
}

class BrokerSummaryDatum {
    BrokerSummaryDatum({
        required this.brokerSummaryDate,
        required this.brokerSummaryBuyLot,
        required this.brokerSummarySellLot,
        required this.brokerSummaryLot,
    });

    DateTime brokerSummaryDate;
    int brokerSummaryBuyLot;
    int brokerSummarySellLot;
    int brokerSummaryLot;

    factory BrokerSummaryDatum.fromJson(Map<String, dynamic> json) => BrokerSummaryDatum(
        brokerSummaryDate: DateTime.parse(json["broker_summary_date"]),
        brokerSummaryBuyLot: json["broker_summary_buy_lot"],
        brokerSummarySellLot: json["broker_summary_sell_lot"],
        brokerSummaryLot: json["broker_summary_lot"],
    );

    Map<String, dynamic> toJson() => {
        "broker_summary_date": "${brokerSummaryDate.year.toString().padLeft(4, '0')}-${brokerSummaryDate.month.toString().padLeft(2, '0')}-${brokerSummaryDate.day.toString().padLeft(2, '0')}",
        "broker_summary_buy_lot": brokerSummaryBuyLot,
        "broker_summary_sell_lot": brokerSummarySellLot,
        "broker_summary_lot": brokerSummaryLot,
    };
}
