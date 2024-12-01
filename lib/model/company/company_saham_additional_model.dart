// To parse this JSON data, do
//
//     final companySahamAdditionalModel = companySahamAdditionalModelFromJson(jsonString);

import 'dart:convert';

CompanySahamAdditionalModel companySahamAdditionalModelFromJson(String str) => CompanySahamAdditionalModel.fromJson(json.decode(str));

String companySahamAdditionalModelToJson(CompanySahamAdditionalModel data) => json.encode(data.toJson());

class CompanySahamAdditionalModel {
    final String code;
    final DateTime fromDate;
    final DateTime toDate;
    final double perOptimistic;
    final double perNeutral;
    final double perPesimistic;
    final double perForecastingOptimistic;
    final double perForecastingNeutral;
    final double perForecastingPesimistic;
    final double perPotentialOptimistic;
    final double perPotentialNeutral;
    final double perPotentialPesimistic;
    final double pbvOptimistic;
    final double pbvNeutral;
    final double pbvPesimistic;
    final double pbvForecastingOptimistic;
    final double pbvForecastingNeutral;
    final double pbvForecastingPesimistic;
    final double pbvPotentialOptimistic;
    final double pbvPotentialNeutral;
    final double pbvPotentialPesimistic;
    final double priceOptimistic;
    final double priceNeutral;
    final double pricePesimistic;
    final double pricePotentialOptimistic;
    final double pricePotentialNeutral;
    final double pricePotentialPesimistic;
    final double priceForecastingOptimistic;
    final double priceForecastingNeutral;
    final double priceForecastingPesimistic;

    CompanySahamAdditionalModel({
        required this.code,
        required this.fromDate,
        required this.toDate,
        this.perOptimistic = -1,
        this.perNeutral = -1,
        this.perPesimistic = -1,
        this.perForecastingOptimistic = -1,
        this.perForecastingNeutral = -1,
        this.perForecastingPesimistic = -1,
        this.perPotentialOptimistic = -1,
        this.perPotentialNeutral = -1,
        this.perPotentialPesimistic = -1,
        this.pbvOptimistic = -1,
        this.pbvNeutral = -1,
        this.pbvPesimistic = -1,
        this.pbvForecastingOptimistic = -1,
        this.pbvForecastingNeutral = -1,
        this.pbvForecastingPesimistic = -1,
        this.pbvPotentialOptimistic = -1,
        this.pbvPotentialNeutral = -1,
        this.pbvPotentialPesimistic = -1,
        this.priceOptimistic = -1,
        this.priceNeutral = -1,
        this.pricePesimistic = -1,
        this.pricePotentialOptimistic = -1,
        this.pricePotentialNeutral = -1,
        this.pricePotentialPesimistic = -1,
        this.priceForecastingOptimistic = -1,
        this.priceForecastingNeutral = -1,
        this.priceForecastingPesimistic = -1,
    });

    factory CompanySahamAdditionalModel.fromJson(Map<String, dynamic> json) => CompanySahamAdditionalModel(
        code: json["code"],
        fromDate: DateTime.parse(json["from_date"]),
        toDate: DateTime.parse(json["to_date"]),
        perOptimistic: json["per_optimistic"]?.toDouble(),
        perNeutral: json["per_neutral"]?.toDouble(),
        perPesimistic: json["per_pesimistic"]?.toDouble(),
        perForecastingOptimistic: json["per_forecasting_optimistic"]?.toDouble(),
        perForecastingNeutral: json["per_forecasting_neutral"]?.toDouble(),
        perForecastingPesimistic: json["per_forecasting_pesimistic"]?.toDouble(),
        perPotentialOptimistic: json["per_potential_optimistic"]?.toDouble(),
        perPotentialNeutral: json["per_potential_neutral"]?.toDouble(),
        perPotentialPesimistic: json["per_potential_pesimistic"]?.toDouble(),
        pbvOptimistic: json["pbv_optimistic"]?.toDouble(),
        pbvNeutral: json["pbv_neutral"]?.toDouble(),
        pbvPesimistic: json["pbv_pesimistic"]?.toDouble(),
        pbvForecastingOptimistic: json["pbv_forecasting_optimistic"]?.toDouble(),
        pbvForecastingNeutral: json["pbv_forecasting_neutral"]?.toDouble(),
        pbvForecastingPesimistic: json["pbv_forecasting_pesimistic"]?.toDouble(),
        pbvPotentialOptimistic: json["pbv_potential_optimistic"]?.toDouble(),
        pbvPotentialNeutral: json["pbv_potential_neutral"]?.toDouble(),
        pbvPotentialPesimistic: json["pbv_potential_pesimistic"]?.toDouble(),
        priceOptimistic: json["price_optimistic"]?.toDouble(),
        priceNeutral: json["price_neutral"]?.toDouble(),
        pricePesimistic: json["price_pesimistic"]?.toDouble(),
        pricePotentialOptimistic: json["price_potential_optimistic"]?.toDouble(),
        pricePotentialNeutral: json["price_potential_neutral"]?.toDouble(),
        pricePotentialPesimistic: json["price_potential_pesimistic"]?.toDouble(),
        priceForecastingOptimistic: json["price_forecasting_optimistic"]?.toDouble(),
        priceForecastingNeutral: json["price_forecasting_neutral"]?.toDouble(),
        priceForecastingPesimistic: json["price_forecasting_pesimistic"]?.toDouble(),
    );

    Map<String, dynamic> toJson() => {
        "code": code,
        "from_date": "${fromDate.year.toString().padLeft(4, '0')}-${fromDate.month.toString().padLeft(2, '0')}-${fromDate.day.toString().padLeft(2, '0')}",
        "to_date": "${toDate.year.toString().padLeft(4, '0')}-${toDate.month.toString().padLeft(2, '0')}-${toDate.day.toString().padLeft(2, '0')}",
        "per_optimistic": perOptimistic,
        "per_neutral": perNeutral,
        "per_pesimistic": perPesimistic,
        "per_forecasting_optimistic": perForecastingOptimistic,
        "per_forecasting_neutral": perForecastingNeutral,
        "per_forecasting_pesimistic": perForecastingPesimistic,
        "per_potential_optimistic": perPotentialOptimistic,
        "per_potential_neutral": perPotentialNeutral,
        "per_potential_pesimistic": perPotentialPesimistic,
        "pbv_optimistic": pbvOptimistic,
        "pbv_neutral": pbvNeutral,
        "pbv_pesimistic": pbvPesimistic,
        "pbv_forecasting_optimistic": pbvForecastingOptimistic,
        "pbv_forecasting_neutral": pbvForecastingNeutral,
        "pbv_forecasting_pesimistic": pbvForecastingPesimistic,
        "pbv_potential_optimistic": pbvPotentialOptimistic,
        "pbv_potential_neutral": pbvPotentialNeutral,
        "pbv_potential_pesimistic": pbvPotentialPesimistic,
        "price_optimistic": priceOptimistic,
        "price_neutral": priceNeutral,
        "price_pesimistic": pricePesimistic,
        "price_potential_optimistic": pricePotentialOptimistic,
        "price_potential_neutral": pricePotentialNeutral,
        "price_potential_pesimistic": pricePotentialPesimistic,
        "price_forecasting_optimistic": priceForecastingOptimistic,
        "price_forecasting_neutral": priceForecastingNeutral,
        "price_forecasting_pesimistic": priceForecastingPesimistic,
    };
}
