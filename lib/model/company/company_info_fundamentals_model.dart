// To parse this JSON data, do
//
//     final infoFundamentalsModel = infoFundamentalsModelFromJson(jsonString);

import 'dart:convert';

InfoFundamentalsModel infoFundamentalsModelFromJson(String str) => InfoFundamentalsModel.fromJson(json.decode(str));

String infoFundamentalsModelToJson(InfoFundamentalsModel data) => json.encode(data.toJson());

class InfoFundamentalsModel {
    InfoFundamentalsModel({
        required this.code,
        this.period,
        this.year,
        this.lastPrice,
        this.shareOut,
        this.marketCap,
        this.cash,
        this.totalAsset,
        this.stBorrowing,
        this.ltBorrowing,
        this.totalEquity,
        this.revenue,
        this.grossProfit,
        this.operatingProfit,
        this.netProfit,
        this.ebitda,
        this.interestExpense,
        this.deviden,
        this.eps,
        this.per,
        this.bvps,
        this.pbv,
        this.roa,
        this.roe,
        this.evEbitda,
        this.debtEquity,
        this.debtTotalcap,
        this.debtEbitda,
        this.ebitdaInterestexpense,
        this.createdAt,
        this.updatedAt,
    });

    final String code;
    final int? period;
    final int? year;
    final int? lastPrice;
    final int? shareOut;
    final int? marketCap;
    final int? cash;
    final int? totalAsset;
    final int? stBorrowing;
    final int? ltBorrowing;
    final int? totalEquity;
    final int? revenue;
    final int? grossProfit;
    final int? operatingProfit;
    final int? netProfit;
    final int? ebitda;
    final int? interestExpense;
    final double? deviden;
    final double? eps;
    final double? per;
    final double? bvps;
    final double? pbv;
    final double? roa;
    final double? roe;
    final double? evEbitda;
    final double? debtEquity;
    final double? debtTotalcap;
    final double? debtEbitda;
    final double? ebitdaInterestexpense;
    final DateTime? createdAt;
    final DateTime? updatedAt;

    factory InfoFundamentalsModel.fromJson(Map<String, dynamic> json) => InfoFundamentalsModel(
        code: json["code"],
        period: json["period"],
        year: json["year"],
        lastPrice: json["last_price"],
        shareOut: json["share_out"],
        marketCap: json["market_cap"],
        cash: json["cash"],
        totalAsset: json["total_asset"],
        stBorrowing: json["st_borrowing"],
        ltBorrowing: json["lt_borrowing"],
        totalEquity: json["total_equity"],
        revenue: json["revenue"],
        grossProfit: json["gross_profit"],
        operatingProfit: json["operating_profit"],
        netProfit: json["net_profit"],
        ebitda: json["ebitda"],
        interestExpense: json["interest_expense"],
        deviden: json["deviden"].toDouble(),
        eps: json["eps"].toDouble(),
        per: json["per"].toDouble(),
        bvps: json["bvps"].toDouble(),
        pbv: json["pbv"].toDouble(),
        roa: json["roa"].toDouble(),
        roe: json["roe"].toDouble(),
        evEbitda: json["ev_ebitda"].toDouble(),
        debtEquity: json["debt_equity"].toDouble(),
        debtTotalcap: json["debt_totalcap"].toDouble(),
        debtEbitda: json["debt_ebitda"].toDouble(),
        ebitdaInterestexpense: json["ebitda_interestexpense"].toDouble(),
        createdAt: (json["created_at"] == null ? null : DateTime.parse(json["created_at"])),
        updatedAt: (json["updated_at"] == null ? null : DateTime.parse(json["updated_at"])),
    );

    Map<String, dynamic> toJson() => {
        "code": code,
        "period": period,
        "year": year,
        "last_price": lastPrice,
        "share_out": shareOut,
        "market_cap": marketCap,
        "cash": cash,
        "total_asset": totalAsset,
        "st_borrowing": stBorrowing,
        "lt_borrowing": ltBorrowing,
        "total_equity": totalEquity,
        "revenue": revenue,
        "gross_profit": grossProfit,
        "operating_profit": operatingProfit,
        "net_profit": netProfit,
        "ebitda": ebitda,
        "interest_expense": interestExpense,
        "deviden": deviden,
        "eps": eps,
        "per": per,
        "bvps": bvps,
        "pbv": pbv,
        "roa": roa,
        "roe": roe,
        "ev_ebitda": evEbitda,
        "debt_equity": debtEquity,
        "debt_totalcap": debtTotalcap,
        "debt_ebitda": debtEbitda,
        "ebitda_interestexpense": ebitdaInterestexpense,
        "created_at": (createdAt == null ? null : createdAt!.toIso8601String()),
        "updated_at": (updatedAt == null ? null : updatedAt!.toIso8601String()),
    };
}
