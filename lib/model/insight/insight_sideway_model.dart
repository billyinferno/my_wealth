// To parse this JSON data, do
//
//     final insightSidewayModel = insightSidewayModelFromJson(jsonString);

// ignore_for_file: prefer_null_aware_operators

import 'dart:convert';

InsightSidewayModel insightSidewayModelFromJson(String str) => InsightSidewayModel.fromJson(json.decode(str));

String insightSidewayModelToJson(InsightSidewayModel data) => json.encode(data.toJson());

class InsightSidewayModel {
    InsightSidewayModel({
        required this.code,
        required this.name,
        required this.lastPrice,
        required this.prevClosingPrice,
        this.oneDay,
        this.oneWeek,
        this.oneMonth,
        this.avgDaily,
        this.avgWeekly,
    });

    final String code;
    final String name;
    final int lastPrice;
    final int prevClosingPrice;
    final double? oneDay;
    final double? oneWeek;
    final double? oneMonth;
    final double? avgDaily;
    final double? avgWeekly;

    factory InsightSidewayModel.fromJson(Map<String, dynamic> json) => InsightSidewayModel(
        code: json["code"],
        name: (json["name"] ?? ''),
        lastPrice: json["last_price"],
        prevClosingPrice: json["prev_closing_price"],
        oneDay: (json["one_day"] == null ? null : json["one_day"].toDouble()),
        oneWeek: (json["one_week"] == null ? null : json["one_week"].toDouble()),
        oneMonth: (json["one_month"] == null ? null : json["one_month"].toDouble()),
        avgDaily: (json["avg_daily"] == null ? null : json["avg_daily"].toDouble()),
        avgWeekly: (json["avg_weekly"] == null ? null : json["avg_weekly"].toDouble()),
    );

    Map<String, dynamic> toJson() => {
        "code": code,
        "name": name,
        "last_price": lastPrice,
        "prev_closing_price": prevClosingPrice,
        "one_day": oneDay,
        "one_week": oneWeek,
        "one_month": oneMonth,
        "avg_daily": avgDaily,
        "avg_weekly": avgWeekly,
    };
}
