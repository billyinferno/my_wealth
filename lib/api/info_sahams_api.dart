import 'dart:convert';
import 'package:my_wealth/model/common/common_array_model.dart';
import 'package:my_wealth/model/company/company_info_saham_price_model.dart';
import 'package:my_wealth/utils/globals.dart';
import 'package:my_wealth/utils/net/netutils.dart';

class InfoSahamsAPI {
  Future<List<InfoSahamPriceModel>> getInfoSahamPrice(String code, [int? offset, int? limit]) async {
    int offsetUse = (offset ?? 0);
    int limitUse = (limit ?? 90);

    // get saham information using netutils
    final String body = await NetUtils.get(
      url: '${Globals.apiInfoSaham}/code/$code/offset/$offsetUse/limit/$limitUse'
    ).onError((error, stackTrace) {
        throw Exception(error);
      }
    );

    // parse saham information list data
    CommonArrayModel commonModel = CommonArrayModel.fromJson(jsonDecode(body));
    List<InfoSahamPriceModel> listInfoSahamPrice = [];
    for (var data in commonModel.data) {
      InfoSahamPriceModel infoSaham = InfoSahamPriceModel.fromJson(data['attributes']);
      listInfoSahamPrice.add(infoSaham);
    }
    return listInfoSahamPrice;
  }

  Future<List<InfoSahamPriceModel>> getInfoSahamPriceDate(
    String code,
    DateTime from,
    DateTime to
  ) async {
    // get saham information using netutils
    final String body = await NetUtils.get(
      url: '${Globals.apiInfoSaham}/code/$code/from/${Globals.dfyyyyMMdd.format(from)}/to/${Globals.dfyyyyMMdd.format(to)}'
    ).onError((error, stackTrace) {
        throw Exception(error);
      }
    );

    // parse saham information list data
    CommonArrayModel commonModel = CommonArrayModel.fromJson(jsonDecode(body));
    List<InfoSahamPriceModel> listInfoSahamPrice = [];
    for (var data in commonModel.data) {
      InfoSahamPriceModel infoSaham = InfoSahamPriceModel.fromJson(data['attributes']);
      listInfoSahamPrice.add(infoSaham);
    }
    return listInfoSahamPrice;
  }
}