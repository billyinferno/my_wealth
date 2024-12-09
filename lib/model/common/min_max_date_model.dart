// To parse this JSON data, do
//
//     final brokerSummaryDateModel = brokerSummaryDateModelFromJson(jsonString);

import 'dart:convert';

MinMaxDateModel minMaxDateModelFromJson(String str) => MinMaxDateModel.fromJson(json.decode(str));

String minMaxDateModelToJson(MinMaxDateModel data) => json.encode(data.toJson());

class MinMaxDateModel {
    MinMaxDateModel({
        required this.minDate,
        required this.maxDate,
    });

    final DateTime minDate;
    final DateTime maxDate;

    factory MinMaxDateModel.fromJson(Map<String, dynamic> json) => MinMaxDateModel(
        minDate: DateTime.parse(json["min_date"]),
        maxDate: DateTime.parse(json["max_date"]),
    );

    Map<String, dynamic> toJson() => {
        "min_date": "${minDate.year.toString().padLeft(4, '0')}-${minDate.month.toString().padLeft(2, '0')}-${minDate.day.toString().padLeft(2, '0')}",
        "max_date": "${maxDate.year.toString().padLeft(4, '0')}-${maxDate.month.toString().padLeft(2, '0')}-${maxDate.day.toString().padLeft(2, '0')}",
    };
}
