import 'package:flutter/material.dart';
import 'package:my_wealth/model/broker_model.dart';

class BrokerProvider extends ChangeNotifier {
  List<BrokerModel>? brokerList;

  setBrokerList(List<BrokerModel> brokerListData) {
    brokerList = brokerListData;
    notifyListeners();
  }
}