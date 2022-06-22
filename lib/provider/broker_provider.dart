import 'package:flutter/material.dart';
import 'package:my_wealth/model/broker_model.dart';
import 'package:my_wealth/model/broker_summary_top_model.dart';

class BrokerProvider extends ChangeNotifier {
  List<BrokerModel>? brokerList;
  BrokerSummaryTopModel? brokerTopList;

  setBrokerList(List<BrokerModel> brokerListData) {
    brokerList = brokerListData;
    notifyListeners();
  }

  setBrokerTopList(BrokerSummaryTopModel brokerTopListData) {
    brokerTopList = brokerTopListData;
    notifyListeners();
  }
}