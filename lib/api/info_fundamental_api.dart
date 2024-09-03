import 'dart:convert';
import 'package:my_wealth/_index.g.dart';

class InfoFundamentalAPI {
  Future<List<InfoFundamentalsModel>> getInfoFundamental({
    required String code,
    int quarter = 5,
  }) async {
    // get company fundamental data using netutils
    final String body = await NetUtils.get(
      url: '${Globals.apiInfoFundamentals}/code/$code/quarter/$quarter'
    ).onError((error, stackTrace) {
      Log.error(
        message: 'Error on getInfoFundamental',
        error: error,
        stackTrace: stackTrace,
      );
      throw error as NetException;
    });

    // parse the response to get company fundamental information
    CommonArrayModel commonModel = CommonArrayModel.fromJson(jsonDecode(body));
    List<InfoFundamentalsModel> listInfoFundamentals = [];
    for (var data in commonModel.data) {
      InfoFundamentalsModel index = InfoFundamentalsModel.fromJson(data['attributes']);
      listInfoFundamentals.add(index);
    }
    return listInfoFundamentals;
  }
}