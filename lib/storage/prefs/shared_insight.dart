import 'dart:convert';
import 'package:my_wealth/_index.g.dart';

enum DateType {
  from, to
}
class InsightSharedPreferences {
  static const String _sectorSummaryKey = "sector_summary";
  static const String _topWorseCompanyListKey = "insight_company_list_";
  static const String _topReksadanaListKey = "insight_reksadana_list_";
  static const String _worseReksadanaListKey = "insight_reksadana_worse_list_";
  static const String _brokerTopTransactionKey = "insight_broker_top_txn";
  static const String _brokerMarketToday = "insight_broker_market_today";
  
  static const String _bandarInterestingKey = "insight_bandar_interesting";
  
  static const  String _topAccumFromDateKey = "insight_top_accum_from_date";
  static const  String _topAccumToDateKey = "insight_top_accum_to_date";
  static const  String _topAccumRateKey = "insight_top_accum_rate";
  static const  String _topAccumResultKey = "insight_top_accum_result";
  
  static const  String _epsMinRateKey = "insight_eps_min_rate";
  static const  String _epsMinDiffRateKey = "insight_eps_min_diff_rate";
  static const  String _epsResultKey = "insight_eps_result";
  
  static const  String _sidewayOneDayRateKey = "insight_sideway_one_day_rate";
  static const  String _sidewayAvgOneDayKey = "insight_sideway_avg_one_day";
  static const  String _sidewayAvgOneWeekKey = "insight_sideway_avg_one_week";
  static const  String _sidewayResultKey = "insight_sideway_result";
  
  static const  String _marketCapKey = "insight_market_cap";
  static const  String _indexBeaterKey = "insight_index_beater";
  static const  String _stockNewListedKey = "insight_stock_new_listed";
  static const  String _stockDividendListKey = "insight_stock_dividend_list";
  static const  String _stockSplitListKey = "insight_stock_split_list";
  
  static const  String _stockCollectKey = "insight_stock_collect";
  static const  String _stockCollectFromDateKey = "insight_stock_collect_from_date";
  static const  String _stockCollectToDateKey = "insight_stock_collect_to_date";
  static const  String _stockCollectAccumRateKey = "insight_stock_collect_accum_rate";
  
  static const  String _brokerCollectKey = "insight_broker_collect";
  static const  String _brokerCollectIDKey = "insight_broker_collect_id";
  static const  String _brokerCollectFromDateKey = "insight_broker_collect_from_date";
  static const  String _brokerCollectToDateKey = "insight_broker_collect_to_date";
  static const  String _brokerCollectAccumRateKey = "insight_broker_collect_accum_rate";

  static const  String _brokerSpecificBrokerKey = "insight_broker_specific_broker_id";
  static const  String _brokerSpecificCompanyKey = "insight_broker_specific_company";
  static const  String _brokerSpecificFromDateKey = "insight_broker_specific_from_date";
  static const  String _brokerSpecificToDateKey = "insight_broker_specific_to_date";
  static const  String _brokerSpecificResultKey = "insight_broker_specific_result";

  static const String _brokerCompanyStockCodeKey = "insight_broker_company_stock_code";
  static const String _brokerCompanyFromDateKey = "insight_broker_company_from_date";
  static const String _brokerCompanyToDateKey = "insight_broker_company_to_date";
  static const String _brokerCompanyDetailKey = "insight_broker_company_detail";
  static const String _brokerCompanyListKey = "insight_broker_company_list";
  static const String _brokerCompanySummaryDataGrossKey = "insight_broker_company_summary_gross";
  static const String _brokerCompanySummaryDataNetKey = "insight_broker_company_summary_net";
  static const String _brokerCompanyTopBrokerKey = "insight_broker_company_top_broker";

