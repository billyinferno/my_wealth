import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:my_wealth/model/common_array_model.dart';
import 'package:my_wealth/model/common_single_model.dart';
import 'package:my_wealth/model/watchlist_detail_list_model.dart';
import 'package:my_wealth/model/watchlist_list_model.dart';
import 'package:my_wealth/model/watchlist_performance_model.dart';
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

  Future<List<WatchlistListModel>> getWatchlist(String type) async {
    // if empty then we try to get again the bearer token from user preferences
    if (_bearerToken.isEmpty) {
      _getJwt();
    }

    // check if we have bearer token or not?
    if (_bearerToken.isNotEmpty) {
      final response = await http.get(
        Uri.parse('${Globals.apiURL}api/watchlists/$type'),
        headers: {
          HttpHeaders.authorizationHeader: "Bearer $_bearerToken",
          'Content-Type': 'application/json',
        },
      );

      // check if we got 200 response or not?
      if (response.statusCode == 200) {
        // parse the response to get the data and process each one
        CommonArrayModel commonModel = CommonArrayModel.fromJson(jsonDecode(response.body));
        List<WatchlistListModel> listWatchlist = [];
        for (var data in commonModel.data) {
          WatchlistListModel watchlist = WatchlistListModel.fromJson(data['attributes']);
          listWatchlist.add(watchlist);
        }
        return listWatchlist;
      }

      // status code is not 200, means we got error
      throw Exception(parseError(response.body).error.message);
    }
    else {
      throw Exception("No bearer token");
    }
  }

  Future<WatchlistListModel> findSpecific(String type, int id) async {
    // if empty then we try to get again the bearer token from user preferences
    if (_bearerToken.isEmpty) {
      _getJwt();
    }

    // check if we have bearer token or not?
    if (_bearerToken.isNotEmpty) {
      final response = await http.get(
        Uri.parse('${Globals.apiURL}api/watchlists/find/$type/id/$id'),
        headers: {
          HttpHeaders.authorizationHeader: "Bearer $_bearerToken",
          'Content-Type': 'application/json',
        },
      );

      // check if we got 200 response or not?
      if (response.statusCode == 200) {
        CommonSingleModel commonModel = CommonSingleModel.fromJson(jsonDecode(response.body));
        WatchlistListModel watchlist = WatchlistListModel.fromJson(commonModel.data['attributes']);
        return watchlist;
      }

      // status code is not 200, means we got error
      throw Exception(parseError(response.body).error.message);
    }
    else {
      throw Exception("No bearer token");
    }
  }

  Future<WatchlistListModel> add(String type, int companyId) async {
    // if empty then we try to get again the bearer token from user preferences
    if (_bearerToken.isEmpty) {
      _getJwt();
    }

    // check if we have bearer token or not?
    if (_bearerToken.isNotEmpty) {
      final response = await http.post(
        Uri.parse('${Globals.apiURL}api/watchlists'),
        headers: {
          HttpHeaders.authorizationHeader: "Bearer $_bearerToken",
          'Content-Type': 'application/json',
        },
        body: jsonEncode({'watchlist_company_id': companyId, 'watchlist_company_type': type}),
      );

      // check if we got 200 response or not?
      if (response.statusCode == 200) {
        // parse the response to get the data and process each one
        CommonSingleModel commonModel = CommonSingleModel.fromJson(jsonDecode(response.body));
        WatchlistListModel watchlist = WatchlistListModel.fromJson(commonModel.data['attributes']);
        return watchlist;
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
        Uri.parse('${Globals.apiURL}api/watchlists/$watchlistId'),
        headers: {
          HttpHeaders.authorizationHeader: "Bearer $_bearerToken",
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
        Uri.parse('${Globals.apiURL}api/watchlists-details'),
        headers: {
          HttpHeaders.authorizationHeader: "Bearer $_bearerToken",
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
        CommonArrayModel commonModel = CommonArrayModel.fromJson(jsonDecode(response.body));
        List<WatchlistDetailListModel> watchlistDetail = [];
        for (var data in commonModel.data) {
          WatchlistDetailListModel detail = WatchlistDetailListModel.fromJson(data['attributes']);
          watchlistDetail.add(detail);
        }
        return watchlistDetail;
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
        Uri.parse('${Globals.apiURL}api/watchlists-details/$id'),
        headers: {
          HttpHeaders.authorizationHeader: "Bearer $_bearerToken",
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
        Uri.parse('${Globals.apiURL}api/watchlists-details/$id'),
        headers: {
          HttpHeaders.authorizationHeader: "Bearer $_bearerToken",
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

  Future<List<WatchlistDetailListModel>> findDetail(int companyId) async {
    // if empty then we try to get again the bearer token from user preferences
    if (_bearerToken.isEmpty) {
      _getJwt();
    }

    // check if we have bearer token or not?
    if (_bearerToken.isNotEmpty) {
      final response = await http.get(
        Uri.parse('${Globals.apiURL}api/watchlists/detail/$companyId'),
        headers: {
          HttpHeaders.authorizationHeader: "Bearer $_bearerToken",
          'Content-Type': 'application/json',
        },
      );

      // check if we got 200 response or not?
      if (response.statusCode == 200) {
        // parse the response to get the data and process each one
        CommonArrayModel commonModel = CommonArrayModel.fromJson(jsonDecode(response.body));
        List<WatchlistDetailListModel> watchlistDetail = [];
        for (var data in commonModel.data) {
          WatchlistDetailListModel detail = WatchlistDetailListModel.fromJson(data['attributes']);
          watchlistDetail.add(detail);
        }
        return watchlistDetail;
      }

      // status code is not 200, means we got error
      throw Exception(parseError(response.body).error.message);
    }
    else {
      throw Exception("No bearer token");
    }
  }

  Future<List<WatchlistPerformanceModel>> getWatchlistPerformance(String type, int id) async {
    // if empty then we try to get again the bearer token from user preferences
    if (_bearerToken.isEmpty) {
      _getJwt();
    }

    // check if we have bearer token or not?
    if (_bearerToken.isNotEmpty) {
      final response = await http.get(
        Uri.parse('${Globals.apiURL}api/watchlists/performance/$type/$id'),
        headers: {
          HttpHeaders.authorizationHeader: "Bearer $_bearerToken",
          'Content-Type': 'application/json',
        },
      );

      // check if we got 200 response or not?
      if (response.statusCode == 200) {
        // parse the response to get the data and process each one
        CommonArrayModel commonModel = CommonArrayModel.fromJson(jsonDecode(response.body));
        List<WatchlistPerformanceModel> listWatchlistPerformance = [];
        for (var data in commonModel.data) {
          WatchlistPerformanceModel watchlist = WatchlistPerformanceModel.fromJson(data['attributes']);
          listWatchlistPerformance.add(watchlist);
        }
        return listWatchlistPerformance;
      }

      // status code is not 200, means we got error
      throw Exception(parseError(response.body).error.message);
    }
    else {
      throw Exception("No bearer token");
    }
  }
}