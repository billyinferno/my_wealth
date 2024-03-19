import 'dart:convert';
import 'package:my_wealth/model/common/common_array_model.dart';
import 'package:my_wealth/model/company/company_info_fundamentals_model.dart';
import 'package:my_wealth/utils/globals.dart';
import 'package:my_wealth/utils/net/netutils.dart';

class InfoFundamentalAPI {
  Future<List<InfoFundamentalsModel>> getInfoFundamental(String code, [int? quarter]) async {
    int quarterUse = (quarter ?? 5);

    // get company fundamental data using netutils
    final String body = await NetUtils.get(
      url: '${Globals.apiInfoFundamentals}/code/$code/quarter/$quarterUse'
    ).onError((error, stackTrace) {
        throw Exception(error);
      }
    );

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