// To parse this JSON data, do
//
//     final brokerTopTransactionModel = brokerTopTransactionModelFromJson(jsonString);

import 'dart:convert';

BrokerTopTransactionModel brokerTopTransactionModelFromJson(String str) => BrokerTopTransactionModel.fromJson(json.decode(str));

String brokerTopTransactionModelToJson(BrokerTopTransactionModel data) => json.encode(data.toJson());

class BrokerTopTransactionModel {
    BrokerTopTransactionModel({
        required this.brokerSummaryDate,
        required this.all,
        required this.domestic,
        required this.foreign,
    });

    final DateTime brokerSummaryDate;
    final BuySell all;
    final BuySell domestic;
    final BuySell foreign;

    factory BrokerTopTransactionModel.fromJson(Map<String, dynamic> json) => BrokerTopTransactionModel(
        brokerSummaryDate: DateTime.parse(json["broker_summary_date"]),
        all: BuySell.fromJson(json["all"]),
        domestic: BuySell.fromJson(json["domestic"]),
        foreign: BuySell.fromJson(json["foreign"]),
    );

    Map<String, dynamic> toJson() => {
        "broker_summary_date": "${brokerSummaryDate.year.toString().padLeft(4, '0')}-${brokerSummaryDate.month.toString().padLeft(2, '0')}-${brokerSummaryDate.day.toString().padLeft(2, '0')}",
        "all": all.toJson(),
        "domestic": domestic.toJson(),
        "foreign": foreign.toJson(),
    };
}

class BuySell {
    BuySell({
        required this.buy,
        required this.sell,
    });

    final List<BuySellItem> buy;
    final List<BuySellItem> sell;

    factory BuySell.fromJson(Map<String, dynamic> json) => BuySell(
        buy: List<BuySellItem>.from(json["buy"].map((x) => BuySellItem.fromJson(x))),
        sell: List<BuySellItem>.from(json["sell"].map((x) => BuySellItem.fromJson(x))),
    );

    Map<String, dynamic> toJson() => {
        "buy": List<dynamic>.from(buy.map((x) => x.toJson())),
        "sell": List<dynamic>.from(sell.map((x) => x.toJson())),
    };
}

class BuySellItem {
    BuySellItem({
        required this.brokerSummaryId,
        required this.brokerTotalTxn,
        required this.brokerTotalLot,
    });

    final String brokerSummaryId;
    final String brokerTotalTxn;
    final double brokerTotalLot;

    factory BuySellItem.fromJson(Map<String, dynamic> json) => BuySellItem(
        brokerSummaryId: json["broker_summary_id"],
        brokerTotalTxn: json["broker_total_txn"],
        brokerTotalLot: json["broker_total_lot"].toDouble(),
    );

    Map<String, dynamic> toJson() => {
        "broker_summary_id": brokerSummaryId,
        "broker_total_txn": brokerTotalTxn,
        "broker_total_lot": brokerTotalLot,
    };
}
