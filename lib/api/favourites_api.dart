import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:my_wealth/model/common_array_model.dart';
import 'package:my_wealth/model/common_single_model.dart';
import 'package:my_wealth/model/favourites_list_model.dart';
import 'package:my_wealth/model/favourites_model.dart';
import 'package:my_wealth/utils/function/parse_error.dart';
import 'package:my_wealth/utils/globals.dart';
import 'package:my_wealth/utils/prefs/shared_user.dart';

class FavouritesAPI {
  late String _bearerToken;

  FavouritesAPI() {
    // get the bearer token from user shared secured box
    _getJwt();
  }

  void _getJwt() {
    _bearerToken = UserSharedPreferences.getUserJWT();
  }

  Future<List<FavouritesModel>> getFavourites() async {
    // if empty then we try to get again the bearer token from user preferences
    if (_bearerToken.isEmpty) {
      _getJwt();
    }

    // check if we have bearer token or not?
    if (_bearerToken.isNotEmpty) {
      final response = await http.get(
        Uri.parse(Globals.apiURL + 'api/favourites'),
        headers: {
          HttpHeaders.authorizationHeader: "Bearer " + _bearerToken,
          'Content-Type': 'application/json',
        },
      );

      // check if we got 200 response or not?
      if (response.statusCode == 200) {
        // parse the response to get the data and process each one
        CommonArrayModel _commonModel = CommonArrayModel.fromJson(jsonDecode(response.body));
        List<FavouritesModel> _listFavourites = [];
        for (var _data in _commonModel.data) {
          FavouritesModel _fave = FavouritesModel.fromJson(_data['attributes']);
          _listFavourites.add(_fave);
        }
        return _listFavourites;
      }

      // status code is not 200, means we got error
      throw Exception(parseError(response.body).error.message);
    }
    else {
      throw Exception("No bearer token");
    }
  }

  Future<List<FavouritesListModel>> listFavouritesCompanies() async {
    // if empty then we try to get again the bearer token from user preferences
    if (_bearerToken.isEmpty) {
      _getJwt();
    }

    // check if we have bearer token or not?
    if (_bearerToken.isNotEmpty) {
      final response = await http.get(
        Uri.parse(Globals.apiURL + 'api/favourites/list'),
        headers: {
          HttpHeaders.authorizationHeader: "Bearer " + _bearerToken,
          'Content-Type': 'application/json',
        },
      );

      // check if we got 200 response or not?
      if (response.statusCode == 200) {
        // parse the response to get the data and process each one
        CommonArrayModel _commonModel = CommonArrayModel.fromJson(jsonDecode(response.body));
        List<FavouritesListModel> _listFavourites = [];
        for (var _data in _commonModel.data) {
          // print(_data['attributes'].toString());
          FavouritesListModel _fave = FavouritesListModel.fromJson(_data['attributes']);
          _listFavourites.add(_fave);
        }
        return _listFavourites;
      }

      // status code is not 200, means we got error
      throw Exception(parseError(response.body).error.message);
    }
    else {
      throw Exception("No bearer token");
    }
  }

  Future<FavouritesListModel> add(int companyId) async {
    // if empty then we try to get again the bearer token from user preferences
    if (_bearerToken.isEmpty) {
      _getJwt();
    }

    // check if we have bearer token or not?
    if (_bearerToken.isNotEmpty) {
      final response = await http.post(
        Uri.parse(Globals.apiURL + 'api/favourites'),
        headers: {
          HttpHeaders.authorizationHeader: "Bearer " + _bearerToken,
          'Content-Type': 'application/json',
        },
        body: jsonEncode({'favourites_company_id': companyId}),
      );

      // check if we got 200 response or not?
      if (response.statusCode == 200) {
        // parse the response to get the data and process each one
        CommonSingleModel _commonModel = CommonSingleModel.fromJson(jsonDecode(response.body));
        FavouritesListModel _userFave = FavouritesListModel.fromJson(_commonModel.data['attributes']);
        return _userFave;
      }

      // status code is not 200, means we got error
      throw Exception(parseError(response.body).error.message);
    }
    else {
      throw Exception("No bearer token");
    }
  }

  Future<void> delete(int favouriteId) async {
    // if empty then we try to get again the bearer token from user preferences
    if (_bearerToken.isEmpty) {
      _bearerToken = UserSharedPreferences.getUserJWT();
    }

    // check if we have bearer token or not?
    if (_bearerToken.isNotEmpty) {
      final response = await http.delete(
        Uri.parse(Globals.apiURL + 'api/favourites/' + favouriteId.toString()),
        headers: {
          HttpHeaders.authorizationHeader: "Bearer " + _bearerToken,
          'Content-Type': 'application/json',
        },
      );

      // check if we got 200 response or not?
      if (response.statusCode == 200) {
        // no need to response the data returned by delete
        return;
      }

      // status code is not 200, means we got error
      throw Exception(parseError(response.body).error.message);
    }
    else {
      throw Exception("No bearer token");
    }
  }
}