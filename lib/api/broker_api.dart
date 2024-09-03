import 'dart:convert';
import 'package:my_wealth/_index.g.dart';

class BrokerAPI {
  Future<List<BrokerModel>> getBroker() async {
    // get the broker data using netutils
    final String body = await NetUtils.get(
      url: Globals.apiBroker
    ).onError((error, stackTrace) {
      Log.error(
        message: 'Error on getBroker',
        error: error,
        stackTrace: stackTrace,
      );
      throw error as NetException;
    });

    // parse the body we got
    CommonArrayModel commonModel = CommonArrayModel.fromJson(jsonDecode(body));
    
    // get all the list broker
    List<BrokerModel> listBroker = [];
    for (var data in commonModel.data) {
      BrokerModel broker = BrokerModel.fromJson(data['attributes']);
      listBroker.add(broker);
    }

    // return the list broker that we got
    return listBroker;
  }
}