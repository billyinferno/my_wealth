import 'dart:convert';
import 'package:my_wealth/_index.g.dart';

class PortofolioAPI {
  Future<List<PortofolioSummaryModel>> getPortofolioSummary({
    required String type
  }) async {
    // get portofolio data using netutils
    final String body = await NetUtils.get(
      url: '${Globals.apiPortofolio}/$type'
    ).onError((error, stackTrace) {
      Log.error(
        message: 'Error on getPortofolioSummary',
        error: error,
        stackTrace: stackTrace,
      );
      throw error as NetException;
    });

    // parse the response to get portofolio summary list for this type
    CommonArrayModel commonModel = CommonArrayModel.fromJson(jsonDecode(body));
    List<PortofolioSummaryModel> portofolioSummary = [];
    for (var data in commonModel.data) {
      PortofolioSummaryModel portofolio = PortofolioSummaryModel.fromJson(data['attributes']);
      portofolioSummary.add(portofolio);
    }
    return portofolioSummary;
  }

  Future<List<PortofolioDetailModel>> getPortofolioDetail({
    required String type,
    required String companyType
  }) async {
    // convert the company type into Base64
    String companyTypeBase64 = base64.encode(utf8.encode(companyType));

    // get portofolio data using netutils
    final String body = await NetUtils.get(
      url: '${Globals.apiPortofolio}/detail/$type/companytype/$companyTypeBase64'
    ).onError((error, stackTrace) {
      Log.error(
        message: 'Error on getPortofolioDetail',
        error: error,
        stackTrace: stackTrace,
      );
      throw error as NetException;
    });

    // parse the response to get list of portofolio detail for this type
    CommonArrayModel commonModel = CommonArrayModel.fromJson(jsonDecode(body));
    List<PortofolioDetailModel> portofolioDetail = [];
    for (var data in commonModel.data) {
      PortofolioDetailModel portofolio = PortofolioDetailModel.fromJson(data['attributes']);
      portofolioDetail.add(portofolio);
    }
    return portofolioDetail;
  }
}