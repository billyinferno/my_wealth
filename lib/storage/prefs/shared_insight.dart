import 'dart:convert';
import 'package:my_wealth/model/broker/broker_top_transaction_model.dart';
import 'package:my_wealth/model/index/index_beater_model.dart';
import 'package:my_wealth/model/insight/insight_bandar_interest_model.dart';
import 'package:my_wealth/model/insight/insight_accumulation_model.dart';
import 'package:my_wealth/model/insight/insight_broker_collect_model.dart';
import 'package:my_wealth/model/insight/insight_eps_model.dart';
import 'package:my_wealth/model/insight/insight_sideway_model.dart';
import 'package:my_wealth/model/insight/insight_market_cap_model.dart';
import 'package:my_wealth/model/insight/insight_market_today_model.dart';
import 'package:my_wealth/model/insight/insight_sector_summary_model.dart';
import 'package:my_wealth/model/insight/insight_stock_collect_model.dart';
import 'package:my_wealth/model/insight/insight_stock_dividend_list_model.dart';
import 'package:my_wealth/model/insight/insight_stock_new_listed_model.dart';
import 'package:my_wealth/model/insight/insight_stock_split_list_model.dart';
import 'package:my_wealth/model/insight/insight_top_worse_company_list_model.dart';
import 'package:my_wealth/storage/box/local_box.dart';

class InsightSharedPreferences {
  static const _sectorSummaryKey = "sector_summary";
  static const _topWorseCompanyListKey = "insight_company_list_";
  static const _topReksadanaListKey = "insight_reksadana_list_";
  static const _worseReksadanaListKey = "insight_reksadana_worse_list_";
  static const _brokerTopTransactionKey = "insight_broker_top_txn";
  static const _brokerMarketToday = "insight_broker_market_today";
  static const _bandarInterestingKey = "insight_bandar_interesting";
  static const _topAccumFromDateKey = "insight_top_accum_from_date";
  static const _topAccumToDateKey = "insight_top_accum_to_date";
  static const _topAccumRateKey = "insight_top_accum_rate";
  static const _topAccumResultKey = "insight_top_accum_result";
  static const _epsMinRateKey = "insight_eps_min_rate";
  static const _epsMinDiffRateKey = "insight_eps_min_diff_rate";
  static const _epsResultKey = "insight_eps_result";
  static const _sidewayOneDayRateKey = "insight_sideway_one_day_rate";
  static const _sidewayAvgOneDayKey = "insight_sideway_avg_one_day";
  static const _sidewayAvgOneWeekKey = "insight_sideway_avg_one_week";
  static const _sidewayResultKey = "insight_sideway_result";
  static const _marketCapKey = "insight_market_cap";
  static const _indexBeaterKey = "insight_index_beater";
  static const _stockNewListedKey = "insight_stock_new_listed";
  static const _stockDividendListKey = "insight_stock_dividend_list";
  static const _stockSplitListKey = "insight_stock_split_list";
  static const _stockCollectKey = "insight_stock_collect";
  static const _stockCollectFromDateKey = "insight_stock_collect_from_date";
  static const _stockCollectToDateKey = "insight_stock_collect_to_date";
  static const _stockCollectAccumRateKey = "insight_stock_collect_accum_rate";
  static const _brokerCollectKey = "insight_broker_collect";
  static const _brokerCollectIDKey = "insight_broker_collect_id";
  static const _brokerCollectFromDateKey = "insight_broker_collect_from_date";
  static const _brokerCollectToDateKey = "insight_broker_collect_to_date";
  static const _brokerCollectAccumRateKey = "insight_broker_collect_accum_rate";

  static Future<void> setSectorSummaryList(List<SectorSummaryModel> sectorSummaryList) async {
    // stored the user info to box
    if(LocalBox.keyBox == null) {
      LocalBox.init();
    }

    // convert the json to string so we can stored it on the local storage
    List<String> sectorSummaryListResp = [];
    for (SectorSummaryModel sector in sectorSummaryList) {
      sectorSummaryListResp.add(jsonEncode(sector.toJson()));
    }
    LocalBox.putStringList(_sectorSummaryKey, sectorSummaryListResp);
  }

