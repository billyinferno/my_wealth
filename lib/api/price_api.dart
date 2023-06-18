import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:my_wealth/model/common/common_single_model.dart';
import 'package:my_wealth/model/price/price_saham_ma_model.dart';
import 'package:my_wealth/model/price/price_saham_movement_model.dart';
import 'package:my_wealth/utils/function/parse_error.dart';
import 'package:my_wealth/utils/globals.dart';
import 'package:my_wealth/storage/prefs/shared_user.dart';

class PriceAPI {
  late String _bearerToken;
  
  PriceAPI() {
    // get the bearer token from user shared secured box
    getJwt();
  }

  void getJwt() {
    _bearerToken = UserSharedPreferences.getUserJWT();
  }

  Future<PriceSahamMovingAverageModel> getPriceMovingAverage(String stockCode) async {
    // if empty then we try to get again the bearer token from user preferences
    if (_bearerToken.isEmpty) {
      getJwt();
    }

    // check if we have bearer token or not?
    if (_bearerToken.isNotEmpty) {
      final response = await http.get(
        Uri.parse('${Globals.apiURL}api/price-sahams/ma/code/$stockCode'),
        headers: {
          HttpHeaders.authorizationHeader: "Bearer $_bearerToken",
          'Content-Type': 'application/json',
        },
      );

      // check if we got 200 response or not?
      if (response.statusCode == 200) {
        // parse the response to get the data and process each one
        CommonSingleModel commonModel = CommonSingleModel.fromJson(jsonDecode(response.body));
        PriceSahamMovingAverageModel priceMa = PriceSahamMovingAverageModel.fromJson(commonModel.data['attributes']);
        return priceMa;
      }

      // status code is not 200, means we got error
      throw Exception(parseError(response.body).error.message);
    }
    else {
      throw Exception("No bearer token");
    }
  }

  Future<PriceSahamMovementModel> getPriceMovement(String stockCode) async {
    // if empty then we try to get again the bearer token from user preferences
    if (_bearerToken.isEmpty) {
      getJwt();
    }

    // check if we have bearer token or not?
    if (_bearerToken.isNotEmpty) {
      final response = await http.get(
        Uri.parse('${Globals.apiURL}api/price-sahams/movement/code/$stockCode'),
        headers: {
          HttpHeaders.authorizationHeader: "Bearer $_bearerToken",
          'Content-Type': 'application/json',
        },
      );

      // check if we got 200 response or not?
      if (response.statusCode == 200) {
        // parse the response to get the data and process each one
        CommonSingleModel commonModel = CommonSingleModel.fromJson(jsonDecode(response.body));
        PriceSahamMovementModel priceMovement = PriceSahamMovementModel.fromJson(commonModel.data['attributes']);
        return priceMovement;
      }

      // status code is not 200, means we got error
      throw Exception(parseError(response.body).error.message);
    }
    else {
      throw Exception("No bearer token");
    }
  }
}