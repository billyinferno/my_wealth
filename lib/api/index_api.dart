import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:my_wealth/model/common_array_model.dart';
import 'package:my_wealth/model/index_model.dart';
import 'package:my_wealth/model/index_price_model.dart';
import 'package:my_wealth/utils/globals.dart';
import 'package:my_wealth/utils/prefs/shared_user.dart';

class IndexAPI {
  late String _bearerToken;

  IndexAPI() {
    // get the bearer token from user shared secured box
    _getJwt();
  }

  void _getJwt() {
    _bearerToken = UserSharedPreferences.getUserJWT();
  }

  Future<List<IndexModel>> getIndex() async {
    // if empty then we try to get again the bearer token from user preferences
    if (_bearerToken.isEmpty) {
      _getJwt();
    }

    // check if we have bearer token or not?
    if (_bearerToken.isNotEmpty) {
      final response = await http.get(
        Uri.parse(Globals.apiURL + 'api/indices'),
        headers: {
          HttpHeaders.authorizationHeader: "Bearer " + _bearerToken,
          'Content-Type': 'application/json',
        },
      );

      // check if we got 200 response or not?
      if (response.statusCode == 200) {
        // parse the response to get the data and process each one
        CommonArrayModel _commonModel = CommonArrayModel.fromJson(jsonDecode(response.body));
        List<IndexModel> _listIndex = [];
        for (var _data in _commonModel.data) {
          IndexModel _index = IndexModel.fromJson(_data['attributes']);
          _listIndex.add(_index);
        }
        return _listIndex;
      }

      // status code is not 200, means we got error
      throw Exception("err=" + response.body);
    }
    else {
      throw Exception("err=No bearer token");
    }
  }

  Future<List<IndexPriceModel>> getIndexPrice(int indexId) async {
    // if empty then we try to get again the bearer token from user preferences
    if (_bearerToken.isEmpty) {
      _getJwt();
    }

    // check if we have bearer token or not?
    if (_bearerToken.isNotEmpty) {
      final response = await http.get(
        Uri.parse(Globals.apiURL + 'api/indices-prices/' + indexId.toString()),
        headers: {
          HttpHeaders.authorizationHeader: "Bearer " + _bearerToken,
          'Content-Type': 'application/json',
        },
      );

      // check if we got 200 response or not?
      if (response.statusCode == 200) {
        // parse the response to get the data and process each one
        CommonArrayModel _commonModel = CommonArrayModel.fromJson(jsonDecode(response.body));
        List<IndexPriceModel> _listIndexPrice = [];
        for (var _data in _commonModel.data) {
          IndexPriceModel _indexPrice = IndexPriceModel.fromJson(_data['attributes']);
          _listIndexPrice.add(_indexPrice);
        }
        return _listIndexPrice;
      }

      // status code is not 200, means we got error
      throw Exception("err=" + response.body);
    }
    else {
      throw Exception("err=No bearer token");
    }
  }
}