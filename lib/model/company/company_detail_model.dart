// To parse this JSON data, do
//
//     final companyDetailModel = companyDetailModelFromJson(jsonString);

// ignore_for_file: prefer_null_aware_operators

import 'dart:convert';
import 'package:my_wealth/model/price/price_model.dart';

CompanyDetailModel companyDetailModelFromJson(String str) => CompanyDetailModel.fromJson(json.decode(str));

String companyDetailModelToJson(CompanyDetailModel data) => json.encode(data.toJson());

class CompanyDetailModel {
    CompanyDetailModel({
        required this.companyId,
        required this.companyName,
        required this.companyType,
        required this.companyIndustry,
        required this.companySharia,
        this.companyNetAssetValue,
        this.companyPrevPrice,
        this.companyDailyReturn,
        this.companyWeeklyReturn,
        this.companyMonthlyReturn,
        this.companyQuarterlyReturn,
        this.companySemiAnnualReturn,
        this.companyYtdReturn,
        this.companyYearlyReturn,
        this.companyLastUpdate,
        this.companyAssetUnderManagement,
        this.companyTotalUnit,
        this.companyYearlyRating,
        this.companyYearlyRisk,
        this.companyPrevClosingPrice,
        this.companyAdjustedClosingPrice,
        this.companyAdjustedOpenPrice,
        this.companyAdjustedHighPrice,
        this.companyAdjustedLowPrice,
        this.companyFrequency,
        this.companyValue,
        this.companyThreeYear,
        this.companyFiveYear,
        this.companyTenYear,
        this.companyMtd,
        this.companyPer,
        this.companyPbr,
        this.companyBetaOneYear,
        this.companyStdDevOneYear,
        this.companyPerAnnualized,
        this.companyPsrAnnualized,
        this.companyPcfrAnnualized,
        this.companySymbol,
        this.companyCurrentPriceUsd,
        this.companyMarketCap,
        this.companyMarketCapRank,
        this.companyFullyDilutedValuation,
        this.companyHigh24H,
        this.companyLow24H,
        this.companyPriceChange24H,
        this.companyPriceChangePercentage24H,
        this.companyMarketCapChange24H,
        this.companyMarketCapChangePercentage24H,
        this.companyCirculatingSupply,
        this.companyTotalSupply,
        this.companyMaxSupply,
        this.companyAllTimeHigh,
        this.companyAllTimeHighChangePercentage,
        this.companyAllTimeHighDate,
        this.companyAllTimeLow,
        this.companyAllTimeLowChangePercentage,
        this.companyAllTimeLowDate,
        required this.companyPrices,
        this.companyFavourites,
        this.companyFavouritesId,
    });

    final int companyId;
    final String companyName;
    final String companyType;
    final String companyIndustry;
    final bool companySharia;
    final double? companyNetAssetValue;
    final double? companyPrevPrice;
    final double? companyDailyReturn;
    final double? companyWeeklyReturn;
    final double? companyMonthlyReturn;
    final double? companyQuarterlyReturn;
    final double? companySemiAnnualReturn;
    final double? companyYtdReturn;
    final double? companyYearlyReturn;
    final DateTime? companyLastUpdate;
    final double? companyAssetUnderManagement;
    final double? companyTotalUnit;
    final double? companyYearlyRating;
    final double? companyYearlyRisk;
    final double? companyPrevClosingPrice;
    final double? companyAdjustedClosingPrice;
    final double? companyAdjustedOpenPrice;
    final double? companyAdjustedHighPrice;
    final double? companyAdjustedLowPrice;
    final int? companyFrequency;
    final int? companyValue;
    final double? companyThreeYear;
    final double? companyFiveYear;
    final double? companyTenYear;
    final double? companyMtd;
    final double? companyPer;
    final double? companyPbr;
    final double? companyBetaOneYear;
    final double? companyStdDevOneYear;
    final double? companyPerAnnualized;
    final double? companyPsrAnnualized;
    final double? companyPcfrAnnualized;
    final String? companySymbol;
    final double? companyCurrentPriceUsd;
    final double? companyMarketCap;
    final int? companyMarketCapRank;
    final double? companyFullyDilutedValuation;
    final double? companyHigh24H;
    final double? companyLow24H;
    final double? companyPriceChange24H;
    final double? companyPriceChangePercentage24H;
    final double? companyMarketCapChange24H;
    final double? companyMarketCapChangePercentage24H;
    final double? companyCirculatingSupply;
    final double? companyTotalSupply;
    final double? companyMaxSupply;
    final double? companyAllTimeHigh;
    final double? companyAllTimeHighChangePercentage;
    final DateTime? companyAllTimeHighDate;
    final double? companyAllTimeLow;
    final double? companyAllTimeLowChangePercentage;
    final DateTime? companyAllTimeLowDate;
    final List<PriceModel> companyPrices;
    final bool? companyFavourites;
    final int? companyFavouritesId;

