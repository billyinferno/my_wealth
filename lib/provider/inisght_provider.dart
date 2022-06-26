import 'package:flutter/cupertino.dart';
import 'package:my_wealth/model/broker_top_transaction_model.dart';
import 'package:my_wealth/model/sector_summary_model.dart';
import 'package:my_wealth/model/top_worse_company_list_model.dart';

class InsightProvider extends ChangeNotifier {
  List<SectorSummaryModel>? sectorSummaryList;
  TopWorseCompanyListModel? topCompanyList;
  TopWorseCompanyListModel? worseCompanyList;
  BrokerTopTransactionModel? brokerTopTransactionList;

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
}