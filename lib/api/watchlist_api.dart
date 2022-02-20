import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:my_wealth/model/common_array_model.dart';
import 'package:my_wealth/model/common_single_model.dart';
import 'package:my_wealth/model/watchlist_detail_list_model.dart';
import 'package:my_wealth/model/watchlist_list_model.dart';
import 'package:my_wealth/utils/function/parse_error.dart';
import 'package:my_wealth/utils/globals.dart';
import 'package:my_wealth/utils/prefs/shared_user.dart';

class WatchlistAPI {
  late String _bearerToken;

  WatchlistAPI() {
    // get the bearer token from user shared secured box
    _getJwt();
  }

  void _getJwt() {
    _bearerToken = UserSharedPreferences.getUserJWT();
  }

  Future<List<WatchlistListModel>> getWatchlist() async {
    // if empty then we try to get again the bearer token from user preferences
    if (_bearerToken.isEmpty) {
      _getJwt();
    }

    // check if we have bearer token or not?
    if (_bearerToken.isNotEmpty) {
      final response = await http.get(
        Uri.parse(Globals.apiURL + 'api/watchlists'),
        headers: {
          HttpHeaders.authorizationHeader: "Bearer " + _bearerToken,
          'Content-Type': 'application/json',
        },
      );

      // check if we got 200 response or not?
      if (response.statusCode == 200) {
        // parse the response to get the data and process each one
        CommonArrayModel _commonModel = CommonArrayModel.fromJson(jsonDecode(response.body));
        List<WatchlistListModel> _listWatchlist = [];
        for (var _data in _commonModel.data) {
          WatchlistListModel _watchlist = WatchlistListModel.fromJson(_data['attributes']);
          _listWatchlist.add(_watchlist);
        }
        return _listWatchlist;
      }

      // status code is not 200, means we got error
      throw Exception(parseError(response.body).error.message);
    }
    else {
      throw Exception("No bearer token");
    }
  }

  Future<WatchlistListModel> add(int companyId) async {
    // if empty then we try to get again the bearer token from user preferences
    if (_bearerToken.isEmpty) {
      _getJwt();
    }

    // check if we have bearer token or not?
    if (_bearerToken.isNotEmpty) {
      final response = await http.post(
        Uri.parse(Globals.apiURL + 'api/watchlists'),
        headers: {
          HttpHeaders.authorizationHeader: "Bearer " + _bearerToken,
          'Content-Type': 'application/json',
        },
        body: jsonEncode({'watchlist_company_id': companyId}),
      );

      // check if we got 200 response or not?
      if (response.statusCode == 200) {
        // parse the response to get the data and process each one
        CommonSingleModel _commonModel = CommonSingleModel.fromJson(jsonDecode(response.body));
        WatchlistListModel _watchlist = WatchlistListModel.fromJson(_commonModel.data['attributes']);
        return _watchlist;
      }

      // status code is not 200, means we got error
      throw Exception(parseError(response.body).error.message);
    }
    else {
      throw Exception("No bearer token");
    }
  }

  Future<bool> delete(int watchlistId) async {
    // if empty then we try to get again the bearer token from user preferences
    if (_bearerToken.isEmpty) {
      _getJwt();
    }

    // check if we have bearer token or not?
    if (_bearerToken.isNotEmpty) {
      final response = await http.delete(
        Uri.parse(Globals.apiURL + 'api/watchlists/' + watchlistId.toString()),
        headers: {
          HttpHeaders.authorizationHeader: "Bearer " + _bearerToken,
          'Content-Type': 'application/json',
        },
      );

      // check if we got 200 response or not?
      if (response.statusCode == 200) {
        // as long as we got 200 it means that we already able to delete the watchlist
        // so just return true.
        return true;
      }

      // status code is not 200, means we got error
      throw Exception(parseError(response.body).error.message);
    }
    else {
      throw Exception("No bearer token");
    }
  }

  Future<List<WatchlistDetailListModel>> addDetail(int id, DateTime date, double shares, double price) async {
    // if empty then we try to get again the bearer token from user preferences
    if (_bearerToken.isEmpty) {
      _getJwt();
    }

    // check if we have bearer token or not?
    if (_bearerToken.isNotEmpty) {
      final response = await http.post(
        Uri.parse(Globals.apiURL + 'api/watchlists-details'),
        headers: {
          HttpHeaders.authorizationHeader: "Bearer " + _bearerToken,
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'watchlist_detail_share': shares,
          'watchlist_detail_price': price,
          'watchlist_detail_date': date.toUtc().toIso8601String(),
          'watchlist_detail_watchlist_id': id
        }),
      );

      // check if we got 200 response or not?
      if (response.statusCode == 200) {
        // parse the response to get the data and process each one
        CommonArrayModel _commonModel = CommonArrayModel.fromJson(jsonDecode(response.body));
        List<WatchlistDetailListModel> _watchlistDetail = [];
        for (var _data in _commonModel.data) {
          WatchlistDetailListModel _detail = WatchlistDetailListModel.fromJson(_data['attributes']);
          _watchlistDetail.add(_detail);
        }
        return _watchlistDetail;
      }

      // status code is not 200, means we got error
      throw Exception(parseError(response.body).error.message);
    }
    else {
      throw Exception("No bearer token");
    }
  }

  Future<bool> deleteDetail(int id) async {
    // if empty then we try to get again the bearer token from user preferences
    if (_bearerToken.isEmpty) {
      _getJwt();
    }

    // check if we have bearer token or not?
    if (_bearerToken.isNotEmpty) {
      final response = await http.delete(
        Uri.parse(Globals.apiURL + 'api/watchlists-details/' + id.toString()),
        headers: {
          HttpHeaders.authorizationHeader: "Bearer " + _bearerToken,
          'Content-Type': 'application/json',
        },
      );

      // check if we got 200 response or not?
      if (response.statusCode == 200) {
        // no need to parse the result, as this only will response the ID that being deleted
        // and we already knew the ID that we need to delete form the caller since it will
        // need to passed it as parameter to here
        return true;
      }

      // status code is not 200, means we got error
      throw Exception(parseError(response.body).error.message);
    }
    else {
      throw Exception("No bearer token");
    }
  }

  Future<bool> updateDetail(int id, DateTime date, double shares, double price) async {
    // if empty then we try to get again the bearer token from user preferences
    if (_bearerToken.isEmpty) {
      _getJwt();
    }

    // check if we have bearer token or not?
    if (_bearerToken.isNotEmpty) {
      final response = await http.put(
        Uri.parse(Globals.apiURL + 'api/watchlists-details/' + id.toString()),
        headers: {
          HttpHeaders.authorizationHeader: "Bearer " + _bearerToken,
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'watchlist_detail_share': shares,
          'watchlist_detail_price': price,
          'watchlist_detail_date': date.toUtc().toIso8601String()
        }),
      );

      // check if we got 200 response or not?
      if (response.statusCode == 200) {
        // no need to return the result from the API, as it will only return the
        // last ID that we updated. So, just return true if all is good
        return true;
      }

      // status code is not 200, means we got error
      throw Exception(parseError(response.body).error.message);
    }
    else {
      throw Exception("No bearer token");
    }
  }
}