    factory CompanyDetailModel.fromJson(Map<String, dynamic> json) {
      return CompanyDetailModel(
        companyId: json["company_id"],
        companyName: json["company_name"],
        companyType: json["company_type"],
        companyIndustry: json["company_industry"],
        companySharia: json["company_sharia"],
        companyNetAssetValue: (json["company_net_asset_value"] == null ? 0 : json["company_net_asset_value"].toDouble()),
        companyPrevPrice: (json["company_prev_price"] == null ? 0 : json["company_prev_price"].toDouble()),
        companyDailyReturn: (json["company_daily_return"] == null ? 0 : json["company_daily_return"].toDouble()),
        companyWeeklyReturn: (json["company_weekly_return"] == null ? 0 : json["company_weekly_return"].toDouble()),
        companyMonthlyReturn: (json["company_monthly_return"] == null ? 0 : json["company_monthly_return"].toDouble()),
        companyQuarterlyReturn: (json["company_quarterly_return"] == null ? 0 : json["company_quarterly_return"].toDouble()),
        companySemiAnnualReturn: (json["company_semi_annual_return"] == null ? 0 : json["company_semi_annual_return"].toDouble()),
        companyYtdReturn: (json["company_ytd_return"] == null ? 0 : json["company_ytd_return"].toDouble()),
        companyYearlyReturn: (json["company_yearly_return"] == null ? 0 : json["company_yearly_return"].toDouble()),
        companyLastUpdate: (json["company_last_update"] == null ? null : DateTime.parse(json["company_last_update"])),
        companyAssetUnderManagement: (json["company_asset_under_management"] == null ? 0 : json["company_asset_under_management"].toDouble()),
        companyTotalUnit: (json["company_total_unit"] == null ? 0 : json["company_total_unit"].toDouble()),
        companyYearlyRating: (json["company_yearly_rating"] == null ? 0 : json["company_yearly_rating"].toDouble()),
        companyYearlyRisk: (json["company_yearly_risk"] == null ? 0 : json["company_yearly_risk"].toDouble()),
        companyPrevClosingPrice: (json["company_prev_closing_price"] == null ? null : json["company_prev_closing_price"].toDouble()),
        companyAdjustedClosingPrice: (json["company_adjusted_closing_price"] == null ? null : json["company_adjusted_closing_price"].toDouble()),
        companyAdjustedOpenPrice: (json["company_adjusted_open_price"] == null ? null : json["company_adjusted_open_price"].toDouble()),
        companyAdjustedHighPrice: (json["company_adjusted_high_price"] == null ? null : json["company_adjusted_high_price"].toDouble()),
        companyAdjustedLowPrice: (json["company_adjusted_low_price"] == null ? null : json["company_adjusted_low_price"].toDouble()),
        companyFrequency: json["company_frequency"],
        companyValue: json["company_value"],
        companyThreeYear: (json["company_three_year"] == null ? null : json["company_three_year"].toDouble()),
        companyFiveYear: (json["company_five_year"] == null ? null : json["company_five_year"].toDouble()),
        companyTenYear: (json["company_ten_year"] == null ? null : json["company_ten_year"].toDouble()),
        companyMtd: (json["company_mtd"] == null ? null : json["company_mtd"].toDouble()),
        companyPer: (json["company_per"] == null ? null : json["company_per"].toDouble()),
        companyPbr: (json["company_pbr"] == null ? null : json["company_pbr"].toDouble()),
        companyBetaOneYear: (json["company_beta_one_year"] == null ? null : json["company_beta_one_year"].toDouble()),
        companyStdDevOneYear: (json["company_std_dev_one_year"] == null ? null : json["company_std_dev_one_year"].toDouble()),
        companyPerAnnualized: (json["company_per_annualized"] == null ? null : json["company_per_annualized"].toDouble()),
        companyPsrAnnualized: (json["company_psr_annualized"] == null ? null : json["company_psr_annualized"].toDouble()),
        companyPcfrAnnualized: (json["company_pcfr_annualized"] == null ? null : json["company_pcfr_annualized"].toDouble()),
        companySymbol: json["company_symbol"],
        companyCurrentPriceUsd: (json["company_current_price_usd"] == null ? null : json["company_current_price_usd"].toDouble()),
        companyMarketCap: (json["company_market_cap"] == null ? null : json["company_market_cap"].toDouble()),
        companyMarketCapRank: json["company_market_cap_rank"],
        companyFullyDilutedValuation: (json["company_fully_diluted_valuation"] == null ? null : json["company_fully_diluted_valuation"].toDouble()),
        companyHigh24H: (json["company_high_24_h"] == null ? null : json["company_high_24_h"].toDouble()),
        companyLow24H: (json["company_low_24_h"] == null ? null : json["company_low_24_h"].toDouble()),
        companyPriceChange24H: (json["company_price_change_24_h"] == null ? null : json["company_price_change_24_h"].toDouble()),
        companyPriceChangePercentage24H: (json["company_price_change_percentage_24_h"] == null ? null : json["company_price_change_percentage_24_h"].toDouble()),
        companyMarketCapChange24H: (json["company_market_cap_change_24_h"] == null ? null : json["company_market_cap_change_24_h"].toDouble()),
        companyMarketCapChangePercentage24H: (json["company_market_cap_change_percentage_24_h"] == null ? null : json["company_market_cap_change_percentage_24_h"].toDouble()),
        companyCirculatingSupply: (json["company_circulating_supply"] == null ? null : json["company_circulating_supply"].toDouble()),
        companyTotalSupply: (json["company_total_supply"] == null ? null : json["company_total_supply"].toDouble()),
        companyMaxSupply: (json["company_max_supply"] == null ? null : json["company_max_supply"].toDouble()),
        companyAllTimeHigh: (json["company_all_time_high"] == null ? null : json["company_all_time_high"].toDouble()),
        companyAllTimeHighChangePercentage: (json["company_all_time_high_change_percentage"] == null ? null : json["company_all_time_high_change_percentage"].toDouble()),
        companyAllTimeHighDate: (json["company_all_time_high_date"] == null ? null : DateTime.parse(json["company_all_time_high_date"])),
        companyAllTimeLow: (json["company_all_time_low"] == null ? null : json["company_all_time_low"].toDouble()),
        companyAllTimeLowChangePercentage: (json["company_all_time_low_change_percentage"] == null ? null : json["company_all_time_low_change_percentage"].toDouble()),
        companyAllTimeLowDate: (json["company_all_time_low_date"] == null ? null : DateTime.parse(json["company_all_time_low_date"])),
        companyPrices: List<PriceModel>.from(json["company_prices"].map((x) => PriceModel.fromJson(x))),
        companyFavourites: (json["company_favourites"] ?? false),
        companyFavouritesId: (json["company_favourites_id"] ?? -1),
      );
    }

