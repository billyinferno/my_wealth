import 'package:flutter/cupertino.dart';
import 'package:my_wealth/model/broker/broker_top_transaction_model.dart';
import 'package:my_wealth/model/insight/insight_bandar_interest_model.dart';
import 'package:my_wealth/model/insight/insight_accumulation_model.dart';
import 'package:my_wealth/model/insight/insight_market_cap_model.dart';
import 'package:my_wealth/model/insight/insight_market_today_model.dart';
import 'package:my_wealth/model/insight/insight_sector_summary_model.dart';
import 'package:my_wealth/model/insight/insight_stock_collect_model.dart';
import 'package:my_wealth/model/insight/insight_stock_dividend_list_model.dart';
import 'package:my_wealth/model/insight/insight_stock_new_listed_model.dart';
import 'package:my_wealth/model/insight/insight_stock_split_list_model.dart';
import 'package:my_wealth/model/insight/insight_top_worse_company_list_model.dart';

class InsightProvider extends ChangeNotifier {
  List<SectorSummaryModel>? sectorSummaryList;
  TopWorseCompanyListModel? topCompanyList;
  TopWorseCompanyListModel? worseCompanyList;
  Map<String, TopWorseCompanyListModel>? topReksadanaList;
  Map<String, TopWorseCompanyListModel>? worseReksadanaList;
  BrokerTopTransactionModel? brokerTopTransactionList;
  InsightBandarInterestModel? bandarInterestList;
  DateTime? topAccumToDate;
  int? topAccumRate;
  List<InsightAccumulationModel>? topAccumList;
  MarketTodayModel? brokerMarketToday;
  List<MarketCapModel>? marketCap;
  List<StockNewListedModel>? stockNewListed;
  List<StockDividendListModel>? stockDividendList;
  List<StockSplitListModel>? stockSplitList;
  List<InsightStockCollectModel>? stockCollectList;

  setSectorSummaryList(List<SectorSummaryModel> list) {
    sectorSummaryList = list;
    notifyListeners();
  }

  setTopWorseCompanyList(String type, TopWorseCompanyListModel data) {
    if (type == 'top') {
      topCompanyList = data;
    }
    else if (type == 'worse') {
      worseCompanyList = data;
    }
    notifyListeners();
  }

  setBrokerTopTransactionList(BrokerTopTransactionModel data) {
    brokerTopTransactionList = data;
    notifyListeners();
  }

  setTopReksadanaList(String type, TopWorseCompanyListModel data) {
    // check if null? if so initialze it
    topReksadanaList ??= {};

    // check if the key already there or not?
    topReksadanaList![type] = data;
    notifyListeners();
  }

  setWorseReksadanaList(String type, TopWorseCompanyListModel data) {
    // check if null? if so initialze it
    worseReksadanaList ??= {};

    // check if the key already there or not?
    worseReksadanaList![type] = data;
    notifyListeners();
  }

  setBandarInterestingList(InsightBandarInterestModel data) {
    bandarInterestList = data;
    notifyListeners();
  }

  setTopAccumulation(DateTime accumeDate, int accumRate, List<InsightAccumulationModel> accumList) {
    topAccumToDate = accumeDate;
    topAccumRate = accumRate;
    topAccumList = accumList;

    notifyListeners();
  }

  setBrokerMarketToday(MarketTodayModel data) {
    brokerMarketToday = data;
    notifyListeners();
  }

  setMarketCap(List<MarketCapModel> data) {
    marketCap = data;
    notifyListeners();
  }

  setStockNewListed(List<StockNewListedModel> data) {
    stockNewListed = data;
    notifyListeners();
  }

  setStockDividendList(List<StockDividendListModel> data) {
    stockDividendList = data;
    notifyListeners();
  }

  setStockSplitList(List<StockSplitListModel> data) {
    stockSplitList = data;
    notifyListeners();
  }

  setStockCollectList(List<InsightStockCollectModel> data) {
    stockCollectList = data;
    notifyListeners();
  }
}