  static List<SectorSummaryModel> getSectorSummaryList() {
    // check if the key box is null or not?
    if(LocalBox.keyBox == null) {
      LocalBox.init();
    }

    // get the data from local box
    List<String> sectorSummaryList = (LocalBox.getStringList(_sectorSummaryKey) ?? []);

    // check if the list is empty or not?
    if (sectorSummaryList.isNotEmpty) {
      // list is not empty, parse the string to FavouriteModel
      List<SectorSummaryModel> ret = [];
      for (String sectorString in sectorSummaryList) {
        SectorSummaryModel sector = SectorSummaryModel.fromJson(jsonDecode(sectorString));
        ret.add(sector);
      }

      // return the favourites list
      return ret;
    }
    else {
      // no data
      return [];
    }
  }

  static Future<void> setTopWorseCompanyList(String type, TopWorseCompanyListModel topWorseList) async {
    // stored the user info to box
    if(LocalBox.keyBox == null) {
      LocalBox.init();
    }

    // convert the json to string so we can stored it on the local storage
    String topWorseString = jsonEncode(topWorseList.toJson());
    LocalBox.putString(_topWorseCompanyListKey + type, topWorseString);
  }

  static TopWorseCompanyListModel getTopWorseCompanyList(String type) {
    // check if the key box is null or not?
    if(LocalBox.keyBox == null) {
      LocalBox.init();
    }

    // get the data from local box
    String topWorseString = (LocalBox.getString(_topWorseCompanyListKey + type) ?? '');

    // check if the list is empty or not?
    if (topWorseString.isNotEmpty) {
      // string is not empty parse it
      TopWorseCompanyListModel topWorse = TopWorseCompanyListModel.fromJson(jsonDecode(topWorseString));
      // return the top worse
      return topWorse;
    }
    else {
      // no data
      return TopWorseCompanyListModel(
        companyList: CompanyList(
          the1D: [],
          the1M: [],
          the1W: [],
          the1Y: [],
          the3M: [],
          the3Y: [],
          the5Y: [],
          the6M: [],
          theYTD: [],
          theMTD: [])
        );
    }
  }

  static Future<void> setBrokerTopTxn(BrokerTopTransactionModel brokerTopList) async {
    // stored the user info to box
    if(LocalBox.keyBox == null) {
      LocalBox.init();
    }

    // convert the json to string so we can stored it on the local storage
    String brokerTopListString = jsonEncode(brokerTopList.toJson());
    LocalBox.putString(_brokerTopTransactionKey, brokerTopListString);
  }

  static BrokerTopTransactionModel getBrokerTopTxn() {
    // check if the key box is null or not?
    if(LocalBox.keyBox == null) {
      LocalBox.init();
    }

    // get the data from local box
    String brokerTopListString = (LocalBox.getString(_brokerTopTransactionKey) ?? '');

    // check if the list is empty or not?
    if (brokerTopListString.isNotEmpty) {
      // string is not empty parse it
      BrokerTopTransactionModel brokerTopList = BrokerTopTransactionModel.fromJson(jsonDecode(brokerTopListString));
      // return the top worse
      return brokerTopList;
    }
    else {
      // no data
      return BrokerTopTransactionModel(
        brokerSummaryDate: DateTime.now(),
        all: BuySell(buy: [], sell: []),
        domestic: BuySell(buy: [], sell: []),
        foreign: BuySell(buy: [], sell: []),
      );
    }
  }

  static Future<void> setTopReksadanaList(String type, TopWorseCompanyListModel topReksadanaList) async {
    // stored the user info to box
    if(LocalBox.keyBox == null) {
      LocalBox.init();
    }

    // convert the json to string so we can stored it on the local storage
    String topReksadanaString = jsonEncode(topReksadanaList.toJson());
    LocalBox.putString(_topReksadanaListKey + type, topReksadanaString);
  }

  static TopWorseCompanyListModel getTopReksadanaList(String type) {
    // check if the key box is null or not?
    if(LocalBox.keyBox == null) {
      LocalBox.init();
    }

    // get the data from local box
    String topReksadanaString = (LocalBox.getString(_topReksadanaListKey + type) ?? '');

    // check if the list is empty or not?
    if (topReksadanaString.isNotEmpty) {
      // string is not empty parse it
      TopWorseCompanyListModel topReksadana = TopWorseCompanyListModel.fromJson(jsonDecode(topReksadanaString));
      // return the top worse
      return topReksadana;
    }
    else {
      // no data
      return TopWorseCompanyListModel(
        companyList: CompanyList(
          the1D: [],
          the1M: [],
          the1W: [],
          the1Y: [],
          the3M: [],
          the3Y: [],
          the5Y: [],
          the6M: [],
          theYTD: [],
          theMTD: [])
        );
    }
  }

