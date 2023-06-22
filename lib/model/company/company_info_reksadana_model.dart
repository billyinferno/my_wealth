// To parse this JSON data, do
//
//     final infoReksadanaModel = infoReksadanaModelFromJson(jsonString);

import 'dart:convert';

InfoReksadanaModel infoReksadanaModelFromJson(String str) => InfoReksadanaModel.fromJson(json.decode(str));

String infoReksadanaModelToJson(InfoReksadanaModel data) => json.encode(data.toJson());

class InfoReksadanaModel {
    final DateTime date;
    final double netAssetValue;
    final double dailyReturn;
    final double weeklyReturn;
    final double monthlyReturn;
    final double quarterlyReturn;
    final double semiAnnualReturn;
    final double ytdReturn;
    final double yearlyReturn;
    final double assetUnderManagement;
    final double totalUnit;

    InfoReksadanaModel({
        required this.date,
        required this.netAssetValue,
        required this.dailyReturn,
        required this.weeklyReturn,
        required this.monthlyReturn,
        required this.quarterlyReturn,
        required this.semiAnnualReturn,
        required this.ytdReturn,
        required this.yearlyReturn,
        required this.assetUnderManagement,
        required this.totalUnit,
    });

    factory InfoReksadanaModel.fromJson(Map<String, dynamic> json) => InfoReksadanaModel(
        date: DateTime.parse(json["date"]),
        netAssetValue: (json["net_asset_value"] != null ? json["net_asset_value"]?.toDouble() : 0),
        dailyReturn: (json["daily_return"] != null ? json["daily_return"]?.toDouble() : 0),
        weeklyReturn: (json["weekly_return"] != null ? json["weekly_return"]?.toDouble() : 0),
        monthlyReturn: (json["monthly_return"] != null ? json["monthly_return"]?.toDouble() : 0),
        quarterlyReturn: (json["quarterly_return"] != null ? json["quarterly_return"]?.toDouble() : 0),
        semiAnnualReturn: (json["semi_annual_return"] != null ? json["semi_annual_return"]?.toDouble() : 0),
        ytdReturn: (json["ytd_return"] != null ? json["ytd_return"]?.toDouble() : 0),
        yearlyReturn: (json["yearly_return"] != null ? json["yearly_return"]?.toDouble() : 0),
        assetUnderManagement: (json["asset_under_management"] != null ? json["asset_under_management"]?.toDouble() : 0),
        totalUnit: (json["total_unit"] != null ? json["total_unit"]?.toDouble() : 0),
    );

    Map<String, dynamic> toJson() => {
        "date": "${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}",
        "net_asset_value": netAssetValue,
        "daily_return": dailyReturn,
        "weekly_return": weeklyReturn,
        "monthly_return": monthlyReturn,
        "quarterly_return": quarterlyReturn,
        "semi_annual_return": semiAnnualReturn,
        "ytd_return": ytdReturn,
        "yearly_return": yearlyReturn,
        "asset_under_management": assetUnderManagement,
        "total_unit": totalUnit,
    };
}
