// To parse this JSON data, do
//
//     final brokerSummaryDailyStatModel = brokerSummaryDailyStatModelFromJson(jsonString);

import 'dart:convert';

BrokerSummaryDailyStatModel brokerSummaryDailyStatModelFromJson(String str) => BrokerSummaryDailyStatModel.fromJson(json.decode(str));

String brokerSummaryDailyStatModelToJson(BrokerSummaryDailyStatModel data) => json.encode(data.toJson());

class BrokerSummaryDailyStatModel {
    final BrokerSummaryDailyStatItem domestic;
    final BrokerSummaryDailyStatItem foreign;
    final BrokerSummaryDailyStatItem all;

    BrokerSummaryDailyStatModel({
        required this.domestic,
        required this.foreign,
        required this.all,
    });

    factory BrokerSummaryDailyStatModel.fromJson(Map<String, dynamic> json) => BrokerSummaryDailyStatModel(
        domestic: BrokerSummaryDailyStatItem.fromJson(json["domestic"]),
        foreign: BrokerSummaryDailyStatItem.fromJson(json["foreign"]),
        all: BrokerSummaryDailyStatItem.fromJson(json["all"]),
    );

    Map<String, dynamic> toJson() => {
        "domestic": domestic.toJson(),
        "foreign": foreign.toJson(),
        "all": all.toJson(),
    };
}

class BrokerSummaryDailyStatItem {
    final List<BrokerSummaryDailyStatBuySell> buy;
    final List<BrokerSummaryDailyStatBuySell> sell;

    BrokerSummaryDailyStatItem({
        required this.buy,
        required this.sell,
    });

    factory BrokerSummaryDailyStatItem.fromJson(Map<String, dynamic> json) => BrokerSummaryDailyStatItem(
        buy: List<BrokerSummaryDailyStatBuySell>.from(json["buy"].map((x) => BrokerSummaryDailyStatBuySell.fromJson(x))),
        sell: List<BrokerSummaryDailyStatBuySell>.from(json["sell"].map((x) => BrokerSummaryDailyStatBuySell.fromJson(x))),
    );

    Map<String, dynamic> toJson() => {
        "buy": List<dynamic>.from(buy.map((x) => x.toJson())),
        "sell": List<dynamic>.from(sell.map((x) => x.toJson())),
    };
}

class BrokerSummaryDailyStatBuySell {
    final String date;
    final int totalLot;
    final int totalValue;

    BrokerSummaryDailyStatBuySell({
        required this.date,
        required this.totalLot,
        required this.totalValue,
    });

    factory BrokerSummaryDailyStatBuySell.fromJson(Map<String, dynamic> json) => BrokerSummaryDailyStatBuySell(
        date: json["date"],
        totalLot: json["total_lot"],
        totalValue: json["total_value"],
    );

    Map<String, dynamic> toJson() => {
        "date": date,
        "total_lot": totalLot,
        "total_value": totalValue,
    };
}