  static Future<void> setWorseReksadanaList(String type, TopWorseCompanyListModel worseReksadanaList) async {
    // stored the user info to box
    if(LocalBox.keyBox == null) {
      LocalBox.init();
    }

    // convert the json to string so we can stored it on the local storage
    String worseReksadanaString = jsonEncode(worseReksadanaList.toJson());
    LocalBox.putString(_worseReksadanaListKey + type, worseReksadanaString);
  }

  static TopWorseCompanyListModel getWorseReksadanaList(String type) {
    // check if the key box is null or not?
    if(LocalBox.keyBox == null) {
      LocalBox.init();
    }

    // get the data from local box
    String worseReksadanaString = (LocalBox.getString(_worseReksadanaListKey + type) ?? '');

    // check if the list is empty or not?
    if (worseReksadanaString.isNotEmpty) {
      // string is not empty parse it
      TopWorseCompanyListModel worseReksadana = TopWorseCompanyListModel.fromJson(jsonDecode(worseReksadanaString));
      // return the top worse
      return worseReksadana;
    }
    else {
      // no data
      return TopWorseCompanyListModel(
        companyList: CompanyList(
          the1D: [],
          the1M: [],
          the1W: [],
          the1Y: [],
          the3M: [],
          the3Y: [],
          the5Y: [],
          the6M: [],
          theYTD: [],
          theMTD: [])
        );
    }
  }

  static Future<void> setBandarInterestingList(InsightBandarInterestModel bandarInterest) async {
    // stored the user info to box
    if(LocalBox.keyBox == null) {
      LocalBox.init();
    }

    // convert the json to string so we can stored it on the local storage
    String bandarInterestString = jsonEncode(bandarInterest.toJson());
    LocalBox.putString(_bandarInterestingKey, bandarInterestString);
  }

  static InsightBandarInterestModel getBandarInterestingList() {
    // check if the key box is null or not?
    if(LocalBox.keyBox == null) {
      LocalBox.init();
    }

    // get the data from local box
    String bandarInterestString = (LocalBox.getString(_bandarInterestingKey) ?? '');

    // check if the list is empty or not?
    if (bandarInterestString.isNotEmpty) {
      // string is not empty parse it
      InsightBandarInterestModel bandarInterest = InsightBandarInterestModel.fromJson(jsonDecode(bandarInterestString));
      // return the top worse
      return bandarInterest;
    }
    else {
      // no data
      return InsightBandarInterestModel(
        atl: [],
        nonAtl: [],
      );
    }
  }

  static Future<void> setTopAccumulation(DateTime fromDate, DateTime toDate, int rate, List<InsightAccumulationModel> accum) async {
    // stored the user info to box
    if(LocalBox.keyBox == null) {
      LocalBox.init();
    }

    // store the from and to date
    LocalBox.putString(_topAccumFromDateKey, fromDate.toString());
    LocalBox.putString(_topAccumToDateKey, toDate.toString());

    // store the rate
    LocalBox.putString(_topAccumRateKey, rate.toString());

    // store the accum list
    List<String> strAccum = [];
    for (InsightAccumulationModel data in accum) {
      strAccum.add(jsonEncode(data.toJson()));
    }
    LocalBox.putStringList(_topAccumResultKey, strAccum);
  }

  static DateTime getTopAccumulationFromDate() {
    // check if the key box is null or not?
    if(LocalBox.keyBox == null) {
      LocalBox.init();
    }

    // get the data from local box
    String fromDateString = (LocalBox.getString(_topAccumFromDateKey) ?? '');
    if (fromDateString.isNotEmpty) {
      return DateTime.parse(fromDateString);
    }

    return DateTime.now().add(const Duration(days: -7)); // default 7 days before
  }

  static DateTime getTopAccumulationToDate() {
    // check if the key box is null or not?
    if(LocalBox.keyBox == null) {
      LocalBox.init();
    }

    // get the data from local box
    String toDateString = (LocalBox.getString(_topAccumToDateKey) ?? '');
    if (toDateString.isNotEmpty) {
      return DateTime.parse(toDateString);
    }

    return DateTime.now(); // default to today time
  }

