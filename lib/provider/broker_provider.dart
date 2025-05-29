import 'package:flutter/material.dart';
import 'package:my_wealth/_index.g.dart';

class BrokerProvider extends ChangeNotifier {
  List<BrokerModel>? brokerList;
  BrokerSummaryTopModel? brokerTopList;

  void setBrokerList({required List<BrokerModel> brokerListData}) {
    brokerList = brokerListData;
    notifyListeners();
  }

  void setBrokerTopList({required BrokerSummaryTopModel brokerTopListData}) {
    brokerTopList = brokerTopListData;
    notifyListeners();
  }
}