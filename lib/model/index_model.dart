// To parse this JSON data, do
//
//     final indexModel = indexModelFromJson(jsonString);

import 'dart:convert';

IndexModel indexModelFromJson(String str) => IndexModel.fromJson(json.decode(str));

String indexModelToJson(IndexModel data) => json.encode(data.toJson());

class IndexModel {
    IndexModel({
        required this.indexId,
        required this.indexName,
        required this.indexSharia,
        required this.indexNetAssetValue,
        required this.indexPrevPrice,
        required this.indexDailyReturn,
        required this.indexWeeklyReturn,
        required this.indexMtdReturn,
        required this.indexMonthlyReturn,
        required this.indexQuarterlyReturn,
        required this.indexSemiAnnualReturn,
        required this.indexYtdReturn,
        required this.indexYearlyReturn,
        required this.indexLastUpdate,
    });

    final int indexId;
    final String indexName;
    final bool indexSharia;
    final double indexNetAssetValue;
    final double indexPrevPrice;
    final double indexDailyReturn;
    final double indexWeeklyReturn;
    final double indexMtdReturn;
    final double indexMonthlyReturn;
    final double indexQuarterlyReturn;
    final double indexSemiAnnualReturn;
    final double indexYtdReturn;
    final double indexYearlyReturn;
    final DateTime indexLastUpdate;

    factory IndexModel.fromJson(Map<String, dynamic> json) => IndexModel(
        indexId: json["index_id"],
        indexName: json["index_name"],
        indexSharia: json["index_sharia"],
        indexNetAssetValue: json["index_net_asset_value"].toDouble(),
        indexPrevPrice: json["index_prev_price"].toDouble(),
        indexDailyReturn: json["index_daily_return"].toDouble(),
        indexWeeklyReturn: json["index_weekly_return"].toDouble(),
        indexMtdReturn: json["index_mtd_return"].toDouble(),
        indexMonthlyReturn: json["index_monthly_return"].toDouble(),
        indexQuarterlyReturn: json["index_quarterly_return"].toDouble(),
        indexSemiAnnualReturn: json["index_semi_annual_return"].toDouble(),
        indexYtdReturn: json["index_ytd_return"].toDouble(),
        indexYearlyReturn: json["index_yearly_return"].toDouble(),
        indexLastUpdate: DateTime.parse(json["index_last_update"]),
    );

    Map<String, dynamic> toJson() => {
        "index_id": indexId,
        "index_name": indexName,
        "index_sharia": indexSharia,
        "index_net_asset_value": indexNetAssetValue,
        "index_prev_price": indexPrevPrice,
        "index_daily_return": indexDailyReturn,
        "index_weekly_return": indexWeeklyReturn,
        "index_mtd_return": indexMtdReturn,
        "index_monthly_return": indexMonthlyReturn,
        "index_quarterly_return": indexQuarterlyReturn,
        "index_semi_annual_return": indexSemiAnnualReturn,
        "index_ytd_return": indexYtdReturn,
        "index_yearly_return": indexYearlyReturn,
        "index_last_update": indexLastUpdate.toIso8601String(),
    };
}
