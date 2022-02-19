import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:my_wealth/model/user_login.dart';
import 'package:my_wealth/utils/globals.dart';
import 'package:my_wealth/utils/prefs/shared_user.dart';

class UserAPI {
  late String _bearerToken;

  UserAPI() {
    // get the bearer token from user shared secured box
    _getJwt();
  }

  _getJwt() {
    _bearerToken = UserSharedPreferences.getUserJWT();
  }

  Future<UserLoginModel> login(String username, String password) async {
    final response = await http.post(
      Uri.parse(Globals.apiURL + 'api/auth/local'),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({'identifier': username, 'password': password}),
    );

    // check if we got 200 response or not?
    if (response.statusCode == 200) {
      // parse the response and put on user login model
      UserLoginModel _userLogin = UserLoginModel.fromJson(jsonDecode(response.body));
      return _userLogin;
    }

    // status code is not 200, means we got error
    throw Exception("err=" + response.body);
  }

  Future<UserLoginInfoModel> me() async {
    // if empty then we try to get again the bearer token from user preferences
    if (_bearerToken.isEmpty) {
      _bearerToken = UserSharedPreferences.getUserJWT();
    }

    // check if we have bearer token or not?
    if (_bearerToken.isNotEmpty) {
      final response = await http.get(
        Uri.parse(Globals.apiURL + 'api/users/me'),
        headers: {
          HttpHeaders.authorizationHeader: "Bearer " + _bearerToken,
          'Content-Type': 'application/json',
        },
      );

      // check if we got 200 response or not?
      if (response.statusCode == 200) {
        // parse the response and put on user login model
        UserLoginInfoModel _userInfo = UserLoginInfoModel.fromJson(jsonDecode(response.body));
        return _userInfo;
      }

      // status code is not 200, means we got error
      throw Exception("err=" + response.body);
    }
    else {
      throw Exception("err=No bearer token");
    }
  }

  Future<UserLoginInfoModel> updateRisk(int risk) async {
    // if empty then we try to get again the bearer token from user preferences
    if (_bearerToken.isEmpty) {
      _bearerToken = UserSharedPreferences.getUserJWT();
    }
    
    // check if we have bearer token or not?
    if (_bearerToken.isNotEmpty) {
      final response = await http.patch(
        Uri.parse(Globals.apiURL + 'api/risk'),
        headers: {
          HttpHeaders.authorizationHeader: "Bearer " + _bearerToken,
          'Content-Type': 'application/json',
        },
        body: jsonEncode({'risk': risk}),
      );

      // check if we got 200 response or not?
      if (response.statusCode == 200) {
        // parse the response and put on user login model
        UserLoginInfoModel _userInfo = UserLoginInfoModel.fromJson(jsonDecode(response.body));
        return _userInfo;
      }

      // status code is not 200, means we got error
      throw Exception("err=" + response.body);
    }
    else {
      throw Exception("err=No bearer token");
    }
  }

  Future<UserLoginInfoModel> updateVisibilitySummary(bool visibility) async {
    // if empty then we try to get again the bearer token from user preferences
    if (_bearerToken.isEmpty) {
      _bearerToken = UserSharedPreferences.getUserJWT();
    }
    
    // check if we have bearer token or not?
    if (_bearerToken.isNotEmpty) {
      final response = await http.patch(
        Uri.parse(Globals.apiURL + 'api/visibility/summary'),
        headers: {
          HttpHeaders.authorizationHeader: "Bearer " + _bearerToken,
          'Content-Type': 'application/json',
        },
        body: jsonEncode({'visibility': visibility}),
      );

      // check if we got 200 response or not?
      if (response.statusCode == 200) {
        // parse the response and put on user login model
        UserLoginInfoModel _userInfo = UserLoginInfoModel.fromJson(jsonDecode(response.body));
        return _userInfo;
      }

      // status code is not 200, means we got error
      throw Exception("err=" + response.body);
    }
    else {
      throw Exception("err=No bearer token");
    }
  }
}