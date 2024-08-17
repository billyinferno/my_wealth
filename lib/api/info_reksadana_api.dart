import 'dart:convert';
import 'package:my_wealth/_index.g.dart';

class InfoReksadanaAPI {
  Future<List<InfoReksadanaModel>> getInfoReksadana(int companyId, [int? limit]) async {
    int limitUse = (limit ?? 90);

    // get reksadana information using netutils
    final String body = await NetUtils.get(
      url: '${Globals.apiInfoReksadana}/id/$companyId/limit/$limitUse'
    ).onError((error, stackTrace) {
        throw Exception(error);
      }
    );

    // parse the response to reksdana information
    CommonArrayModel commonModel = CommonArrayModel.fromJson(jsonDecode(body));
    List<InfoReksadanaModel> listInfoReksadana = [];
    for (var data in commonModel.data) {
      InfoReksadanaModel index = InfoReksadanaModel.fromJson(data['attributes']);
      listInfoReksadana.add(index);
    }
    return listInfoReksadana;
  }

  Future<List<InfoReksadanaModel>> getInfoReksadanaDate(
    int companyId,
    DateTime from,
    DateTime to
  ) async {
    // get reksadana information using netutils
    final String body = await NetUtils.get(
      url: '${Globals.apiInfoReksadana}/id/$companyId/from/${Globals.dfyyyyMMdd.format(from)}/to/${Globals.dfyyyyMMdd.format(to)}'
    ).onError((error, stackTrace) {
        throw Exception(error);
      }
    );

    // parse the response to reksdana information
    CommonArrayModel commonModel = CommonArrayModel.fromJson(jsonDecode(body));
    List<InfoReksadanaModel> listInfoReksadana = [];
    for (var data in commonModel.data) {
      InfoReksadanaModel index = InfoReksadanaModel.fromJson(data['attributes']);
      listInfoReksadana.add(index);
    }
    return listInfoReksadana;
  }
}