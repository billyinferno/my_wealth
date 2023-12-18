// To parse this JSON data, do
//
//     final summaryPerformanceModel = summaryPerformanceModelFromJson(jsonString);

import 'dart:convert';

SummaryPerformanceModel summaryPerformanceModelFromJson(String str) => SummaryPerformanceModel.fromJson(json.decode(str));

String summaryPerformanceModelToJson(SummaryPerformanceModel data) => json.encode(data.toJson());

class SummaryPerformanceModel {
    SummaryPerformanceModel({
        required this.plDate,
        required this.plValue,
        required this.totalAmount
    });

    DateTime plDate;
    double plValue;
    double totalAmount;

    factory SummaryPerformanceModel.fromJson(Map<String, dynamic> json) => SummaryPerformanceModel(
        plDate: DateTime.parse(json["pl_date"]),
        plValue: (json["pl_value"] == null ? 0 : json["pl_value"].toDouble()),
        totalAmount: (json["total_amount"] == null ? 0 : json["total_amount"].toDouble()) 
    );

    Map<String, dynamic> toJson() => {
        "pl_date": "${plDate.year.toString().padLeft(4, '0')}-${plDate.month.toString().padLeft(2, '0')}-${plDate.day.toString().padLeft(2, '0')}",
        "pl_value": plValue,
        "total_amount": totalAmount,
    };
}
