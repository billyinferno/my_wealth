import 'dart:convert';
import 'package:my_wealth/model/broker_top_transaction_model.dart';
import 'package:my_wealth/model/sector_summary_model.dart';
import 'package:my_wealth/model/top_worse_company_list_model.dart';
import 'package:my_wealth/storage/local_box.dart';

class InsightSharedPreferences {
  static const _sectorSummaryKey = "sector_summary";
  static const _topWorseCompanyListKey = "insight_company_list_";
  static const _topReksadanaListKey = "insight_reksadana_list_";
  static const _brokerTopTransactionKey = "insight_broker_top_txn";

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
          theYTD: [])
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
          theYTD: [])
        );
    }
  }
}