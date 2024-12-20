import 'dart:convert';
import 'package:my_wealth/_index.g.dart';

class InfoReksadanaAPI {
  Future<List<InfoReksadanaModel>> getInfoReksadana({
    required int companyId,
    int limit = 90,
  }) async {
    // get reksadana information using netutils
    final String body = await NetUtils.get(
      url: '${Globals.apiInfoReksadana}/id/$companyId/limit/$limit'
    ).onError((error, stackTrace) {
      Log.error(
        message: 'Error on getInfoReksadana',
        error: error,
        stackTrace: stackTrace,
      );
      throw error as NetException;
    });

    // parse the response to reksdana information
    CommonArrayModel commonModel = CommonArrayModel.fromJson(jsonDecode(body));
    List<InfoReksadanaModel> listInfoReksadana = [];
    for (var data in commonModel.data) {
      InfoReksadanaModel index = InfoReksadanaModel.fromJson(data['attributes']);
      listInfoReksadana.add(index);
    }
    return listInfoReksadana;
  }

  Future<List<InfoReksadanaModel>> getInfoReksadanaDate({
    required int companyId,
    required DateTime from,
    required DateTime to
  }) async {
    // get reksadana information using netutils
    final String body = await NetUtils.get(
      url: '${Globals.apiInfoReksadana}/id/$companyId/from/${Globals.dfyyyyMMdd.formatLocal(from)}/to/${Globals.dfyyyyMMdd.formatLocal(to)}'
    ).onError((error, stackTrace) {
      Log.error(
        message: 'Error on getInfoReksadanaDate',
        error: error,
        stackTrace: stackTrace,
      );
      throw error as NetException;
    });

    // parse the response to reksdana information
    CommonArrayModel commonModel = CommonArrayModel.fromJson(jsonDecode(body));
    List<InfoReksadanaModel> listInfoReksadana = [];
    for (var data in commonModel.data) {
      InfoReksadanaModel index = InfoReksadanaModel.fromJson(data['attributes']);
      listInfoReksadana.add(index);
    }
    return listInfoReksadana;
  }

  Future<MinMaxDateModel> getInfoReksadanaMinMaxDate({
    required int companyId
  }) async {
    // get the API response
    final String body = await NetUtils.get(
      url: '${Globals.apiInfoReksadana}/minmax/date/$companyId'
    ).onError((error, stackTrace) {
      Log.error(
        message: 'Error on getInfoReksadanaMinMaxDate',
        error: error,
        stackTrace: stackTrace,
      );
      throw error as NetException;
    });

    // parse the response to get broker summary data based on the stock code
    CommonSingleModel commonModel = CommonSingleModel.fromJson(jsonDecode(body));
    MinMaxDateModel minMaxDate = MinMaxDateModel.fromJson(commonModel.data['attributes']);
    return minMaxDate;
  }
}