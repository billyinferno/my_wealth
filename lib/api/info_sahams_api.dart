import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:my_wealth/model/common_array_model.dart';
import 'package:my_wealth/model/info_saham_price_model.dart';
import 'package:my_wealth/utils/function/parse_error.dart';
import 'package:my_wealth/utils/globals.dart';
import 'package:my_wealth/utils/prefs/shared_user.dart';

class InfoSahamsAPI {
  late String _bearerToken;

  InfoSahamsAPI() {
    // get the bearer token from user shared secured box
    getJwt();
  }

  void getJwt() {
    _bearerToken = UserSharedPreferences.getUserJWT();
  }

  Future<List<InfoSahamPriceModel>> getInfoSahamPrice(String code, [int? offset, int? limit]) async {
    int offsetUse = (offset ?? 0);
    int limitUse = (limit ?? 90);

    // if empty then we try to get again the bearer token from user preferences
    if (_bearerToken.isEmpty) {
      getJwt();
    }

    // check if we have bearer token or not?
    if (_bearerToken.isNotEmpty) {
      final response = await http.get(
        Uri.parse('${Globals.apiURL}api/info-sahams/code/$code/offset/$offsetUse/limit/$limitUse'),
        headers: {
          HttpHeaders.authorizationHeader: "Bearer $_bearerToken",
          'Content-Type': 'application/json',
        },
      );

      // check if we got 200 response or not?
      if (response.statusCode == 200) {
        // parse the response to get the data and process each one
        CommonArrayModel commonModel = CommonArrayModel.fromJson(jsonDecode(response.body));
        List<InfoSahamPriceModel> listInfoSahamPrice = [];
        for (var data in commonModel.data) {
          InfoSahamPriceModel infoSaham = InfoSahamPriceModel.fromJson(data['attributes']);
          listInfoSahamPrice.add(infoSaham);
        }
        return listInfoSahamPrice;
      }

      // status code is not 200, means we got error
      throw Exception(parseError(response.body).error.message);
    }
    else {
      throw Exception("No bearer token");
    }
  }
}