  static int getTopAccumulationRate() {
    // check if the key box is null or not?
    if(LocalBox.keyBox == null) {
      LocalBox.init();
    }

    // get the data from local box
    String rateString = (LocalBox.getString(_topAccumRateKey) ?? '');
    if (rateString.isNotEmpty) {
      return int.parse(rateString);
    }

    // default it as 8%
    return 8;
  }

  static List<InsightAccumulationModel> getTopAccumulationResult() {
    // check if the key box is null or not?
    if(LocalBox.keyBox == null) {
      LocalBox.init();
    }

    // get the data from local box
    List<String> accumString = (LocalBox.getStringList(_topAccumResultKey) ?? []);
    if (accumString.isNotEmpty) {
      // loop thru the stringList
      List<InsightAccumulationModel> accumResult = [];
      for (String accumData in accumString) {
        InsightAccumulationModel accum = InsightAccumulationModel.fromJson(jsonDecode(accumData));
        accumResult.add(accum);
      }

      return accumResult;
    }

    // default it as empty array
    return [];
  }

  static Future<void> clearTopAccumulation() async {
    // check if the key box is null or not?
    if(LocalBox.keyBox == null) {
      // null no need to clear
      return;
    }

    // clear all the key for the topAccumulation
    LocalBox.delete(_topAccumFromDateKey, true);
    LocalBox.delete(_topAccumToDateKey, true);
    LocalBox.delete(_topAccumRateKey, true);
    LocalBox.delete(_topAccumResultKey, true);
  }

  static Future<void> setEps(int minRate, int diffRate, List<InsightEpsModel> epsList) async {
    // stored the user info to box
    if(LocalBox.keyBox == null) {
      LocalBox.init();
    }

    // store the from and to date
    LocalBox.putString(_epsMinRateKey, minRate.toString());
    LocalBox.putString(_epsMinDiffRateKey, diffRate.toString());

    // store the accum list
    List<String> strEps = [];
    for (InsightEpsModel data in epsList) {
      strEps.add(jsonEncode(data.toJson()));
    }
    LocalBox.putStringList(_epsResultKey, strEps);
  }

  static int getEpsMinRate() {
    // check if the key box is null or not?
    if(LocalBox.keyBox == null) {
      LocalBox.init();
    }

    // get the data from local box
    String rateString = (LocalBox.getString(_epsMinRateKey) ?? '');
    if (rateString.isNotEmpty) {
      return int.parse(rateString);
    }

    // default it as 0%
    return 0;
  }

  static int getEpsMinDiffRate() {
    // check if the key box is null or not?
    if(LocalBox.keyBox == null) {
      LocalBox.init();
    }

    // get the data from local box
    String rateString = (LocalBox.getString(_epsMinDiffRateKey) ?? '');
    if (rateString.isNotEmpty) {
      return int.parse(rateString);
    }

    // default it as 5%
    return 5;
  }

  static List<InsightEpsModel> getEpsResult() {
    // check if the key box is null or not?
    if(LocalBox.keyBox == null) {
      LocalBox.init();
    }

    // get the data from local box
    List<String> epsString = (LocalBox.getStringList(_epsResultKey) ?? []);
    if (epsString.isNotEmpty) {
      // loop thru the stringList
      List<InsightEpsModel> epsResult = [];
      for (String epsData in epsString) {
        InsightEpsModel eps = InsightEpsModel.fromJson(jsonDecode(epsData));
        epsResult.add(eps);
      }

      return epsResult;
    }

    // default it as empty array
    return [];
  }

  static Future<void> clearEps() async {
    // check if the key box is null or not?
    if(LocalBox.keyBox == null) {
      // null no need to clear
      return;
    }

    // clear all the key for the eps data
    LocalBox.delete(_epsMinRateKey, true);
    LocalBox.delete(_epsMinDiffRateKey, true);
    LocalBox.delete(_epsResultKey, true);
  }

