import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:my_wealth/model/common_array_model.dart';
import 'package:my_wealth/model/portofolio_detail_model.dart';
import 'package:my_wealth/model/portofolio_summary_model.dart';
import 'package:my_wealth/utils/function/parse_error.dart';
import 'package:my_wealth/utils/globals.dart';
import 'package:my_wealth/utils/prefs/shared_user.dart';

class PortofolioAPI {
  late String _bearerToken;

  PortofolioAPI() {
    // get the bearer token from user shared secured box
    getJwt();
  }

  void getJwt() {
    _bearerToken = UserSharedPreferences.getUserJWT();
  }

  Future<List<PortofolioSummaryModel>> getPortofolioSummary(String type) async {
    // if empty then we try to get again the bearer token from user preferences
    if (_bearerToken.isEmpty) {
      getJwt();
    }

    // check if we have bearer token or not?
    if (_bearerToken.isNotEmpty) {
      final response = await http.get(
        Uri.parse('${Globals.apiURL}api/portofolio/$type'),
        headers: {
          HttpHeaders.authorizationHeader: "Bearer $_bearerToken",
          'Content-Type': 'application/json',
        },
      );

      // check if we got 200 response or not?
      if (response.statusCode == 200) {
        // parse the response to get the data and process each one
        CommonArrayModel commonModel = CommonArrayModel.fromJson(jsonDecode(response.body));
        List<PortofolioSummaryModel> portofolioSummary = [];
        for (var data in commonModel.data) {
          PortofolioSummaryModel portofolio = PortofolioSummaryModel.fromJson(data['attributes']);
          portofolioSummary.add(portofolio);
        }
        return portofolioSummary;
      }

      // status code is not 200, means we got error
      throw Exception(parseError(response.body).error.message);
    }
    else {
      throw Exception("No bearer token");
    }
  }

  Future<List<PortofolioDetailModel>> getPortofolioDetail(String type, String companyType) async {
    // if empty then we try to get again the bearer token from user preferences
    if (_bearerToken.isEmpty) {
      getJwt();
    }

    // check if we have bearer token or not?
    if (_bearerToken.isNotEmpty) {
      String companyTypeBase64 = base64.encode(utf8.encode(companyType));
      final response = await http.get(
        Uri.parse('${Globals.apiURL}api/portofolio/detail/$type/companytype/$companyTypeBase64'),
        headers: {
          HttpHeaders.authorizationHeader: "Bearer $_bearerToken",
          'Content-Type': 'application/json',
        },
      );

      // check if we got 200 response or not?
      if (response.statusCode == 200) {
        // parse the response to get the data and process each one
        CommonArrayModel commonModel = CommonArrayModel.fromJson(jsonDecode(response.body));
        List<PortofolioDetailModel> portofolioDetail = [];
        for (var data in commonModel.data) {
          PortofolioDetailModel portofolio = PortofolioDetailModel.fromJson(data['attributes']);
          portofolioDetail.add(portofolio);
        }
        return portofolioDetail;
      }

      // status code is not 200, means we got error
      throw Exception(parseError(response.body).error.message);
    }
    else {
      throw Exception("No bearer token");
    }
  }
}