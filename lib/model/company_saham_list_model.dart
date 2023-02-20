// To parse this JSON data, do
//
//     final companySahamListModel = companySahamListModelFromJson(jsonString);
import 'dart:convert';

CompanySahamListModel companySahamListModelFromJson(String str) => CompanySahamListModel.fromJson(json.decode(str));

String companySahamListModelToJson(CompanySahamListModel data) => json.encode(data.toJson());

class CompanySahamListModel {
    CompanySahamListModel({
        required this.code,
        required this.name,
        required this.lastPrice,
    });

    final String code;
    final String name;
    final int? lastPrice;

    factory CompanySahamListModel.fromJson(Map<String, dynamic> json) => CompanySahamListModel(
        code: json["code"],
        name: json["name"],
        lastPrice: (json["last_price"] ?? 0)
    );

    Map<String, dynamic> toJson() => {
        "code": code,
        "name": name,
        "last_price": lastPrice,
    };
}
