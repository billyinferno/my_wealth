import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:my_wealth/model/common/common_array_model.dart';
import 'package:my_wealth/model/company/company_info_reksadana_model.dart';
import 'package:my_wealth/storage/prefs/shared_user.dart';
import 'package:my_wealth/utils/function/parse_error.dart';
import 'package:my_wealth/utils/globals.dart';

class InfoReksadanaAPI {
  late String _bearerToken;

  InfoReksadanaAPI() {
    // get the bearer token from user shared secured box
    getJwt();
  }

  void getJwt() {
    _bearerToken = UserSharedPreferences.getUserJWT();
  }

  Future<List<InfoReksadanaModel>> getInfoReksadana(int companyId, [int? limit]) async {
    int limitUse = (limit ?? 90);

    // if empty then we try to get again the bearer token from user preferences
    if (_bearerToken.isEmpty) {
      getJwt();
    }

    // check if we have bearer token or not?
    if (_bearerToken.isNotEmpty) {
      final response = await http.get(
        Uri.parse('${Globals.apiURL}api/info-reksadanas/id/$companyId/limit/$limitUse'),
        headers: {
          HttpHeaders.authorizationHeader: "Bearer $_bearerToken",
          'Content-Type': 'application/json',
        },
      );

      // check if we got 200 response or not?
      if (response.statusCode == 200) {
        // parse the response to get the data and process each one
        CommonArrayModel commonModel = CommonArrayModel.fromJson(jsonDecode(response.body));
        List<InfoReksadanaModel> listInfoReksadana = [];
        for (var data in commonModel.data) {
          InfoReksadanaModel index = InfoReksadanaModel.fromJson(data['attributes']);
          listInfoReksadana.add(index);
        }
        return listInfoReksadana;
      }

      // status code is not 200, means we got error
      throw Exception(parseError(response.body).error.message);
    }
    else {
      throw Exception("No bearer token");
    }
  }
}