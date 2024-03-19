import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:my_wealth/model/common/error_model.dart';
import 'package:my_wealth/storage/prefs/shared_user.dart';
import 'package:my_wealth/utils/function/parse_error.dart';
import 'package:my_wealth/utils/globals.dart';

enum NetType {
  initialize,
  get,
  put,
  patch,
  post,
  delete
}

class NetException {
  final int code;
  final NetType type;
  final String message;
  final String? body;

  const NetException({required this.code, required this.type, required this.message, this.body});

  @override
  String toString() {
    return '[$type][$code] $message';
  }

  ErrorModel? error() {
    // check if body is not null
    if (body != null) {
      return parseError(body!);
    }

    // return null if body is null
    return null;
  }
}

class NetUtils {
  static String? bearerToken;

  static void refreshJWT() {
    bearerToken = UserSharedPreferences.getUserJWT();
  }

  static void clearJWT() {
    bearerToken = null;
  }

  static Future get({required String url, Map<String, dynamic>? params}) async {
    // check if bearer token is null? if null then get from UserSharedPreferences
    bearerToken ??= UserSharedPreferences.getUserJWT();

    // check to ensure it's not empty
    if (bearerToken == null) {
      throw const NetException(
        code: 403,
        type: NetType.initialize,
        message: "Bearer token empty"
      );
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
        throw NetException(
          code: 504,
          type: NetType.get,
          message: 'Gateway Timeout for $url'
        );
      },
    );

    // check the response we got from http
    if (response.statusCode == 200) {
      return response.body;
    }

    // status code is not 200, means we got error
    throw NetException(
      code: response.statusCode,
      type: NetType.get,
      message: response.reasonPhrase ?? '',
      body: response.body,
    );
  }

  static Future post({required String url, Map<String, dynamic>? params, required Map<String, dynamic> body}) async {
    // check if bearer token is null? if null then get from UserSharedPreferences
    bearerToken ??= UserSharedPreferences.getUserJWT();

    // check to ensure it's not empty
    if (bearerToken == null) {
      throw const NetException(
        code: 403,
        type: NetType.initialize,
        message: "Bearer token empty"
      );
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
        throw NetException(
          code: 504,
          type: NetType.post,
          message: 'Gateway Timeout for $url'
        );
      },
    );

    // check the response we got from http
    if (response.statusCode == 200) {
      return response.body;
    }

    // status code is not 200, means we got error
    throw NetException(
      code: response.statusCode,
      type: NetType.post,
      message: response.reasonPhrase ?? '',
      body: response.body,
    );
  }

  static Future delete({required String url, Map<String, dynamic>? params}) async {
    // check if bearer token is null? if null then get from UserSharedPreferences
    bearerToken ??= UserSharedPreferences.getUserJWT();

    // check to ensure it's not empty
    if (bearerToken == null) {
      throw const NetException(
        code: 403,
        type: NetType.initialize,
        message: "Bearer token empty"
      );
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
        throw NetException(
          code: 504,
          type: NetType.delete,
          message: 'Gateway Timeout for $url'
        );
      },
    );

    // check the response we got from http
    if (response.statusCode == 200) {
      return response.body;
    }

    // status code is not 200, means we got error
    throw NetException(
      code: response.statusCode,
      type: NetType.delete,
      message: response.reasonPhrase ?? '',
      body: response.body,
    );
  }

  static Future patch({required String url, Map<String, dynamic>? params, required Map<String, dynamic> body}) async {
    // check if bearer token is null? if null then get from UserSharedPreferences
    bearerToken ??= UserSharedPreferences.getUserJWT();

    // check to ensure it's not empty
    if (bearerToken == null) {
      throw const NetException(
        code: 403,
        type: NetType.initialize,
        message: "Bearer token empty"
      );
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
        throw NetException(
          code: 504,
          type: NetType.patch,
          message: 'Gateway Timeout for $url'
        );
      },
    );

    // check the response we got from http
    if (response.statusCode == 200) {
      return response.body;
    }

    // status code is not 200, means we got error
    throw NetException(
      code: response.statusCode,
      type: NetType.patch,
      message: response.reasonPhrase ?? '',
      body: response.body,
    );
  }

  static Future put({required String url, Map<String, dynamic>? params, required Map<String, dynamic> body}) async {
    // check if bearer token is null? if null then get from UserSharedPreferences
    bearerToken ??= UserSharedPreferences.getUserJWT();

    // check to ensure it's not empty
    if (bearerToken == null) {
      throw const NetException(
        code: 403,
        type: NetType.initialize,
        message: "Bearer token empty"
      );
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
        throw NetException(
          code: 504,
          type: NetType.put,
          message: 'Gateway Timeout for $url'
        );
      },
    );

    // check the response we got from http
    if (response.statusCode == 200) {
      return response.body;
    }

    // status code is not 200, means we got error
    throw NetException(
      code: response.statusCode,
      type: NetType.put,
      message: response.reasonPhrase ?? '',
      body: response.body,
    );
  }
}