  static Future<void> setSideway(int oneDay, int avgOneDay, int avgOneWeek, List<InsightSidewayModel> sidewayList) async {
    // stored the user info to box
    if(LocalBox.keyBox == null) {
      LocalBox.init();
    }

    // store the from and to date
    LocalBox.putString(_sidewayOneDayRateKey, oneDay.toString());
    LocalBox.putString(_sidewayAvgOneDayKey, avgOneDay.toString());
    LocalBox.putString(_sidewayAvgOneWeekKey, avgOneWeek.toString());

    // store the accum list
    List<String> strSideway = [];
    for (InsightSidewayModel data in sidewayList) {
      strSideway.add(jsonEncode(data.toJson()));
    }
    LocalBox.putStringList(_sidewayResultKey, strSideway);
  }

  static int getSidewayOneDayRate() {
    // check if the key box is null or not?
    if(LocalBox.keyBox == null) {
      LocalBox.init();
    }

    // get the data from local box
    String rateString = (LocalBox.getString(_sidewayOneDayRateKey) ?? '');
    if (rateString.isNotEmpty) {
      return int.parse(rateString);
    }

    // default it as 5%
    return 5;
  }

  static int getSidewayAvgOneDay() {
    // check if the key box is null or not?
    if(LocalBox.keyBox == null) {
      LocalBox.init();
    }

    // get the data from local box
    String rateString = (LocalBox.getString(_sidewayAvgOneDayKey) ?? '');
    if (rateString.isNotEmpty) {
      return int.parse(rateString);
    }

    // default it as 1%
    return 1;
  }

  static int getSidewayAvgOneWeek() {
    // check if the key box is null or not?
    if(LocalBox.keyBox == null) {
      LocalBox.init();
    }

    // get the data from local box
    String rateString = (LocalBox.getString(_sidewayAvgOneWeekKey) ?? '');
    if (rateString.isNotEmpty) {
      return int.parse(rateString);
    }

    // default it as 1%
    return 1;
  }

  static List<InsightSidewayModel> getSidewayResult() {
    // check if the key box is null or not?
    if(LocalBox.keyBox == null) {
      LocalBox.init();
    }

    // get the data from local box
    List<String> sidewaysString = (LocalBox.getStringList(_sidewayResultKey) ?? []);
    if (sidewaysString.isNotEmpty) {
      // loop thru the stringList
      List<InsightSidewayModel> sidewayResult = [];
      for (String sidewayData in sidewaysString) {
        InsightSidewayModel sideway = InsightSidewayModel.fromJson(jsonDecode(sidewayData));
        sidewayResult.add(sideway);
      }

      return sidewayResult;
    }

    // default it as empty array
    return [];
  }

  static Future<void> clearSideway() async {
    // check if the key box is null or not?
    if(LocalBox.keyBox == null) {
      // null no need to clear
      return;
    }

    // clear all the key for the sideway data
    LocalBox.delete(_sidewayOneDayRateKey, true);
    LocalBox.delete(_sidewayAvgOneDayKey, true);
    LocalBox.delete(_sidewayAvgOneWeekKey, true);
    LocalBox.delete(_sidewayResultKey, true);
  }

  static Future<void> setBrokerMarketToday(MarketTodayModel marketToday) async {
    // stored the user info to box
    if(LocalBox.keyBox == null) {
      LocalBox.init();
    }

    // convert the json to string so we can stored it on the local storage
    String marketTodayString = jsonEncode(marketToday.toJson());
    LocalBox.putString(_brokerMarketToday, marketTodayString);
  }

  static MarketTodayModel getBrokerMarketToday() {
    // check if the key box is null or not?
    if(LocalBox.keyBox == null) {
      LocalBox.init();
    }

    // get the data from local box
    String marketTodayString = (LocalBox.getString(_brokerMarketToday) ?? '');

    // check if the list is empty or not?
    if (marketTodayString.isNotEmpty) {
      // string is not empty parse it
      MarketTodayModel marketToday = MarketTodayModel.fromJson(jsonDecode(marketTodayString));
      // return the top worse
      return marketToday;
    }
    else {
      // no data
      return MarketTodayModel(
        buy: MarketTodayData(
          brokerSummaryType: "buy",
          brokerSummaryTotalLot: -1,
          brokerSummaryTotalValue: -1,
        ),
        sell: MarketTodayData(
          brokerSummaryType: "sell",
          brokerSummaryTotalLot: -1,
          brokerSummaryTotalValue: -1,
        ),
      );
    }
  }

