import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:my_wealth/model/common/common_array_model.dart';
import 'package:my_wealth/model/company/company_info_fundamentals_model.dart';
import 'package:my_wealth/utils/function/parse_error.dart';
import 'package:my_wealth/utils/globals.dart';
import 'package:my_wealth/storage/prefs/shared_user.dart';

class InfoFundamentalAPI {
  late String _bearerToken;

  InfoFundamentalAPI() {
    // get the bearer token from user shared secured box
    getJwt();
  }

  void getJwt() {
    _bearerToken = UserSharedPreferences.getUserJWT();
  }

  Future<List<InfoFundamentalsModel>> getInfoFundamental(String code, [int? quarter]) async {
    int quarterUse = (quarter ?? 5);

    // if empty then we try to get again the bearer token from user preferences
    if (_bearerToken.isEmpty) {
      getJwt();
    }

    // check if we have bearer token or not?
    if (_bearerToken.isNotEmpty) {
      final response = await http.get(
        Uri.parse('${Globals.apiURL}api/info-fundamentals/code/$code/quarter/$quarterUse'),
        headers: {
          HttpHeaders.authorizationHeader: "Bearer $_bearerToken",
          'Content-Type': 'application/json',
        },
      );

      // check if we got 200 response or not?
      if (response.statusCode == 200) {
        // parse the response to get the data and process each one
        CommonArrayModel commonModel = CommonArrayModel.fromJson(jsonDecode(response.body));
        List<InfoFundamentalsModel> listInfoFundamentals = [];
        for (var data in commonModel.data) {
          InfoFundamentalsModel index = InfoFundamentalsModel.fromJson(data['attributes']);
          listInfoFundamentals.add(index);
        }
        return listInfoFundamentals;
      }

      // status code is not 200, means we got error
      throw Exception(parseError(response.body).error.message);
    }
    else {
      throw Exception("No bearer token");
    }
  }
}