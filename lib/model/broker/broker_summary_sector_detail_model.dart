// To parse this JSON data, do
//
//     final brokerSummarySectorDetailModel = brokerSummarySectorDetailModelFromJson(jsonString);

import 'dart:convert';

BrokerSummarySectorDetailModel brokerSummarySectorDetailModelFromJson(String str) => BrokerSummarySectorDetailModel.fromJson(json.decode(str));

String brokerSummarySectorDetailModelToJson(BrokerSummarySectorDetailModel data) => json.encode(data.toJson());

class BrokerSummarySectorDetailModel {
    final List<SectorDetail> domestic;
    final List<SectorDetail> foreign;

    BrokerSummarySectorDetailModel({
        required this.domestic,
        required this.foreign,
    });

    factory BrokerSummarySectorDetailModel.fromJson(Map<String, dynamic> json) => BrokerSummarySectorDetailModel(
        domestic: List<SectorDetail>.from(json["domestic"].map((x) => SectorDetail.fromJson(x))),
        foreign: List<SectorDetail>.from(json["foreign"].map((x) => SectorDetail.fromJson(x))),
    );

    Map<String, dynamic> toJson() => {
        "domestic": List<dynamic>.from(domestic.map((x) => x.toJson())),
        "foreign": List<dynamic>.from(foreign.map((x) => x.toJson())),
    };
}

class SectorDetail {
    final DateTime date;
    final int totalSellLot;
    final int totalSellValue;
    final int totalBuyLot;
    final int totalBuyValue;
    final int totalNetLot;
    final int totalNetValue;

    SectorDetail({
        required this.date,
        required this.totalSellLot,
        required this.totalSellValue,
        required this.totalBuyLot,
        required this.totalBuyValue,
        required this.totalNetLot,
        required this.totalNetValue,
    });

    factory SectorDetail.fromJson(Map<String, dynamic> json) => SectorDetail(
        date: DateTime.parse(json["date"]),
        totalSellLot: json["total_sell_lot"],
        totalSellValue: json["total_sell_value"],
        totalBuyLot: json["total_buy_lot"],
        totalBuyValue: json["total_buy_value"],
        totalNetLot: json["total_net_lot"],
        totalNetValue: json["total_net_value"],
    );

    Map<String, dynamic> toJson() => {
        "date": "${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}",
        "total_sell_lot": totalSellLot,
        "total_sell_value": totalSellValue,
        "total_buy_lot": totalBuyLot,
        "total_buy_value": totalBuyValue,
        "total_net_lot": totalNetLot,
        "total_net_value": totalNetValue,
    };
}
