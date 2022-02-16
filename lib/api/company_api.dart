import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:my_wealth/model/common_array_model.dart';
import 'package:my_wealth/model/common_single_model.dart';
import 'package:my_wealth/model/company_detail_model.dart';
import 'package:my_wealth/model/company_search_model.dart';
import 'package:my_wealth/utils/globals.dart';
import 'package:my_wealth/utils/prefs/shared_user.dart';

class CompanyAPI {
  late String _bearerToken;

  CompanyAPI() {
    // get the bearer token from user shared secured box
    _getJwt();
  }

  void _getJwt() {
    _bearerToken = UserSharedPreferences.getUserJWT();
  }

  Future<CompanyDetailModel> getCompanyDetail(int companyId) async {
    // if empty then we try to get again the bearer token from user preferences
    if (_bearerToken.isEmpty) {
      _getJwt();
    }

    // check if we have bearer token or not?
    if (_bearerToken.isNotEmpty) {
      final response = await http.get(
        Uri.parse(Globals.apiURL + 'api/companies/detail/' + companyId.toString()),
        headers: {
          HttpHeaders.authorizationHeader: "Bearer " + _bearerToken,
          'Content-Type': 'application/json',
        },
      );

      // check if we got 200 response or not?
      if (response.statusCode == 200) {
        // parse the response to get the data and process each one
        CommonSingleModel _commonModel = CommonSingleModel.fromJson(jsonDecode(response.body));
        CompanyDetailModel _company = CompanyDetailModel.fromJson(_commonModel.data[0]['attributes']);
        return _company;
      }

      // status code is not 200, means we got error
      throw Exception("err=" + response.body);
    }
    else {
      throw Exception("err=No bearer token");
    }
  }

  Future<List<CompanySearchModel>> getCompanyByName(String companyName) async {
    // if empty then we try to get again the bearer token from user preferences
    if (_bearerToken.isEmpty) {
      _getJwt();
    }

    // check if we have bearer token or not?
    if (_bearerToken.isNotEmpty) {
      final response = await http.get(
        Uri.parse(Globals.apiURL + 'api/companies/name/' + companyName.toLowerCase()),
        headers: {
          HttpHeaders.authorizationHeader: "Bearer " + _bearerToken,
          'Content-Type': 'application/json',
        },
      );

      // check if we got 200 response or not?
      if (response.statusCode == 200) {
        // parse the response to get the data and process each one
        CommonArrayModel _commonModel = CommonArrayModel.fromJson(jsonDecode(response.body));
        List<CompanySearchModel> _ret = [];
        for (dynamic _data in _commonModel.data) {
          CompanySearchModel _company = CompanySearchModel.fromJson(_data['attributes']);
          _ret.add(_company);
        }
        return _ret;
      }

      // status code is not 200, means we got error
      throw Exception("err=" + response.body);
    }
    else {
      throw Exception("err=No bearer token");
    }
  }
}