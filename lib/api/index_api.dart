import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:my_wealth/model/common/common_array_model.dart';
import 'package:my_wealth/model/index/index_model.dart';
import 'package:my_wealth/model/index/index_price_model.dart';
import 'package:my_wealth/utils/function/parse_error.dart';
import 'package:my_wealth/utils/globals.dart';
import 'package:my_wealth/storage/prefs/shared_user.dart';

class IndexAPI {
  late String _bearerToken;

  IndexAPI() {
    // get the bearer token from user shared secured box
    getJwt();
  }

  void getJwt() {
    _bearerToken = UserSharedPreferences.getUserJWT();
  }

  Future<List<IndexModel>> getIndex() async {
    // if empty then we try to get again the bearer token from user preferences
    if (_bearerToken.isEmpty) {
      getJwt();
    }

    // check if we have bearer token or not?
    if (_bearerToken.isNotEmpty) {
      final response = await http.get(
        Uri.parse('${Globals.apiURL}api/indices'),
        headers: {
          HttpHeaders.authorizationHeader: "Bearer $_bearerToken",
          'Content-Type': 'application/json',
        },
      );

      // check if we got 200 response or not?
      if (response.statusCode == 200) {
        // parse the response to get the data and process each one
        CommonArrayModel commonModel = CommonArrayModel.fromJson(jsonDecode(response.body));
        List<IndexModel> listIndex = [];
        for (var data in commonModel.data) {
          IndexModel index = IndexModel.fromJson(data['attributes']);
          listIndex.add(index);
        }
        return listIndex;
      }

      // status code is not 200, means we got error
      throw Exception(parseError(response.body).error.message);
    }
    else {
      throw Exception("No bearer token");
    }
  }

  Future<List<IndexPriceModel>> getIndexPrice(int indexId) async {
    // if empty then we try to get again the bearer token from user preferences
    if (_bearerToken.isEmpty) {
      getJwt();
    }

    // check if we have bearer token or not?
    if (_bearerToken.isNotEmpty) {
      final response = await http.get(
        Uri.parse('${Globals.apiURL}api/indices-prices/$indexId'),
        headers: {
          HttpHeaders.authorizationHeader: "Bearer $_bearerToken",
          'Content-Type': 'application/json',
        },
      );

      // check if we got 200 response or not?
      if (response.statusCode == 200) {
        // parse the response to get the data and process each one
        CommonArrayModel commonModel = CommonArrayModel.fromJson(jsonDecode(response.body));
        List<IndexPriceModel> listIndexPrice = [];
        for (var data in commonModel.data) {
          IndexPriceModel indexPrice = IndexPriceModel.fromJson(data['attributes']);
          listIndexPrice.add(indexPrice);
        }
        return listIndexPrice;
      }

      // status code is not 200, means we got error
      throw Exception(parseError(response.body).error.message);
    }
    else {
      throw Exception("No bearer token");
    }
  }
}