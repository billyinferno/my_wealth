import 'dart:convert';
import 'package:my_wealth/model/broker_model.dart';
import 'package:my_wealth/model/broker_summary_top_model.dart';
import 'package:my_wealth/storage/local_box.dart';

class BrokerSharedPreferences {
  static const _brokerKey = "broker_list";
  static const _brokerTopKey = "broker_top_list";

  static Future<void> setBrokerList(List<BrokerModel> brokerList) async {
    // stored the user info to box
    if(LocalBox.keyBox == null) {
      LocalBox.init();
    }

    // convert the json to string so we can stored it on the local storage
    List<String> indexListResp = [];
    for (BrokerModel broker in brokerList) {
      indexListResp.add(jsonEncode(broker.toJson()));
    }
    LocalBox.putStringList(_brokerKey, indexListResp);
  }

  static List<BrokerModel> getBrokerList() {
    // check if the key box is null or not?
    if(LocalBox.keyBox == null) {
      LocalBox.init();
    }

    // get the data from local box
    List<String> brokerList = (LocalBox.getStringList(_brokerKey) ?? []);

    // check if the list is empty or not?
    if (brokerList.isNotEmpty) {
      // list is not empty, parse the string to FavouriteModel
      List<BrokerModel> ret = [];
      for (String brokerString in brokerList) {
        BrokerModel index = BrokerModel.fromJson(jsonDecode(brokerString));
        ret.add(index);
      }

      // return the favourites list
      return ret;
    }
    else {
      // no data
      return [];
    }
  }

  static Future<void> setBroketTopList(BrokerSummaryTopModel topList) async {
    // stored the user info to box
    if(LocalBox.keyBox == null) {
      LocalBox.init();
    }

    // convert the json to string so we can stored it on the local storage
    LocalBox.putString(_brokerTopKey, jsonEncode(topList.toJson()));
  }

  static BrokerSummaryTopModel? getBrokerTopList() {
    // check if the key box is null or not?
    if(LocalBox.keyBox == null) {
      LocalBox.init();
    }

    // get the data from local box
    String topList = (LocalBox.getString(_brokerTopKey) ?? '');

    // check if the list is empty or not?
    if (topList.isNotEmpty) {
      // data is not empty, parse the string to broker top model0
      BrokerSummaryTopModel brokerTopList = BrokerSummaryTopModel.fromJson(jsonDecode(topList));

      // return the top list
      return brokerTopList;
    }
    else {
      // no data
      return null;
    }
  }
}