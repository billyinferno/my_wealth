// To parse this JSON data, do
//
//     final brokerSummarySectorFlowModel = brokerSummarySectorFlowModelFromJson(jsonString);

import 'dart:convert';

BrokerSummarySectorFlowModel brokerSummarySectorFlowModelFromJson(String str) => BrokerSummarySectorFlowModel.fromJson(json.decode(str));

String brokerSummarySectorFlowModelToJson(BrokerSummarySectorFlowModel data) => json.encode(data.toJson());

class BrokerSummarySectorFlowModel {
    final String sectorName;
    final DateTime brokerSummaryDate;
    final int prevTotalLotDomesticNet;
    final int prevTotalValueDomesticNet;
    final int prevTotalLotForeignNet;
    final int prevTotalValueForeignNet;
    final int totalLotDomesticNet;
    final int totalValueDomesticNet;
    final int totalLotForeignNet;
    final int totalValueForeignNet;

    BrokerSummarySectorFlowModel({
        required this.sectorName,
        required this.brokerSummaryDate,
        required this.prevTotalLotDomesticNet,
        required this.prevTotalValueDomesticNet,
        required this.prevTotalLotForeignNet,
        required this.prevTotalValueForeignNet,
        required this.totalLotDomesticNet,
        required this.totalValueDomesticNet,
        required this.totalLotForeignNet,
        required this.totalValueForeignNet,
    });

    factory BrokerSummarySectorFlowModel.fromJson(Map<String, dynamic> json) => BrokerSummarySectorFlowModel(
        sectorName: json["sector_name"].toString().replaceAll('&amp;', '&'),
        brokerSummaryDate: DateTime.parse(json["broker_summary_date"]),
        prevTotalLotDomesticNet: json["prev_total_lot_domestic_net"],
        prevTotalValueDomesticNet: json["prev_total_value_domestic_net"],
        prevTotalLotForeignNet: json["prev_total_lot_foreign_net"],
        prevTotalValueForeignNet: json["prev_total_value_foreign_net"],
        totalLotDomesticNet: json["total_lot_domestic_net"],
        totalValueDomesticNet: json["total_value_domestic_net"],
        totalLotForeignNet: json["total_lot_foreign_net"],
        totalValueForeignNet: json["total_value_foreign_net"],
    );

    Map<String, dynamic> toJson() => {
        "sector_name": sectorName,
        "broker_summary_date": "${brokerSummaryDate.year.toString().padLeft(4, '0')}-${brokerSummaryDate.month.toString().padLeft(2, '0')}-${brokerSummaryDate.day.toString().padLeft(2, '0')}",
        "prev_total_lot_domestic_net": prevTotalLotDomesticNet,
        "prev_total_value_domestic_net": prevTotalValueDomesticNet,
        "prev_total_lot_foreign_net": prevTotalLotForeignNet,
        "prev_total_value_foreign_net": prevTotalValueForeignNet,
        "total_lot_domestic_net": totalLotDomesticNet,
        "total_value_domestic_net": totalValueDomesticNet,
        "total_lot_foreign_net": totalLotForeignNet,
        "total_value_foreign_net": totalValueForeignNet,
    };
}