  static Future<void> setSectorSummaryList({
    required List<SectorSummaryModel> sectorSummaryList
  }) async {
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

  static Future<void> setTopWorseCompanyList({
    required String type,
    required TopWorseCompanyListModel topWorseList
  }) async {
    // convert the json to string so we can stored it on the local storage
    String topWorseString = jsonEncode(topWorseList.toJson());
    LocalBox.putString(
      key: "$_topWorseCompanyListKey$type",
      value: topWorseString,
    );
  }

  static TopWorseCompanyListModel getTopWorseCompanyList({
    required String type
  }) {
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

  static Future<void> setBrokerTopTxn({
    required BrokerTopTransactionModel brokerTopList
  }) async {
    // convert the json to string so we can stored it on the local storage
    String brokerTopListString = jsonEncode(brokerTopList.toJson());
    LocalBox.putString(
      key: _brokerTopTransactionKey,
      value: brokerTopListString,
    );
  }

  static BrokerTopTransactionModel getBrokerTopTxn() {
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

  static Future<void> setTopReksadanaList({
    required String type,
    required TopWorseCompanyListModel topReksadanaList
  }) async {
    // convert the json to string so we can stored it on the local storage
    String topReksadanaString = jsonEncode(topReksadanaList.toJson());
    LocalBox.putString(
      key: _topReksadanaListKey + type,
      value: topReksadanaString
    );
  }

  static TopWorseCompanyListModel getTopReksadanaList({required String type}) {
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

  static Future<void> setWorseReksadanaList({
    required String type,
    required TopWorseCompanyListModel worseReksadanaList
  }) async {
    // convert the json to string so we can stored it on the local storage
    String worseReksadanaString = jsonEncode(worseReksadanaList.toJson());
    LocalBox.putString(
      key: "$_worseReksadanaListKey$type",
      value: worseReksadanaString
    );
  }

  static TopWorseCompanyListModel getWorseReksadanaList({
    required String type
  }) {
    // get the data from local box
    String worseReksadanaString = (
      LocalBox.getString(key: "$_worseReksadanaListKey$type") ?? ''
    );

    // check if the list is empty or not?
    if (worseReksadanaString.isNotEmpty) {
      // string is not empty parse it
      TopWorseCompanyListModel worseReksadana = TopWorseCompanyListModel.fromJson(
        jsonDecode(worseReksadanaString)
      );
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

  static Future<void> setBandarInterestingList({
    required InsightBandarInterestModel bandarInterest
  }) async {
    // convert the json to string so we can stored it on the local storage
    String bandarInterestString = jsonEncode(bandarInterest.toJson());
    LocalBox.putString(
      key: _bandarInterestingKey,
      value: bandarInterestString
    );
  }

  static InsightBandarInterestModel getBandarInterestingList() {
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

  static Future<void> setTopAccumulation({
    required DateTime fromDate,
    required DateTime toDate,
    required int rate,
    required List<InsightAccumulationModel> accum
  }) async {
    // store the from and to date
    LocalBox.putString(
      key: _topAccumFromDateKey,
      value: fromDate.toString(),
      cache: true,
    );
    LocalBox.putString(
      key: _topAccumToDateKey,
      value: toDate.toString(),
      cache: true,
    );

    // store the rate
    LocalBox.putString(
      key: _topAccumRateKey,
      value: rate.toString(),
      cache: true,
    );

    // store the accum list
    List<String> strAccum = [];
    for (InsightAccumulationModel data in accum) {
      strAccum.add(jsonEncode(data.toJson()));
    }
    LocalBox.putStringList(
      key: _topAccumResultKey,
      value: strAccum,
      cache: true,
    );
  }

  static DateTime getTopAccumulationFromDate() {
    // get the data from local box
    String fromDateString = (
      LocalBox.getString(key: _topAccumFromDateKey, cache: true) ?? ''
    );
    if (fromDateString.isNotEmpty) {
      return DateTime.parse(fromDateString);
    }

    return DateTime.now().add(const Duration(days: -7)); // default 7 days before
  }

  static DateTime getTopAccumulationToDate() {
    // get the data from local box
    String toDateString = (
      LocalBox.getString(key: _topAccumToDateKey, cache: true) ?? ''
    );
    if (toDateString.isNotEmpty) {
      return DateTime.parse(toDateString);
    }

    return DateTime.now(); // default to today time
  }

  static int getTopAccumulationRate() {
    // get the data from local box
    String rateString = (
      LocalBox.getString(key: _topAccumRateKey, cache:  true) ?? ''
    );
    if (rateString.isNotEmpty) {
      return int.parse(rateString);
    }

    // default it as 8%
    return 8;
  }

  static List<InsightAccumulationModel> getTopAccumulationResult() {
    // get the data from local box
    List<String> accumString = (
      LocalBox.getStringList(key: _topAccumResultKey, cache: true) ?? []
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
    // clear all the key for the topAccumulation
    LocalBox.delete(key: _topAccumFromDateKey, exact: true);
    LocalBox.delete(key: _topAccumToDateKey, exact: true);
    LocalBox.delete(key: _topAccumRateKey, exact: true);
    LocalBox.delete(key: _topAccumResultKey, exact: true);
  }

  static Future<void> setEps({
    required int minRate,
    required int diffRate,
    required List<InsightEpsModel> epsList
  }) async {
    // store the from and to date
    LocalBox.putString(
      key: _epsMinRateKey,
      value: "$minRate",
      cache: true,
    );
    LocalBox.putString(
      key: _epsMinDiffRateKey,
      value: "$diffRate",
      cache: true,
    );

    // store the accum list
    List<String> strEps = [];
    for (InsightEpsModel data in epsList) {
      strEps.add(jsonEncode(data.toJson()));
    }
    LocalBox.putStringList(
      key: _epsResultKey,
      value: strEps,
      cache: true,
    );
  }

  static int getEpsMinRate() {
    // get the data from local box
    String rateString = (
      LocalBox.getString(
        key: _epsMinRateKey,
        cache: true,
      ) ?? ''
    );
    if (rateString.isNotEmpty) {
      return int.parse(rateString);
    }

    // default it as 0%
    return 0;
  }

  static int getEpsMinDiffRate() {
    // get the data from local box
    String rateString = (
      LocalBox.getString(
        key: _epsMinDiffRateKey,
        cache: true,
      ) ?? ''
    );
    if (rateString.isNotEmpty) {
      return int.parse(rateString);
    }

    // default it as 5%
    return 5;
  }

  static List<InsightEpsModel> getEpsResult() {
    // get the data from local box
    List<String> epsString = (
      LocalBox.getStringList(
        key: _epsResultKey,
        cache: true,
      ) ?? []
    );

    // check if the result is empty or not?
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
    // clear all the key for the eps data
    LocalBox.delete(key: _epsMinRateKey, exact: true);
    LocalBox.delete(key: _epsMinDiffRateKey, exact: true);
    LocalBox.delete(key: _epsResultKey, exact: true);
  }

  static Future<void> setSideway({
    required int oneDay,
    required int avgOneDay,
    required int avgOneWeek,
    required List<InsightSidewayModel> sidewayList
  }) async {
    // store the from and to date
    LocalBox.putString(
      key: _sidewayOneDayRateKey,
      value: oneDay.toString(),
      cache: true,
    );
    LocalBox.putString(
      key: _sidewayAvgOneDayKey,
      value: avgOneDay.toString(),
      cache: true,
    );
    LocalBox.putString(
      key: _sidewayAvgOneWeekKey,
      value: avgOneWeek.toString(),
      cache: true,
    );

    // store the accum list
    List<String> strSideway = [];
    for (InsightSidewayModel data in sidewayList) {
      strSideway.add(jsonEncode(data.toJson()));
    }
    LocalBox.putStringList(
      key: _sidewayResultKey,
      value: strSideway,
      cache: true,
    );
  }

  static int getSidewayOneDayRate() {
    // get the data from local box
    String rateString = (LocalBox.getString(key: _sidewayOneDayRateKey, cache: true) ?? '');
    if (rateString.isNotEmpty) {
      return int.parse(rateString);
    }

    // default it as 5%
    return 5;
  }

  static int getSidewayAvgOneDay() {
    // get the data from local box
    String rateString = (LocalBox.getString(key: _sidewayAvgOneDayKey, cache: true) ?? '');
    if (rateString.isNotEmpty) {
      return int.parse(rateString);
    }

    // default it as 1%
    return 1;
  }

  static int getSidewayAvgOneWeek() {
    // get the data from local box
    String rateString = (LocalBox.getString(key: _sidewayAvgOneWeekKey, cache: true) ?? '');
    if (rateString.isNotEmpty) {
      return int.parse(rateString);
    }

    // default it as 1%
    return 1;
  }

  static List<InsightSidewayModel> getSidewayResult() {
    // get the data from local box
    List<String> sidewaysString = (
      LocalBox.getStringList(key: _sidewayResultKey, cache: true) ?? []
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
    // clear all the key for the sideway data
    LocalBox.delete(key: _sidewayOneDayRateKey, exact: true);
    LocalBox.delete(key: _sidewayAvgOneDayKey, exact: true);
    LocalBox.delete(key: _sidewayAvgOneWeekKey, exact: true);
    LocalBox.delete(key: _sidewayResultKey, exact: true);
  }

  static Future<void> setBrokerMarketToday({
    required MarketTodayModel marketToday
  }) async {
    // convert the json to string so we can stored it on the local storage
    String marketTodayString = jsonEncode(marketToday.toJson());
    LocalBox.putString(key: _brokerMarketToday, value: marketTodayString);
  }

  static MarketTodayModel getBrokerMarketToday() {
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

  static Future<void> setMarketCap({
    required List<MarketCapModel> marketCapList
  }) async {
    // convert the json to string so we can stored it on the local storage
    List<String> marketCapListResp = [];
    for (MarketCapModel sector in marketCapList) {
      marketCapListResp.add(jsonEncode(sector.toJson()));
    }
    LocalBox.putStringList(key: _marketCapKey, value: marketCapListResp);
  }

  static List<MarketCapModel> getMarketCap() {
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

  static Future<void> setIndexBeater({
    required List<IndexBeaterModel> indexBeaterList
  }) async {
    // convert the json to string so we can stored it on the local storage
    List<String> indexBeaterListResp = [];
    for (IndexBeaterModel indexBeater in indexBeaterList) {
      indexBeaterListResp.add(jsonEncode(indexBeater.toJson()));
    }
    LocalBox.putStringList(key: _indexBeaterKey, value: indexBeaterListResp, cache: true);
  }

  static List<IndexBeaterModel> getIndexBeater() {
    // get the data from local box
    List<String> indexBeaterList = (
      LocalBox.getStringList(key: _indexBeaterKey, cache: true) ?? []
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
    // clear all the key for the index beaterdata
    LocalBox.delete(key: _indexBeaterKey, exact: true);
  }

  static Future<void> setStockNewListed({
    required List<StockNewListedModel> stockNewList
  }) async {
    // convert the json to string so we can stored it on the local storage
    List<String> stockNewListResp = [];
    for (StockNewListedModel stock in stockNewList) {
      stockNewListResp.add(jsonEncode(stock.toJson()));
    }
    LocalBox.putStringList(key: _stockNewListedKey, value: stockNewListResp);
  }

  static List<StockNewListedModel> getStockNewListed() {
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

  static Future<void> setStockDividendList({
    required List<StockDividendListModel> stockDividendList
  }) async {
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

  static Future<void> setStockSplitList({
    required List<StockSplitListModel> stockDividendList
  }) async {
    // convert the json to string so we can stored it on the local storage
    List<String> stockSplitListResp = [];
    for (StockSplitListModel stock in stockDividendList) {
      stockSplitListResp.add(jsonEncode(stock.toJson()));
    }
    LocalBox.putStringList(key: _stockSplitListKey, value: stockSplitListResp);
  }

  static List<StockSplitListModel> getStockSplitList() {
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

  static Future<void> setStockCollect({
    required List<InsightStockCollectModel> stockCollectList,
    required DateTime fromDate,
    required DateTime toDate,
    required int rate
  }) async {
    // store the from and to date
    LocalBox.putString(
      key: _stockCollectFromDateKey,
      value: fromDate.toString(),
      cache: true,
    );
    LocalBox.putString(
      key: _stockCollectToDateKey,
      value: toDate.toString(),
      cache: true,
    );

    // store the rate
    LocalBox.putString(
      key: _stockCollectAccumRateKey,
      value: rate.toString(),
      cache: true,
    );

    // convert the json to string so we can stored it on the local storage
    List<String> stockCollectResp = [];
    for (InsightStockCollectModel stock in stockCollectList) {
      stockCollectResp.add(jsonEncode(stock.toJson()));
    }
    LocalBox.putStringList(
      key: _stockCollectKey,
      value: stockCollectResp,
      cache: true,
    );
  }

  static List<InsightStockCollectModel> getStockCollect() {
    // get the data from local box
    List<String> stockCollectList = (
      LocalBox.getStringList(key: _stockCollectKey, cache: true) ?? []
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

  static DateTime? getStockCollectDate({required String type}) {
    // get the data from local box
    String dateString = '';
    switch(type.toLowerCase()) {
      case 'to':
        dateString = (LocalBox.getString(key: _stockCollectToDateKey, cache: true) ?? '');
        break;
      case 'from':
      default:
        dateString = (LocalBox.getString(key: _stockCollectFromDateKey, cache: true) ?? '');
        break;
    }
    
    if (dateString.isNotEmpty) {
      return DateTime.parse(dateString);
    }

    return null;
  }

  static int getStockCollectAccumulationRate() {
    // get the data from local box
    String rateString = (
      LocalBox.getString(key: _stockCollectAccumRateKey, cache: true) ?? ''
    );
    if (rateString.isNotEmpty) {
      return int.parse(rateString);
    }

    // default it as 75%
    return 75;
  }

  static Future<void> clearStockCollect() async {
    // clear all the data for stock collect
    LocalBox.delete(key: _stockCollectKey, exact: true);
    LocalBox.delete(key: _stockCollectFromDateKey, exact: true);
    LocalBox.delete(key: _stockCollectToDateKey, exact: true);
    LocalBox.delete(key: _stockCollectAccumRateKey, exact: true);
  }

  static Future<void> setBrokerCollect({
    required InsightBrokerCollectModel brokerCollectList,
    required String brokerId,
    required DateTime fromDate,
    required DateTime toDate,
    required int rate
  }) async {
    // store the broker id
    LocalBox.putString(
      key: _brokerCollectIDKey,
      value: brokerId,
      cache: true,
    );

    // store the from and to date
    LocalBox.putString(
      key: _brokerCollectFromDateKey,
      value: fromDate.toString(),
      cache: true,
    );
    LocalBox.putString(
      key: _brokerCollectToDateKey,
      value: toDate.toString(),
      cache: true,
    );

    // store the rate
    LocalBox.putString(
      key: _brokerCollectAccumRateKey,
      value: rate.toString(),
      cache: true,
    );

    // convert the json to string so we can stored it on the local storage
    LocalBox.putString(
      key: _brokerCollectKey,
      value: jsonEncode(brokerCollectList.toJson()),
      cache: true,
    );
  }

  static InsightBrokerCollectModel? getBrokerCollect() {
    // get the data from local box
    String brokerCollectString = (
      LocalBox.getString(key: _brokerCollectKey, cache: true,) ?? ''
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
    // get the data from local box
    String brokerId = (LocalBox.getString(key: _brokerCollectIDKey, cache: true,) ?? '');
    if (brokerId.isNotEmpty) {
      return brokerId;
    }

    return '';
  }

  static DateTime? getBrokerCollectDate({required String type}) {
    // get the data from local box
    String dateString = '';
    switch(type.toLowerCase()) {
      case 'to':
        dateString = (LocalBox.getString(key: _brokerCollectToDateKey, cache: true,) ?? '');
        break;
      case 'from':
      default:
        dateString = (LocalBox.getString(key: _brokerCollectFromDateKey, cache: true,) ?? '');
        break;
    }
    
    if (dateString.isNotEmpty) {
      return DateTime.parse(dateString);
    }

    return null;
  }

  static int getBrokerCollectAccumulationRate() {
    // get the data from local box
    String rateString = (
      LocalBox.getString(key: _brokerCollectAccumRateKey, cache: true,) ?? ''
    );
    if (rateString.isNotEmpty) {
      return int.parse(rateString);
    }

    // default it as 75%
    return 75;
  }

  static Future<void> clearBrokerCollect() async {
    // clear all the data for stock collect
    LocalBox.delete(key: _brokerCollectKey, exact: true);
    LocalBox.delete(key: _brokerCollectIDKey, exact: true);
    LocalBox.delete(key: _brokerCollectFromDateKey, exact: true);
    LocalBox.delete(key: _brokerCollectToDateKey, exact: true);
    LocalBox.delete(key: _brokerCollectAccumRateKey, exact: true);
  }

  static Future<void> setBrokerSpecific({
    required BrokerSummaryTxnDetailModel brokerSummaryData,
    required String brokerId,
    required CompanyDetailModel company,
    required DateTime fromDate,
    required DateTime toDate,
  }) async {
    // store the broker id
    LocalBox.putString(
      key: _brokerSpecificBrokerKey,
      value: brokerId,
      cache: true,
    );

    // stored the company detail information
    LocalBox.putString(
      key: _brokerSpecificCompanyKey,
      value: jsonEncode(company.toJson()),
      cache: true,
    );

    // store the from and to date
    LocalBox.putString(
      key: _brokerSpecificFromDateKey,
      value: fromDate.toString(),
      cache: true,
    );
    LocalBox.putString(
      key: _brokerSpecificToDateKey,
      value: toDate.toString(),
      cache: true,
    );

    // convert the json to string so we can stored it on the local storage
    LocalBox.putString(
      key: _brokerSpecificResultKey,
      value: jsonEncode(brokerSummaryData.toJson()),
      cache: true,
    );
  }

  static String getBrokerSpecificBroker() {
    // get the data from local box
    String brokerId = (LocalBox.getString(key: _brokerSpecificBrokerKey, cache: true,) ?? '');
    if (brokerId.isNotEmpty) {
      return brokerId;
    }

    return '';
  }

  static CompanyDetailModel? getBrokerSpecificCompany() {
    // get the data from local box
    String companyDetailString = (LocalBox.getString(key: _brokerSpecificCompanyKey, cache: true,) ?? '');
    if (companyDetailString.isNotEmpty) {
      // company detail data is not empty, convert the string to company detail model
      CompanyDetailModel companyDetail = CompanyDetailModel.fromJson(jsonDecode(companyDetailString));
      return companyDetail;
    }

    return null;
  }

  static DateTime? getBrokerSpecificDate({required DateType type}) {
    // get the data from local box
    String dateString = '';
    switch(type) {
      case DateType.to:
        dateString = (LocalBox.getString(key: _brokerSpecificToDateKey, cache: true,) ?? '');
        break;
      case DateType.from:
        dateString = (LocalBox.getString(key: _brokerSpecificFromDateKey, cache: true,) ?? '');
        break;
    }
    
    if (dateString.isNotEmpty) {
      return DateTime.parse(dateString);
    }

    return null;
  }

  static BrokerSummaryTxnDetailModel? getBrokerSpecificResult() {
    // get the data from local box
    String brokerSpecificResultString = (
      LocalBox.getString(key: _brokerSpecificResultKey, cache: true,) ?? ''
    );

    // check if the list is empty or not?
    if (brokerSpecificResultString.isNotEmpty) {
      // list is not empty, parse the string to FavouriteModel
      BrokerSummaryTxnDetailModel brokerSpecificData = BrokerSummaryTxnDetailModel.fromJson(jsonDecode(brokerSpecificResultString));
      return brokerSpecificData;
    }
    else {
      // no data
      return null;
    }
  }

  static Future<void> setBrokerCompany({
    required String stockCode,
    required DateTime fromDate,
    required DateTime toDate,
    required CompanyDetailModel companyDetail,
    required CompanyListModel companyList,
    required BrokerSummaryModel summaryGross,
    required BrokerSummaryModel summaryNet,
    required CompanyTopBrokerModel topBroker,

  }) async {
    // store the stock code
    LocalBox.putString(
      key: _brokerCompanyStockCodeKey,
      value: stockCode,
      cache: true,
    );

    // store the from and to date
    LocalBox.putString(
      key: _brokerCompanyFromDateKey,
      value: fromDate.toString(),
      cache: true,
    );
    LocalBox.putString(
      key: _brokerCompanyToDateKey,
      value: toDate.toString(),
      cache: true,
    );

    // stored company detail information
    LocalBox.putString(
      key: _brokerCompanyDetailKey,
      value: jsonEncode(companyDetail.toJson()),
      cache: true,
    );
    LocalBox.putString(
      key: _brokerCompanyListKey,
      value: jsonEncode(companyList.toJson()),
      cache: true,
    );

    // stored broker summary gross and net
    LocalBox.putString(
      key: _brokerCompanySummaryDataGrossKey,
      value: jsonEncode(summaryGross.toJson()),
      cache: true,
    );
    LocalBox.putString(
      key: _brokerCompanySummaryDataNetKey,
      value: jsonEncode(summaryNet.toJson()),
      cache: true,
    );

    // stored the top broker data
    LocalBox.putString(
      key: _brokerCompanyTopBrokerKey,
      value: jsonEncode(topBroker.toJson()),
      cache: true,
    );
  }

  static String getBrokerCompanyStockCode() {
    // get the data from local box
    String stockCode = (LocalBox.getString(key: _brokerCompanyStockCodeKey, cache: true,) ?? '');
    if (stockCode.isNotEmpty) {
      return stockCode;
    }

    return '';
  }

  static DateTime? getBrokerCompanyDate({required DateType type}) {
    // get the data from local box
    String dateString = '';
    switch(type) {
      case DateType.to:
        dateString = (LocalBox.getString(key: _brokerCompanyToDateKey, cache: true,) ?? '');
        break;
      case DateType.from:
        dateString = (LocalBox.getString(key: _brokerCompanyFromDateKey, cache: true,) ?? '');
        break;
    }
    
    if (dateString.isNotEmpty) {
      return DateTime.parse(dateString);
    }

    return null;
  }

  static CompanyDetailModel? getBrokerCompanyDetail() {
    // get the data from local box
    String companyDetailString = (
      LocalBox.getString(key: _brokerCompanyDetailKey, cache: true,) ?? ''
    );

    // check if the list is empty or not?
    if (companyDetailString.isNotEmpty) {
      // list is not empty, parse the string to FavouriteModel
      CompanyDetailModel companyDetail = CompanyDetailModel.fromJson(jsonDecode(companyDetailString));
      return companyDetail;
    }
    else {
      // no data
      return null;
    }
  }

  static CompanyListModel? getBrokerCompanyList() {
    // get the data from local box
    String companyListString = (
      LocalBox.getString(key: _brokerCompanyListKey, cache: true,) ?? ''
    );

    // check if the list is empty or not?
    if (companyListString.isNotEmpty) {
      // list is not empty, parse the string to FavouriteModel
      CompanyListModel companyList = CompanyListModel.fromJson(jsonDecode(companyListString));
      return companyList;
    }
    else {
      // no data
      return null;
    }
  }

  static BrokerSummaryModel? getBrokerCompanyGross() {
    // get the data from local box
    String brokerSummaryString = (
      LocalBox.getString(key: _brokerCompanySummaryDataGrossKey, cache: true,) ?? ''
    );

    // check if the list is empty or not?
    if (brokerSummaryString.isNotEmpty) {
      // list is not empty, parse the string to FavouriteModel
      BrokerSummaryModel brokerSummary = BrokerSummaryModel.fromJson(jsonDecode(brokerSummaryString));
      return brokerSummary;
    }
    else {
      // no data
      return null;
    }
  }

  static BrokerSummaryModel? getBrokerCompanyNet() {
    // get the data from local box
    String brokerSummaryString = (
      LocalBox.getString(key: _brokerCompanySummaryDataNetKey, cache: true,) ?? ''
    );

    // check if the list is empty or not?
    if (brokerSummaryString.isNotEmpty) {
      // list is not empty, parse the string to FavouriteModel
      BrokerSummaryModel brokerSummary = BrokerSummaryModel.fromJson(jsonDecode(brokerSummaryString));
      return brokerSummary;
    }
    else {
      // no data
      return null;
    }
  }

  static CompanyTopBrokerModel? getBrokerCompanyTopBroker() {
    // get the data from local box
    String topBrokerString = (
      LocalBox.getString(key: _brokerCompanyTopBrokerKey, cache: true,) ?? ''
    );

    // check if the list is empty or not?
    if (topBrokerString.isNotEmpty) {
      // list is not empty, parse the string to FavouriteModel
      CompanyTopBrokerModel topbroker = CompanyTopBrokerModel.fromJson(jsonDecode(topBrokerString));
      return topbroker;
    }
    else {
      // no data
      return null;
    }
  }
}