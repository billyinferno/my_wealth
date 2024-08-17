import 'package:flutter/material.dart';
import 'package:my_wealth/_index.g.dart';

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