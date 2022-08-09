import 'dart:convert';
import 'package:my_wealth/model/broker_top_transaction_model.dart';
import 'package:my_wealth/model/inisght_bandar_interest_model.dart';
import 'package:my_wealth/model/insight_accumulation_model.dart';
import 'package:my_wealth/model/insight_eps_model.dart';
import 'package:my_wealth/model/insight_sideway_model.dart';
import 'package:my_wealth/model/sector_summary_model.dart';
import 'package:my_wealth/model/top_worse_company_list_model.dart';
import 'package:my_wealth/storage/local_box.dart';

class InsightSharedPreferences {
  static const _sectorSummaryKey = "sector_summary";
  static const _topWorseCompanyListKey = "insight_company_list_";
  static const _topReksadanaListKey = "insight_reksadana_list_";
  static const _brokerTopTransactionKey = "insight_broker_top_txn";
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
}