// To parse this JSON data, do
//
//     final insightAcquisitionModel = insightAcquisitionModelFromJson(jsonString);

import 'dart:convert';

InsightAccumulationModel insightAcquisitionModelFromJson(String str) => InsightAccumulationModel.fromJson(json.decode(str));

String insightAcquisitionModelToJson(InsightAccumulationModel data) => json.encode(data.toJson());

class InsightAccumulationModel {
    InsightAccumulationModel({
        required this.code,
        required this.oneDay,
        required this.lastPrice,
        required this.buyLot,
        required this.sellLot,
        required this.diff,
    });

    String code;
    double oneDay;
    int lastPrice;
    int buyLot;
    int sellLot;
    int diff;

    factory InsightAccumulationModel.fromJson(Map<String, dynamic> json) => InsightAccumulationModel(
        code: json["code"],
        oneDay: json["one_day"].toDouble(),
        lastPrice: json["last_price"],
        buyLot: json["buy_lot"],
        sellLot: json["sell_lot"],
        diff: json["diff"],
    );

    Map<String, dynamic> toJson() => {
        "code": code,
        "one_day": oneDay,
        "last_price": lastPrice,
        "buy_lot": buyLot,
        "sell_lot": sellLot,
        "diff": diff,
    };
}
