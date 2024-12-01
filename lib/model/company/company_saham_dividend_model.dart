// To parse this JSON data, do
//
//     final companySahamDividendModel = companySahamDividendModelFromJson(jsonString);

import 'dart:convert';

CompanySahamDividendModel companySahamDividendModelFromJson(String str) =>
    CompanySahamDividendModel.fromJson(json.decode(str));

String companySahamDividendModelToJson(CompanySahamDividendModel data) =>
    json.encode(data.toJson());

class CompanySahamDividendModel {
  final String code;
  final List<Dividend> dividend;

  CompanySahamDividendModel({
    required this.code,
    required this.dividend,
  });

  factory CompanySahamDividendModel.fromJson(Map<String, dynamic> json) => CompanySahamDividendModel(
    code: json["code"],
    dividend: List<Dividend>.from(
        json["dividend"].map((x) => Dividend.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "code": code,
    "dividend": List<dynamic>.from(dividend.map((x) => x.toJson())),
  };
}

class Dividend {
  final double? price;
  final DateTime? priceDate;
  final double cashDividend;
  final DateTime? cumDividend;
  final DateTime? exDividend;
  final DateTime recordDate;
  final DateTime paymentDate;
  final String note;

  Dividend({
    required this.price,
    required this.priceDate,
    required this.cashDividend,
    required this.cumDividend,
    required this.exDividend,
    required this.recordDate,
    required this.paymentDate,
    required this.note,
  });

  factory Dividend.fromJson(Map<String, dynamic> json) => Dividend(
    price: (json["price"]?.toDouble()),
    priceDate: (json["price_date"] == null ? null : DateTime.parse(json["price_date"])),
    cashDividend: json["cash_dividend"]?.toDouble(),
    cumDividend: (json["cum_dividend"] == null ? null : DateTime.parse(json["cum_dividend"])),
    exDividend: (json["ex_dividend"] == null ? null : DateTime.parse(json["ex_dividend"])),
    recordDate: DateTime.parse(json["record_date"]),
    paymentDate: DateTime.parse(json["payment_date"]),
    note: json["note"],
  );

  Map<String, dynamic> toJson() => {
    "price": price,
    "price_date": (priceDate == null ? null : "${priceDate!.year.toString().padLeft(4, '0')}-${priceDate!.month.toString().padLeft(2, '0')}-${priceDate!.day.toString().padLeft(2, '0')}"),
    "cash_dividend": cashDividend,
    "cum_dividend": (cumDividend == null ? null : "${cumDividend!.year.toString().padLeft(4, '0')}-${cumDividend!.month.toString().padLeft(2, '0')}-${cumDividend!.day.toString().padLeft(2, '0')}"),
    "ex_dividend": (exDividend == null ? null : "${exDividend!.year.toString().padLeft(4, '0')}-${exDividend!.month.toString().padLeft(2, '0')}-${exDividend!.day.toString().padLeft(2, '0')}"),
    "record_date": "${recordDate.year.toString().padLeft(4, '0')}-${recordDate.month.toString().padLeft(2, '0')}-${recordDate.day.toString().padLeft(2, '0')}",
    "payment_date": "${paymentDate.year.toString().padLeft(4, '0')}-${paymentDate.month.toString().padLeft(2, '0')}-${paymentDate.day.toString().padLeft(2, '0')}",
    "note": note,
  };
}
