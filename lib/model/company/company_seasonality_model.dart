// To parse this JSON data, do
//
//     final seasonalityModel = seasonalityModelFromJson(jsonString);
import 'dart:convert';

SeasonalityModel seasonalityModelFromJson(String str) => SeasonalityModel.fromJson(json.decode(str));

String seasonalityModelToJson(SeasonalityModel data) => json.encode(data.toJson());

class SeasonalityModel {
    SeasonalityModel({
        required this.year,
        required this.month,
        required this.averageDiffPrice,
        required this.minDiffPrice,
        required this.maxDiffPrice,
        required this.minLastPrice,
        required this.maxLastPrice,
        this.minPrevPrice,
        this.maxPrevPrice,
    });

    final String year;
    final String month;
    final double averageDiffPrice;
    final double minDiffPrice;
    final double maxDiffPrice;
    final double minLastPrice;
    final double maxLastPrice;
    final double? minPrevPrice;
    final double? maxPrevPrice;

    factory SeasonalityModel.fromJson(Map<String, dynamic> json) => SeasonalityModel(
        year: json["year"],
        month: json["month"],
        averageDiffPrice: (json["average_diff_price"] != null ? json["average_diff_price"]?.toDouble() : 0),
        minDiffPrice: (json["min_diff_price"] != null ? json["min_diff_price"]?.toDouble() : 0),
        maxDiffPrice: (json["max_diff_price"] != null ? json["max_diff_price"]?.toDouble() : 0),
        minLastPrice: (json["min_last_price"] != null ? json["min_last_price"]?.toDouble() : 0),
        maxLastPrice: (json["max_last_price"] != null ? json["max_last_price"]?.toDouble() : 0),
        minPrevPrice: null,
        maxPrevPrice: null,
    );

    Map<String, dynamic> toJson() => {
        "year": year,
        "month": month,
        "average_diff_price": averageDiffPrice,
        "min_diff_price": minDiffPrice,
        "max_diff_price": maxDiffPrice,
        "min_last_price": minLastPrice,
        "max_last_price": maxLastPrice,
    };
}
