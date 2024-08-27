import 'dart:convert';
import 'package:my_wealth/_index.g.dart';

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
    LocalBox.putStringList(
      key: _sectorSummaryKey,
      value: sectorSummaryListResp
    );
  }

  static List<SectorSummaryModel> getSectorSummaryList() {
    // check if the key box is null or not?
    if(LocalBox.keyBox == null) {
      LocalBox.init();
    }

    // get the data from local box
    List<String> sectorSummaryList = (
      LocalBox.getStringList(key: _sectorSummaryKey) ?? []
    );

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
    LocalBox.putString(
      key: "$_topWorseCompanyListKey$type",
      value: topWorseString,
    );
  }

  static TopWorseCompanyListModel getTopWorseCompanyList(String type) {
    // check if the key box is null or not?
    if(LocalBox.keyBox == null) {
      LocalBox.init();
    }

    // get the data from local box
    String topWorseString = (
      LocalBox.getString(key: _topWorseCompanyListKey + type) ?? ''
    );

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
    LocalBox.putString(
      key: _brokerTopTransactionKey,
      value: brokerTopListString,
    );
  }

  static BrokerTopTransactionModel getBrokerTopTxn() {
    // check if the key box is null or not?
    if(LocalBox.keyBox == null) {
      LocalBox.init();
    }

    // get the data from local box
    String brokerTopListString = (
      LocalBox.getString(key: _brokerTopTransactionKey) ?? ''
    );

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
    LocalBox.putString(
      key: _topReksadanaListKey + type,
      value: topReksadanaString
    );
  }

  static TopWorseCompanyListModel getTopReksadanaList(String type) {
    // check if the key box is null or not?
    if(LocalBox.keyBox == null) {
      LocalBox.init();
    }

    // get the data from local box
    String topReksadanaString = (
      LocalBox.getString(key: _topReksadanaListKey + type) ?? ''
    );

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
    LocalBox.putString(
      key: "$_worseReksadanaListKey$type",
      value: worseReksadanaString
    );
  }

  static TopWorseCompanyListModel getWorseReksadanaList(String type) {
    // check if the key box is null or not?
    if(LocalBox.keyBox == null) {
      LocalBox.init();
    }

    // get the data from local box
    String worseReksadanaString = (
      LocalBox.getString(key: "$_worseReksadanaListKey$type") ?? ''
    );

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
    LocalBox.putString(
      key: _bandarInterestingKey,
      value: bandarInterestString
    );
  }

  static InsightBandarInterestModel getBandarInterestingList() {
    // check if the key box is null or not?
    if(LocalBox.keyBox == null) {
      LocalBox.init();
    }

    // get the data from local box
    String bandarInterestString = (
      LocalBox.getString(key: _bandarInterestingKey) ?? ''
    );

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
    LocalBox.putString(
      key: _topAccumFromDateKey,
      value: fromDate.toString()
    );
    LocalBox.putString(
      key: _topAccumToDateKey,
      value: toDate.toString()
    );

    // store the rate
    LocalBox.putString(
      key: _topAccumRateKey,
      value: rate.toString()
    );

    // store the accum list
    List<String> strAccum = [];
    for (InsightAccumulationModel data in accum) {
      strAccum.add(jsonEncode(data.toJson()));
    }
    LocalBox.putStringList(
      key: _topAccumResultKey,
      value: strAccum
    );
  }

  static DateTime getTopAccumulationFromDate() {
    // check if the key box is null or not?
    if(LocalBox.keyBox == null) {
      LocalBox.init();
    }

    // get the data from local box
    String fromDateString = (
      LocalBox.getString(key: _topAccumFromDateKey) ?? ''
    );
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
    String toDateString = (
      LocalBox.getString(key: _topAccumToDateKey) ?? ''
    );
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
    String rateString = (
      LocalBox.getString(key: _topAccumRateKey) ?? ''
    );
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
    List<String> accumString = (
      LocalBox.getStringList(key: _topAccumResultKey) ?? []
    );
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
    LocalBox.delete(key: _topAccumFromDateKey, exact: true);
    LocalBox.delete(key: _topAccumToDateKey, exact: true);
    LocalBox.delete(key: _topAccumRateKey, exact: true);
    LocalBox.delete(key: _topAccumResultKey, exact: true);
  }

  static Future<void> setEps(int minRate, int diffRate, List<InsightEpsModel> epsList) async {
    // stored the user info to box
    if(LocalBox.keyBox == null) {
      LocalBox.init();
    }

    // store the from and to date
    LocalBox.putString(key: _epsMinRateKey, value: minRate.toString());
    LocalBox.putString(key: _epsMinDiffRateKey, value: diffRate.toString());

    // store the accum list
    List<String> strEps = [];
    for (InsightEpsModel data in epsList) {
      strEps.add(jsonEncode(data.toJson()));
    }
    LocalBox.putStringList(key: _epsResultKey, value: strEps);
  }

  static int getEpsMinRate() {
    // check if the key box is null or not?
    if(LocalBox.keyBox == null) {
      LocalBox.init();
    }

    // get the data from local box
    String rateString = (LocalBox.getString(key: _epsMinRateKey) ?? '');
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
    String rateString = (LocalBox.getString(key: _epsMinDiffRateKey) ?? '');
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
    List<String> epsString = (LocalBox.getStringList(key: _epsResultKey) ?? []);
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
    LocalBox.delete(key: _epsMinRateKey, exact: true);
    LocalBox.delete(key: _epsMinDiffRateKey, exact: true);
    LocalBox.delete(key: _epsResultKey, exact: true);
  }

  static Future<void> setSideway(int oneDay, int avgOneDay, int avgOneWeek, List<InsightSidewayModel> sidewayList) async {
    // stored the user info to box
    if(LocalBox.keyBox == null) {
      LocalBox.init();
    }

    // store the from and to date
    LocalBox.putString(key: _sidewayOneDayRateKey, value: oneDay.toString());
    LocalBox.putString(key: _sidewayAvgOneDayKey, value: avgOneDay.toString());
    LocalBox.putString(key: _sidewayAvgOneWeekKey, value: avgOneWeek.toString());

    // store the accum list
    List<String> strSideway = [];
    for (InsightSidewayModel data in sidewayList) {
      strSideway.add(jsonEncode(data.toJson()));
    }
    LocalBox.putStringList(key: _sidewayResultKey, value: strSideway);
  }

  static int getSidewayOneDayRate() {
    // check if the key box is null or not?
    if(LocalBox.keyBox == null) {
      LocalBox.init();
    }

    // get the data from local box
    String rateString = (LocalBox.getString(key: _sidewayOneDayRateKey) ?? '');
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
    String rateString = (LocalBox.getString(key: _sidewayAvgOneDayKey) ?? '');
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
    String rateString = (LocalBox.getString(key: _sidewayAvgOneWeekKey) ?? '');
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
    List<String> sidewaysString = (
      LocalBox.getStringList(key: _sidewayResultKey) ?? []
    );
    if (sidewaysString.isNotEmpty) {
      // loop thru the stringList
      List<InsightSidewayModel> sidewayResult = [];
      for (String sidewayData in sidewaysString) {
        InsightSidewayModel sideway = InsightSidewayModel.fromJson(
          jsonDecode(sidewayData)
        );
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
    LocalBox.delete(key: _sidewayOneDayRateKey, exact: true);
    LocalBox.delete(key: _sidewayAvgOneDayKey, exact: true);
    LocalBox.delete(key: _sidewayAvgOneWeekKey, exact: true);
    LocalBox.delete(key: _sidewayResultKey, exact: true);
  }

  static Future<void> setBrokerMarketToday(MarketTodayModel marketToday) async {
    // stored the user info to box
    if(LocalBox.keyBox == null) {
      LocalBox.init();
    }

    // convert the json to string so we can stored it on the local storage
    String marketTodayString = jsonEncode(marketToday.toJson());
    LocalBox.putString(key: _brokerMarketToday, value: marketTodayString);
  }

  static MarketTodayModel getBrokerMarketToday() {
    // check if the key box is null or not?
    if(LocalBox.keyBox == null) {
      LocalBox.init();
    }

    // get the data from local box
    String marketTodayString = (
      LocalBox.getString(key: _brokerMarketToday) ?? ''
    );

    // check if the list is empty or not?
    if (marketTodayString.isNotEmpty) {
      // string is not empty parse it
      MarketTodayModel marketToday = MarketTodayModel.fromJson(
        jsonDecode(marketTodayString)
      );
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
    LocalBox.putStringList(key: _marketCapKey, value: marketCapListResp);
  }

  static List<MarketCapModel> getMarketCap() {
    // check if the key box is null or not?
    if(LocalBox.keyBox == null) {
      LocalBox.init();
    }

    // get the data from local box
    List<String> marketCapList = (
      LocalBox.getStringList(key: _marketCapKey) ?? []
    );

    // check if the list is empty or not?
    if (marketCapList.isNotEmpty) {
      // list is not empty, parse the string to FavouriteModel
      List<MarketCapModel> ret = [];
      for (String marketCapString in marketCapList) {
        MarketCapModel marketCap = MarketCapModel.fromJson(
          jsonDecode(marketCapString)
        );
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
    LocalBox.putStringList(key: _indexBeaterKey, value: indexBeaterListResp);
  }

  static List<IndexBeaterModel> getIndexBeater() {
    // check if the key box is null or not?
    if(LocalBox.keyBox == null) {
      LocalBox.init();
    }

    // get the data from local box
    List<String> indexBeaterList = (
      LocalBox.getStringList(key: _indexBeaterKey) ?? []
    );

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
    LocalBox.delete(key: _indexBeaterKey, exact: true);
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
    LocalBox.putStringList(key: _stockNewListedKey, value: stockNewListResp);
  }

  static List<StockNewListedModel> getStockNewListed() {
    // check if the key box is null or not?
    if(LocalBox.keyBox == null) {
      LocalBox.init();
    }

    // get the data from local box
    List<String> stockNewList = (
      LocalBox.getStringList(key: _stockNewListedKey) ?? []
    );

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
    LocalBox.putStringList(
      key: _stockDividendListKey,
      value: stockDividendListResp
    );
  }

  static List<StockDividendListModel> getStockDividendList() {
    // check if the key box is null or not?
    if(LocalBox.keyBox == null) {
      LocalBox.init();
    }

    // get the data from local box
    List<String> stockDividendList = (
      LocalBox.getStringList(key: _stockDividendListKey) ?? []
    );

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
    LocalBox.putStringList(key: _stockSplitListKey, value: stockSplitListResp);
  }

  static List<StockSplitListModel> getStockSplitList() {
    // check if the key box is null or not?
    if(LocalBox.keyBox == null) {
      LocalBox.init();
    }

    // get the data from local box
    List<String> stockSplitList = (
      LocalBox.getStringList(key: _stockSplitListKey) ?? []
    );

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
    LocalBox.putString(
      key: _stockCollectFromDateKey,
      value: fromDate.toString()
    );
    LocalBox.putString(
      key: _stockCollectToDateKey,
      value: toDate.toString()
    );

    // store the rate
    LocalBox.putString(key: _stockCollectAccumRateKey, value: rate.toString());

    // convert the json to string so we can stored it on the local storage
    List<String> stockCollectResp = [];
    for (InsightStockCollectModel stock in stockCollectList) {
      stockCollectResp.add(jsonEncode(stock.toJson()));
    }
    LocalBox.putStringList(
      key: _stockCollectKey,
      value: stockCollectResp,
    );
  }

  static List<InsightStockCollectModel> getStockCollect() {
    // check if the key box is null or not?
    if(LocalBox.keyBox == null) {
      LocalBox.init();
    }

    // get the data from local box
    List<String> stockCollectList = (
      LocalBox.getStringList(key: _stockCollectKey) ?? []
    );

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
        dateString = (LocalBox.getString(key: _stockCollectToDateKey) ?? '');
        break;
      case 'from':
      default:
        dateString = (LocalBox.getString(key: _stockCollectFromDateKey) ?? '');
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
    String rateString = (
      LocalBox.getString(key: _stockCollectAccumRateKey) ?? ''
    );
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
    LocalBox.delete(key: _stockCollectKey, exact: true);
    LocalBox.delete(key: _stockCollectFromDateKey, exact: true);
    LocalBox.delete(key: _stockCollectToDateKey, exact: true);
    LocalBox.delete(key: _stockCollectAccumRateKey, exact: true);
  }

  static Future<void> setBrokerCollect(InsightBrokerCollectModel brokerCollectList, String brokerId, DateTime fromDate, DateTime toDate, int rate) async {
    // stored the user info to box
    if(LocalBox.keyBox == null) {
      LocalBox.init();
    }

    // store the broker id
    LocalBox.putString(
      key: _brokerCollectIDKey,
      value: brokerId
    );

    // store the from and to date
    LocalBox.putString(
      key: _brokerCollectFromDateKey,
      value: fromDate.toString()
    );
    LocalBox.putString(
      key: _brokerCollectToDateKey,
      value: toDate.toString()
    );

    // store the rate
    LocalBox.putString(
      key: _brokerCollectAccumRateKey,
      value: rate.toString()
    );

    // convert the json to string so we can stored it on the local storage
    LocalBox.putString(
      key: _brokerCollectKey,
      value: jsonEncode(brokerCollectList.toJson())
    );
  }

  static InsightBrokerCollectModel? getBrokerCollect() {
    // check if the key box is null or not?
    if(LocalBox.keyBox == null) {
      LocalBox.init();
    }

    // get the data from local box
    String brokerCollectString = (
      LocalBox.getString(key: _brokerCollectKey) ?? ''
    );

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
    String brokerId = (LocalBox.getString(key: _brokerCollectIDKey) ?? '');
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
        dateString = (LocalBox.getString(key: _brokerCollectToDateKey) ?? '');
        break;
      case 'from':
      default:
        dateString = (LocalBox.getString(key: _brokerCollectFromDateKey) ?? '');
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
    String rateString = (
      LocalBox.getString(key: _brokerCollectAccumRateKey) ?? ''
    );
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
    LocalBox.delete(key: _brokerCollectKey, exact: true);
    LocalBox.delete(key: _brokerCollectIDKey, exact: true);
    LocalBox.delete(key: _brokerCollectFromDateKey, exact: true);
    LocalBox.delete(key: _brokerCollectToDateKey, exact: true);
    LocalBox.delete(key: _brokerCollectAccumRateKey, exact: true);
  }
}