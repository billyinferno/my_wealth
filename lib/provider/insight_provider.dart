import 'package:flutter/cupertino.dart';
import 'package:my_wealth/_index.g.dart';

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

  void setSectorSummaryList({required List<SectorSummaryModel> list}) {
    sectorSummaryList = list;
    notifyListeners();
  }

  void setTopWorseCompanyList({
    required String type,
    required TopWorseCompanyListModel data
  }) {
    if (type == 'top') {
      topCompanyList = data;
    }
    else if (type == 'worse') {
      worseCompanyList = data;
    }
    notifyListeners();
  }

  void setBrokerTopTransactionList({required BrokerTopTransactionModel data}) {
    brokerTopTransactionList = data;
    notifyListeners();
  }

  void setTopReksadanaList({
    required String type,
    required TopWorseCompanyListModel data
  }) {
    // check if null? if so initialze it
    topReksadanaList ??= {};

    // check if the key already there or not?
    topReksadanaList![type] = data;
    notifyListeners();
  }

  void setWorseReksadanaList({
    required String type,
    required TopWorseCompanyListModel data
  }) {
    // check if null? if so initialze it
    worseReksadanaList ??= {};

    // check if the key already there or not?
    worseReksadanaList![type] = data;
    notifyListeners();
  }

  void setBandarInterestingList({required InsightBandarInterestModel data}) {
    bandarInterestList = data;
    notifyListeners();
  }

  void setTopAccumulation({
    required DateTime accumeDate,
    required int accumRate,
    required List<InsightAccumulationModel> accumList
  }) {
    topAccumToDate = accumeDate;
    topAccumRate = accumRate;
    topAccumList = accumList;

    notifyListeners();
  }

  void setBrokerMarketToday({required MarketTodayModel data}) {
    brokerMarketToday = data;
    notifyListeners();
  }

  void setMarketCap({required List<MarketCapModel> data}) {
    marketCap = data;
    notifyListeners();
  }

  void setStockNewListed({required List<StockNewListedModel> data}) {
    stockNewListed = data;
    notifyListeners();
  }

  void setStockDividendList({required List<StockDividendListModel> data}) {
    stockDividendList = data;
    notifyListeners();
  }

  void setStockSplitList({required List<StockSplitListModel> data}) {
    stockSplitList = data;
    notifyListeners();
  }

  void setStockCollectList({required List<InsightStockCollectModel> data}) {
    stockCollectList = data;
    notifyListeners();
  }
}