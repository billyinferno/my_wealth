import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:my_wealth/storage/prefs/shared_user.dart';
import 'package:my_wealth/utils/function/parse_error.dart';
import 'package:my_wealth/utils/globals.dart';

class NetUtils {
  static String? bearerToken;

  static void refreshJWT() {
    bearerToken = UserSharedPreferences.getUserJWT();
  }

  static Future get({required String url, Map<String, dynamic>? params}) async {
    // check if bearer token is null? if null then get from UserSharedPreferences
    bearerToken ??= UserSharedPreferences.getUserJWT();

    // check to ensure it's not empty
    if (bearerToken == null) {
      throw Exception('Bearer Token Empty');
    }

    // generate the additional params
    var uri = Uri.parse(url);
    if (params != null) {
      uri = uri.replace(queryParameters: params);
    }

    // bearer token is not empty, we can perform call to the API
    final response = await http.get(
      uri,
      headers: {
        HttpHeaders.authorizationHeader: "Bearer $bearerToken",
        'Content-Type': 'application/json',
      },
    ).timeout(
      Duration(seconds: Globals.apiTimeOut),
      onTimeout: () {
        throw Exception('Timeout When Get $url');
      },
    );

    // check the response we got from http
    if (response.statusCode == 200) {
      return response.body;
    }

    // status code is not 200, means we got error
    throw Exception(parseError(response.body).error.message); 
  }

  static Future post({required String url, Map<String, dynamic>? params, required Map<String, dynamic> body}) async {
    // check if bearer token is null? if null then get from UserSharedPreferences
    bearerToken ??= UserSharedPreferences.getUserJWT();

    // check to ensure it's not empty
    if (bearerToken == null) {
      throw Exception('Bearer Token Empty');
    }

    // generate the additional params
    var uri = Uri.parse(url);
    if (params != null) {
      uri = uri.replace(queryParameters: params);
    }

    // bearer token is not empty, we can perform call to the API
    final response = await http.post(
      uri,
      headers: {
        HttpHeaders.authorizationHeader: "Bearer $bearerToken",
        'Content-Type': 'application/json',
      },
      body: jsonEncode(body)
    ).timeout(
      Duration(seconds: Globals.apiTimeOut),
      onTimeout: () {
        throw Exception('Timeout When Post $url');
      },
    );

    // check the response we got from http
    if (response.statusCode == 200) {
      return response.body;
    }

    // status code is not 200, means we got error
    throw Exception(parseError(response.body).error.message); 
  }

  static Future delete({required String url, Map<String, dynamic>? params}) async {
    // check if bearer token is null? if null then get from UserSharedPreferences
    bearerToken ??= UserSharedPreferences.getUserJWT();

    // check to ensure it's not empty
    if (bearerToken == null) {
      throw Exception('Bearer Token Empty');
    }

    // generate the additional params
    var uri = Uri.parse(url);
    if (params != null) {
      uri = uri.replace(queryParameters: params);
    }

    // bearer token is not empty, we can perform call to the API
    final response = await http.delete(
      uri,
      headers: {
        HttpHeaders.authorizationHeader: "Bearer $bearerToken",
        'Content-Type': 'application/json',
      },
    ).timeout(
      Duration(seconds: Globals.apiTimeOut),
      onTimeout: () {
        throw Exception('Timeout When Delete $url');
      },
    );

    // check the response we got from http
    if (response.statusCode == 200) {
      return response.body;
    }

    // status code is not 200, means we got error
    throw Exception(parseError(response.body).error.message); 
  }

  static Future patch({required String url, Map<String, dynamic>? params, required Map<String, dynamic> body}) async {
    // check if bearer token is null? if null then get from UserSharedPreferences
    bearerToken ??= UserSharedPreferences.getUserJWT();

    // check to ensure it's not empty
    if (bearerToken == null) {
      throw Exception('Bearer Token Empty');
    }

    // generate the additional params
    var uri = Uri.parse(url);
    if (params != null) {
      uri = uri.replace(queryParameters: params);
    }

    // bearer token is not empty, we can perform call to the API
    final response = await http.patch(
      uri,
      headers: {
        HttpHeaders.authorizationHeader: "Bearer $bearerToken",
        'Content-Type': 'application/json',
      },
      body: jsonEncode(body)
    ).timeout(
      Duration(seconds: Globals.apiTimeOut),
      onTimeout: () {
        throw Exception('Timeout When Patch $url');
      },
    );

    // check the response we got from http
    if (response.statusCode == 200) {
      return response.body;
    }

    // status code is not 200, means we got error
    throw Exception(parseError(response.body).error.message); 
  }

  static Future put({required String url, Map<String, dynamic>? params, required Map<String, dynamic> body}) async {
    // check if bearer token is null? if null then get from UserSharedPreferences
    bearerToken ??= UserSharedPreferences.getUserJWT();

    // check to ensure it's not empty
    if (bearerToken == null) {
      throw Exception('Bearer Token Empty');
    }

    // generate the additional params
    var uri = Uri.parse(url);
    if (params != null) {
      uri = uri.replace(queryParameters: params);
    }

    // bearer token is not empty, we can perform call to the API
    final response = await http.put(
      uri,
      headers: {
        HttpHeaders.authorizationHeader: "Bearer $bearerToken",
        'Content-Type': 'application/json',
      },
      body: jsonEncode(body)
    ).timeout(
      Duration(seconds: Globals.apiTimeOut),
      onTimeout: () {
        throw Exception('Timeout When Patch $url');
      },
    );

    // check the response we got from http
    if (response.statusCode == 200) {
      return response.body;
    }

    // status code is not 200, means we got error
    throw Exception(parseError(response.body).error.message); 
  }
}