  static Future<void> setMarketCap(List<MarketCapModel> marketCapList) async {
    // stored the user info to box
    if(LocalBox.keyBox == null) {
      LocalBox.init();
    }

    // convert the json to string so we can stored it on the local storage
    List<String> marketCapListResp = [];
    for (MarketCapModel sector in marketCapList) {
      marketCapListResp.add(jsonEncode(sector.toJson()));
    }
    LocalBox.putStringList(_marketCapKey, marketCapListResp);
  }

  static List<MarketCapModel> getMarketCap() {
    // check if the key box is null or not?
    if(LocalBox.keyBox == null) {
      LocalBox.init();
    }

    // get the data from local box
    List<String> marketCapList = (LocalBox.getStringList(_marketCapKey) ?? []);

    // check if the list is empty or not?
    if (marketCapList.isNotEmpty) {
      // list is not empty, parse the string to FavouriteModel
      List<MarketCapModel> ret = [];
      for (String marketCapString in marketCapList) {
        MarketCapModel marketCap = MarketCapModel.fromJson(jsonDecode(marketCapString));
        ret.add(marketCap);
      }

      // return the favourites list
      return ret;
    }
    else {
      // no data
      return [];
    }
  }

  static Future<void> setIndexBeater(List<IndexBeaterModel> indexBeaterList) async {
    // stored the user info to box
    if(LocalBox.keyBox == null) {
      LocalBox.init();
    }

    // convert the json to string so we can stored it on the local storage
    List<String> indexBeaterListResp = [];
    for (IndexBeaterModel indexBeater in indexBeaterList) {
      indexBeaterListResp.add(jsonEncode(indexBeater.toJson()));
    }
    LocalBox.putStringList(_indexBeaterKey, indexBeaterListResp);
  }

  static List<IndexBeaterModel> getIndexBeater() {
    // check if the key box is null or not?
    if(LocalBox.keyBox == null) {
      LocalBox.init();
    }

    // get the data from local box
    List<String> indexBeaterList = (LocalBox.getStringList(_indexBeaterKey) ?? []);

    // check if the list is empty or not?
    if (indexBeaterList.isNotEmpty) {
      // list is not empty, parse the string to FavouriteModel
      List<IndexBeaterModel> ret = [];
      for (String indexBeaterString in indexBeaterList) {
        IndexBeaterModel indexBeater = IndexBeaterModel.fromJson(jsonDecode(indexBeaterString));
        ret.add(indexBeater);
      }

      // return the favourites list
      return ret;
    }
    else {
      // no data
      return [];
    }
  }

  static Future<void> clearIndexBeater() async {
    // check if the key box is null or not?
    if(LocalBox.keyBox == null) {
      // null no need to clear
      return;
    }

    // clear all the key for the index beaterdata
    LocalBox.delete(_indexBeaterKey, true);
  }

  static Future<void> setStockNewListed(List<StockNewListedModel> stockNewList) async {
    // stored the user info to box
    if(LocalBox.keyBox == null) {
      LocalBox.init();
    }

    // convert the json to string so we can stored it on the local storage
    List<String> stockNewListResp = [];
    for (StockNewListedModel stock in stockNewList) {
      stockNewListResp.add(jsonEncode(stock.toJson()));
    }
    LocalBox.putStringList(_stockNewListedKey, stockNewListResp);
  }

  static List<StockNewListedModel> getStockNewListed() {
    // check if the key box is null or not?
    if(LocalBox.keyBox == null) {
      LocalBox.init();
    }

    // get the data from local box
    List<String> stockNewList = (LocalBox.getStringList(_stockNewListedKey) ?? []);

    // check if the list is empty or not?
    if (stockNewList.isNotEmpty) {
      // list is not empty, parse the string to FavouriteModel
      List<StockNewListedModel> ret = [];
      for (String stockString in stockNewList) {
        StockNewListedModel stock = StockNewListedModel.fromJson(jsonDecode(stockString));
        ret.add(stock);
      }

      // return the favourites list
      return ret;
    }
    else {
      // no data
      return [];
    }
  }

  static Future<void> setStockDividendList(List<StockDividendListModel> stockDividendList) async {
    // stored the user info to box
    if(LocalBox.keyBox == null) {
      LocalBox.init();
    }

    // convert the json to string so we can stored it on the local storage
    List<String> stockDividendListResp = [];
    for (StockDividendListModel stock in stockDividendList) {
      stockDividendListResp.add(jsonEncode(stock.toJson()));
    }
    LocalBox.putStringList(_stockDividendListKey, stockDividendListResp);
  }

