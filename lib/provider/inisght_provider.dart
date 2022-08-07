import 'package:flutter/cupertino.dart';
import 'package:my_wealth/model/broker_top_transaction_model.dart';
import 'package:my_wealth/model/inisght_bandar_interest_model.dart';
import 'package:my_wealth/model/insight_accumulation_model.dart';
import 'package:my_wealth/model/sector_summary_model.dart';
import 'package:my_wealth/model/top_worse_company_list_model.dart';

class InsightProvider extends ChangeNotifier {
  List<SectorSummaryModel>? sectorSummaryList;
  TopWorseCompanyListModel? topCompanyList;
  TopWorseCompanyListModel? worseCompanyList;
  Map<String, TopWorseCompanyListModel>? topReksadanaList;
  BrokerTopTransactionModel? brokerTopTransactionList;
  InsightBandarInterestModel? bandarInterestList;
  DateTime? topAccumToDate;
  int? topAccumRate;
  List<InsightAccumulationModel>? topAccumList;

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
}