    Map<String, dynamic> toJson() => {
        "company_id": companyId,
        "company_name": companyName,
        "company_type": companyType,
        "company_industry": companyIndustry,
        "company_sharia": companySharia,
        "company_net_asset_value": companyNetAssetValue,
        "company_prev_price": companyPrevPrice,
        "company_daily_return": companyDailyReturn,
        "company_weekly_return": companyWeeklyReturn,
        "company_monthly_return": companyMonthlyReturn,
        "company_quarterly_return": companyQuarterlyReturn,
        "company_semi_annual_return": companySemiAnnualReturn,
        "company_ytd_return": companyYtdReturn,
        "company_yearly_return": companyYearlyReturn,
        "company_last_update": (companyLastUpdate == null ? null : companyLastUpdate!.toIso8601String()),
        "company_asset_under_management": companyAssetUnderManagement,
        "company_total_unit": companyTotalUnit,
        "company_yearly_rating": companyYearlyRating,
        "company_yearly_risk": companyYearlyRisk,
        "company_prev_closing_price": companyPrevClosingPrice,
        "company_adjusted_closing_price": companyAdjustedClosingPrice,
        "company_adjusted_open_price": companyAdjustedOpenPrice,
        "company_adjusted_high_price": companyAdjustedHighPrice,
        "company_adjusted_low_price": companyAdjustedLowPrice,
        "company_frequency": companyFrequency,
        "company_value": companyValue,
        "company_three_year": companyThreeYear,
        "company_five_year": companyFiveYear,
        "company_ten_year": companyTenYear,
        "company_mtd": companyMtd,
        "company_per": companyPer,
        "company_pbr": companyPbr,
        "company_beta_one_year": companyBetaOneYear,
        "company_std_dev_one_year": companyStdDevOneYear,
        "company_per_annualized": companyPerAnnualized,
        "company_psr_annualized": companyPsrAnnualized,
        "company_pcfr_annualized": companyPcfrAnnualized,
        "company_symbol": companySymbol,
        "company_current_price_usd": companyCurrentPriceUsd,
        "company_market_cap": companyMarketCap,
        "company_market_cap_rank": companyMarketCapRank,
        "company_fully_diluted_valuation": companyFullyDilutedValuation,
        "company_high_24_h": companyHigh24H,
        "company_low_24_h": companyLow24H,
        "company_price_change_24_h": companyPriceChange24H,
        "company_price_change_percentage_24_h": companyPriceChangePercentage24H,
        "company_market_cap_change_24_h": companyMarketCapChange24H,
        "company_market_cap_change_percentage_24_h": companyMarketCapChangePercentage24H,
        "company_circulating_supply": companyCirculatingSupply,
        "company_total_supply": companyTotalSupply,
        "company_max_supply": companyMaxSupply,
        "company_all_time_high": companyAllTimeHigh,
        "company_all_time_high_change_percentage": companyAllTimeHighChangePercentage,
        "company_all_time_high_date": (companyAllTimeHighDate == null ? null : companyAllTimeHighDate!.toIso8601String()),
        "company_all_time_low": companyAllTimeLow,
        "company_all_time_low_change_percentage": companyAllTimeLowChangePercentage,
        "company_all_time_low_date": (companyAllTimeLowDate == null ? null : companyAllTimeLowDate!.toIso8601String()),
        "company_prices": List<dynamic>.from(companyPrices.map((x) => x.toJson())),
        "company_favourites": companyFavourites,
        "company_favourites_id": companyFavouritesId,
    };
}