  static List<StockDividendListModel> getStockDividendList() {
    // check if the key box is null or not?
    if(LocalBox.keyBox == null) {
      LocalBox.init();
    }

    // get the data from local box
    List<String> stockDividendList = (LocalBox.getStringList(_stockDividendListKey) ?? []);

    // check if the list is empty or not?
    if (stockDividendList.isNotEmpty) {
      // list is not empty, parse the string to FavouriteModel
      List<StockDividendListModel> ret = [];
      for (String stockString in stockDividendList) {
        StockDividendListModel stock = StockDividendListModel.fromJson(jsonDecode(stockString));
        ret.add(stock);
      }

      // return the favourites list
      return ret;
    }
    else {
      // no data
      return [];
    }
  }

  static Future<void> setStockSplitList(List<StockSplitListModel> stockDividendList) async {
    // stored the user info to box
    if(LocalBox.keyBox == null) {
      LocalBox.init();
    }

    // convert the json to string so we can stored it on the local storage
    List<String> stockSplitListResp = [];
    for (StockSplitListModel stock in stockDividendList) {
      stockSplitListResp.add(jsonEncode(stock.toJson()));
    }
    LocalBox.putStringList(_stockSplitListKey, stockSplitListResp);
  }

  static List<StockSplitListModel> getStockSplitList() {
    // check if the key box is null or not?
    if(LocalBox.keyBox == null) {
      LocalBox.init();
    }

    // get the data from local box
    List<String> stockSplitList = (LocalBox.getStringList(_stockSplitListKey) ?? []);

    // check if the list is empty or not?
    if (stockSplitList.isNotEmpty) {
      // list is not empty, parse the string to FavouriteModel
      List<StockSplitListModel> ret = [];
      for (String stockString in stockSplitList) {
        StockSplitListModel stock = StockSplitListModel.fromJson(jsonDecode(stockString));
        ret.add(stock);
      }

      // return the favourites list
      return ret;
    }
    else {
      // no data
      return [];
    }
  }

  static Future<void> setStockCollect(List<InsightStockCollectModel> stockCollectList, DateTime fromDate, DateTime toDate, int rate) async {
    // stored the user info to box
    if(LocalBox.keyBox == null) {
      LocalBox.init();
    }

    // store the from and to date
    LocalBox.putString(_stockCollectFromDateKey, fromDate.toString());
    LocalBox.putString(_stockCollectToDateKey, toDate.toString());

    // store the rate
    LocalBox.putString(_stockCollectAccumRateKey, rate.toString());

    // convert the json to string so we can stored it on the local storage
    List<String> stockCollectResp = [];
    for (InsightStockCollectModel stock in stockCollectList) {
      stockCollectResp.add(jsonEncode(stock.toJson()));
    }
    LocalBox.putStringList(_stockCollectKey, stockCollectResp);
  }

  static List<InsightStockCollectModel> getStockCollect() {
    // check if the key box is null or not?
    if(LocalBox.keyBox == null) {
      LocalBox.init();
    }

    // get the data from local box
    List<String> stockCollectList = (LocalBox.getStringList(_stockCollectKey) ?? []);

    // check if the list is empty or not?
    if (stockCollectList.isNotEmpty) {
      // list is not empty, parse the string to FavouriteModel
      List<InsightStockCollectModel> ret = [];
      for (String stockString in stockCollectList) {
        InsightStockCollectModel stock = InsightStockCollectModel.fromJson(jsonDecode(stockString));
        ret.add(stock);
      }

      // return the favourites list
      return ret;
    }
    else {
      // no data
      return [];
    }
  }

  static DateTime? getStockCollectDate(String type) {
    // check if the key box is null or not?
    if(LocalBox.keyBox == null) {
      LocalBox.init();
    }

    // get the data from local box
    String dateString = '';
    switch(type.toLowerCase()) {
      case 'to':
        dateString = (LocalBox.getString(_stockCollectToDateKey) ?? '');
        break;
      case 'from':
      default:
        dateString = (LocalBox.getString(_stockCollectFromDateKey) ?? '');
        break;
    }
    
    if (dateString.isNotEmpty) {
      return DateTime.parse(dateString);
    }

    return null;
  }

