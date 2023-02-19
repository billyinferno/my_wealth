// To parse this JSON data, do
//
//     final stockDividendListModel = stockDividendListModelFromJson(jsonString);
import 'dart:convert';

StockDividendListModel stockDividendListModelFromJson(String str) => StockDividendListModel.fromJson(json.decode(str));

String stockDividendListModelToJson(StockDividendListModel data) => json.encode(data.toJson());

class StockDividendListModel {
    StockDividendListModel({
        required this.id,
        required this.code,
        required this.name,
        required this.cashDividend,
        required this.cumDividend,
        required this.exDividend,
        required this.recordDate,
        required this.paymentDate,
    });

    final int id;
    final String code;
    final String name;
    final double cashDividend;
    final DateTime? cumDividend;
    final DateTime? exDividend;
    final DateTime? recordDate;
    final DateTime? paymentDate;

    factory StockDividendListModel.fromJson(Map<String, dynamic> json) => StockDividendListModel(
        id: json["id"],
        code: json["code"],
        name: json["name"],
        cashDividend: json["cash_dividend"]?.toDouble(),
        cumDividend: (json["cum_dividend"] != null ? DateTime.parse(json["cum_dividend"]).toLocal() : null),
        exDividend: (json["ex_dividend"] != null ? DateTime.parse(json["ex_dividend"]).toLocal() : null),
        recordDate: (json["record_date"] != null ? DateTime.parse(json["record_date"]).toLocal() : null),
        paymentDate: (json["payment_date"] != null ? DateTime.parse(json["payment_date"]).toLocal() : null),
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "code": code,
        "name": name,
        "cash_dividend": cashDividend,
        "cum_dividend": (cumDividend != null ? "${cumDividend!.year.toString().padLeft(4, '0')}-${cumDividend!.month.toString().padLeft(2, '0')}-${cumDividend!.day.toString().padLeft(2, '0')}" : null),
        "ex_dividend": (exDividend != null ? "${exDividend!.year.toString().padLeft(4, '0')}-${exDividend!.month.toString().padLeft(2, '0')}-${exDividend!.day.toString().padLeft(2, '0')}" : null),
        "record_date": (recordDate != null ? "${recordDate!.year.toString().padLeft(4, '0')}-${recordDate!.month.toString().padLeft(2, '0')}-${recordDate!.day.toString().padLeft(2, '0')}" : null),
        "payment_date": (paymentDate != null ? "${paymentDate!.year.toString().padLeft(4, '0')}-${paymentDate!.month.toString().padLeft(2, '0')}-${paymentDate!.day.toString().padLeft(2, '0')}" : null),
    };
}
