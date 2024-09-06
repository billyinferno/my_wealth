import 'dart:convert';
import 'package:my_wealth/_index.g.dart';

class InfoSahamsAPI {
  Future<List<InfoSahamPriceModel>> getInfoSahamPrice({
    required String code,
    int offset = 0,
    int limit = 90,
  }) async {
    // get saham information using netutils
    final String body = await NetUtils.get(
      url: '${Globals.apiInfoSaham}/code/$code/offset/$offset/limit/$limit'
    ).onError((error, stackTrace) {
      Log.error(
        message: 'Error on getInfoSahamPrice',
        error: error,
        stackTrace: stackTrace,
      );
      throw error as NetException;
    });

    // parse saham information list data
    CommonArrayModel commonModel = CommonArrayModel.fromJson(jsonDecode(body));
    List<InfoSahamPriceModel> listInfoSahamPrice = [];
    for (var data in commonModel.data) {
      InfoSahamPriceModel infoSaham = InfoSahamPriceModel.fromJson(data['attributes']);
      listInfoSahamPrice.add(infoSaham);
    }
    return listInfoSahamPrice;
  }

  Future<List<InfoSahamPriceModel>> getInfoSahamPriceDate({
    required String code,
    required DateTime from,
    required DateTime to
  }) async {
    // get saham information using netutils
    final String body = await NetUtils.get(
      url: '${Globals.apiInfoSaham}/code/$code/from/${Globals.dfyyyyMMdd.formatLocal(from)}/to/${Globals.dfyyyyMMdd.formatLocal(to)}'
    ).onError((error, stackTrace) {
      Log.error(
        message: 'Error on getInfoSahamPriceDate',
        error: error,
        stackTrace: stackTrace,
      );
      throw error as NetException;
    });

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