  static int getStockCollectAccumulationRate() {
    // check if the key box is null or not?
    if(LocalBox.keyBox == null) {
      LocalBox.init();
    }

    // get the data from local box
    String rateString = (LocalBox.getString(_stockCollectAccumRateKey) ?? '');
    if (rateString.isNotEmpty) {
      return int.parse(rateString);
    }

    // default it as 75%
    return 75;
  }

  static Future<void> clearStockCollect() async {
    // check if the key box is null or not?
    if(LocalBox.keyBox == null) {
      // null no need to clear
      return;
    }

    // clear all the data for stock collect
    LocalBox.delete(_stockCollectKey, true);
    LocalBox.delete(_stockCollectFromDateKey, true);
    LocalBox.delete(_stockCollectToDateKey, true);
    LocalBox.delete(_stockCollectAccumRateKey, true);
  }

  static Future<void> setBrokerCollect(InsightBrokerCollectModel brokerCollectList, String brokerId, DateTime fromDate, DateTime toDate, int rate) async {
    // stored the user info to box
    if(LocalBox.keyBox == null) {
      LocalBox.init();
    }

    // store the broker id
    LocalBox.putString(_brokerCollectIDKey, brokerId);

    // store the from and to date
    LocalBox.putString(_brokerCollectFromDateKey, fromDate.toString());
    LocalBox.putString(_brokerCollectToDateKey, toDate.toString());

    // store the rate
    LocalBox.putString(_brokerCollectAccumRateKey, rate.toString());

    // convert the json to string so we can stored it on the local storage
    LocalBox.putString(_brokerCollectKey, jsonEncode(brokerCollectList.toJson()));
  }

  static InsightBrokerCollectModel? getBrokerCollect() {
    // check if the key box is null or not?
    if(LocalBox.keyBox == null) {
      LocalBox.init();
    }

    // get the data from local box
    String brokerCollectString = (LocalBox.getString(_brokerCollectKey) ?? '');

    // check if the list is empty or not?
    if (brokerCollectString.isNotEmpty) {
      // list is not empty, parse the string to FavouriteModel
      InsightBrokerCollectModel brokerCollectData = InsightBrokerCollectModel.fromJson(jsonDecode(brokerCollectString));
      return brokerCollectData;
    }
    else {
      // no data
      return null;
    }
  }

  static String getBrokerCollectID() {
    // check if the key box is null or not?
    if(LocalBox.keyBox == null) {
      LocalBox.init();
    }

    // get the data from local box
    String brokerId = (LocalBox.getString(_brokerCollectIDKey) ?? '');
    if (brokerId.isNotEmpty) {
      return brokerId;
    }

    return '';
  }

  static DateTime? getBrokerCollectDate(String type) {
    // check if the key box is null or not?
    if(LocalBox.keyBox == null) {
      LocalBox.init();
    }

    // get the data from local box
    String dateString = '';
    switch(type.toLowerCase()) {
      case 'to':
        dateString = (LocalBox.getString(_brokerCollectToDateKey) ?? '');
        break;
      case 'from':
      default:
        dateString = (LocalBox.getString(_brokerCollectFromDateKey) ?? '');
        break;
    }
    
    if (dateString.isNotEmpty) {
      return DateTime.parse(dateString);
    }

    return null;
  }

  static int getBrokerCollectAccumulationRate() {
    // check if the key box is null or not?
    if(LocalBox.keyBox == null) {
      LocalBox.init();
    }

    // get the data from local box
    String rateString = (LocalBox.getString(_brokerCollectAccumRateKey) ?? '');
    if (rateString.isNotEmpty) {
      return int.parse(rateString);
    }

    // default it as 75%
    return 75;
  }

  static Future<void> clearBrokerCollect() async {
    // check if the key box is null or not?
    if(LocalBox.keyBox == null) {
      // null no need to clear
      return;
    }

    // clear all the data for stock collect
    LocalBox.delete(_brokerCollectKey, true);
    LocalBox.delete(_brokerCollectIDKey, true);
    LocalBox.delete(_brokerCollectFromDateKey, true);
    LocalBox.delete(_brokerCollectToDateKey, true);
    LocalBox.delete(_brokerCollectAccumRateKey, true);
  }
}