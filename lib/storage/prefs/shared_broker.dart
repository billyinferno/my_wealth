import 'dart:convert';
import 'package:my_wealth/_index.g.dart';

class BrokerSharedPreferences {
  static const _brokerKey = "broker_list";
  static const _brokerTopKey = "broker_top_list";
  static const _brokerMinDateKey = "broker_min_date";
  static const _brokerMaxDateKey = "broker_max_date";
  static const _brokerSummarySectorFlowKey = "broker_summary_sector_flow";
  static const _brokerSummaryFlowKey = "broker_summary_flow";
  static const _brokerSummaryFlowLastUpdateKey = "broker_summary_flow_last_update";

  static Future<void> setBrokerList({
    required List<BrokerModel> brokerList
  }) async {
    // convert the json to string so we can stored it on the local storage
    List<String> indexListResp = [];
    for (BrokerModel broker in brokerList) {
      indexListResp.add(jsonEncode(broker.toJson()));
    }
    LocalBox.putStringList(
      key: _brokerKey,
      value: indexListResp,
    );
  }

  static List<BrokerModel> getBrokerList() {
    // get the data from local box
    List<String> brokerList = (LocalBox.getStringList(key: _brokerKey) ?? []);

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

  static Future<void> setBrokerTopList({
    required BrokerSummaryTopModel topList
  }) async {
    // convert the json to string so we can stored it on the local storage
    LocalBox.putString(
      key: _brokerTopKey,
      value: jsonEncode(topList.toJson())
    );
  }

  static BrokerSummaryTopModel? getBrokerTopList() {
    // get the data from local box
    String topList = (LocalBox.getString(key: _brokerTopKey) ?? '');

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

  static Future<void> setBrokerMinMaxDate({
    required DateTime minDate,
    required DateTime maxDate
  }) async {
    // put the date on the shared preferences
    LocalBox.putString(key: _brokerMinDateKey, value: minDate.toString());
    LocalBox.putString(key: _brokerMaxDateKey, value: maxDate.toString());
  }

  static DateTime? getBrokerMinDate() {
    // get the data from local box
    String strMinDate = (LocalBox.getString(key: _brokerMinDateKey) ?? '');
    if (strMinDate.isNotEmpty) {
      return DateTime.parse(strMinDate);
    }

    return null;
  }

  static DateTime? getBrokerMaxDate() {
    // get the data from local box
    String strMaxDate = (LocalBox.getString(key: _brokerMaxDateKey) ?? '');
    if (strMaxDate.isNotEmpty) {
      return DateTime.parse(strMaxDate);
    }

    return null;
  }

  static Future<void> setBrokerSummarySectorFlow({
    required List<BrokerSummarySectorFlowModel> sectorFlowList
  }) async {
    // convert the json to string so we can stored it on the local storage
    List<String> indexListResp = [];
    for (BrokerSummarySectorFlowModel broker in sectorFlowList) {
      indexListResp.add(jsonEncode(broker.toJson()));
    }
    LocalBox.putStringList(
      key: _brokerSummarySectorFlowKey,
      value: indexListResp,
    );
  }

  static List<BrokerSummarySectorFlowModel> getBrokerSummarySectorFlow() {
    // get the data from local box
    List<String> brokerList = (LocalBox.getStringList(key: _brokerSummarySectorFlowKey) ?? []);

    // check if the list is empty or not?
    if (brokerList.isNotEmpty) {
      // list is not empty, parse the string to FavouriteModel
      List<BrokerSummarySectorFlowModel> ret = [];
      for (String brokerString in brokerList) {
        BrokerSummarySectorFlowModel index = BrokerSummarySectorFlowModel.fromJson(jsonDecode(brokerString));
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

  static Future<void> setBrokerSummaryFlow({
    required BrokerSummaryFlowModel data
  }) async {
    // convert the json to string so we can stored it on the local storage
    LocalBox.putString(
      key: _brokerSummaryFlowKey,
      value: jsonEncode(data.toJson())
    );
    // put the last update date for broker summary flow
    LocalBox.putString(
      key: _brokerSummaryFlowLastUpdateKey,
      value: DateTime.now().toString(),
    );
  }

  static BrokerSummaryFlowModel? getBrokerSummaryFlow() {
    // get the data from local box
    String topList = (LocalBox.getString(key: _brokerSummaryFlowKey) ?? '');

    // check if the list is empty or not?
    if (topList.isNotEmpty) {
      // data is not empty, parse the string to broker top model0
      BrokerSummaryFlowModel brokerSummaryFlow = BrokerSummaryFlowModel.fromJson(jsonDecode(topList));

      // return the top list
      return brokerSummaryFlow;
    }
    else {
      // no data
      return null;
    }
  }

  static DateTime? getBrokerSummaryFlowLastUpdate() {
    // get the data from local box
    String strLastUpdate = (LocalBox.getString(key: _brokerSummaryFlowLastUpdateKey) ?? '');
    if (strLastUpdate.isNotEmpty) {
      return DateTime.parse(strLastUpdate);
    }

    return null;
  }
}