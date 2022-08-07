// To parse this JSON data, do
//
//     final insightEpsModel = insightEpsModelFromJson(jsonString);

import 'dart:convert';

InsightEpsModel insightEpsModelFromJson(String str) => InsightEpsModel.fromJson(json.decode(str));

String insightEpsModelToJson(InsightEpsModel data) => json.encode(data.toJson());

class InsightEpsModel {
    InsightEpsModel({
        required this.code,
        required this.currentPeriod,
        required this.currentYear,
        required this.currentPrice,
        required this.currentMarketCap,
        required this.currentRevenue,
        required this.currentNetProfit,
        required this.currentDeviden,
        required this.currentEps,
        required this.currentEpsRate,
        required this.prevPeriod,
        required this.prevYear,
        required this.prevPrice,
        required this.prevMarketCap,
        required this.prevRevenue,
        required this.prevNetProfit,
        required this.prevDeviden,
        required this.prevEps,
        required this.prevEpsRate,
        required this.oneYear,
        required this.sixMonth,
        required this.oneMonth,
        required this.avgIncrement,
        required this.buyLot,
        required this.sellLot,
        required this.diffLot,
        required this.diffEpsRate,
    });

    String code;
    int currentPeriod;
    int currentYear;
    int currentPrice;
    int currentMarketCap;
    int currentRevenue;
    int currentNetProfit;
    double currentDeviden;
    double currentEps;
    double currentEpsRate;
    int prevPeriod;
    int prevYear;
    int prevPrice;
    int prevMarketCap;
    int prevRevenue;
    int prevNetProfit;
    double prevDeviden;
    double prevEps;
    double prevEpsRate;
    double oneYear;
    double sixMonth;
    double oneMonth;
    double avgIncrement;
    int buyLot;
    int sellLot;
    int diffLot;
    double diffEpsRate;

    factory InsightEpsModel.fromJson(Map<String, dynamic> json) => InsightEpsModel(
        code: json["code"],
        currentPeriod: json["current_period"],
        currentYear: json["current_year"],
        currentPrice: json["current_price"],
        currentMarketCap: json["current_market_cap"],
        currentRevenue: json["current_revenue"],
        currentNetProfit: json["current_net_profit"],
        currentDeviden: json["current_deviden"].toDouble(),
        currentEps: json["current_eps"].toDouble(),
        currentEpsRate: json["current_eps_rate"].toDouble(),
        prevPeriod: json["prev_period"],
        prevYear: json["prev_year"],
        prevPrice: json["prev_price"],
        prevMarketCap: json["prev_market_cap"],
        prevRevenue: json["prev_revenue"],
        prevNetProfit: json["prev_net_profit"],
        prevDeviden: json["prev_deviden"].toDouble(),
        prevEps: json["prev_eps"].toDouble(),
        prevEpsRate: json["prev_eps_rate"].toDouble(),
        oneYear: json["one_year"].toDouble(),
        sixMonth: json["six_month"].toDouble(),
        oneMonth: json["one_month"].toDouble(),
        avgIncrement: json["avg_increment"].toDouble(),
        buyLot: json["buy_lot"],
        sellLot: json["sell_lot"],
        diffLot: json["diff_lot"],
        diffEpsRate: json["diff_eps_rate"].toDouble(),
    );

    Map<String, dynamic> toJson() => {
        "code": code,
        "current_period": currentPeriod,
        "current_year": currentYear,
        "current_price": currentPrice,
        "current_market_cap": currentMarketCap,
        "current_revenue": currentRevenue,
        "current_net_profit": currentNetProfit,
        "current_deviden": currentDeviden,
        "current_eps": currentEps,
        "current_eps_rate": currentEpsRate,
        "prev_period": prevPeriod,
        "prev_year": prevYear,
        "prev_price": prevPrice,
        "prev_market_cap": prevMarketCap,
        "prev_revenue": prevRevenue,
        "prev_net_profit": prevNetProfit,
        "prev_deviden": prevDeviden,
        "prev_eps": prevEps,
        "prev_eps_rate": prevEpsRate,
        "one_year": oneYear,
        "six_month": sixMonth,
        "one_month": oneMonth,
        "avg_increment": avgIncrement,
        "buy_lot": buyLot,
        "sell_lot": sellLot,
        "diff_lot": diffLot,
        "diff_eps_rate": diffEpsRate,
    };
}
