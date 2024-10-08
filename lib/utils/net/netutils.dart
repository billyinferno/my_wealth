import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:my_wealth/_index.g.dart';

class NetUtils {
  static String? bearerToken;

  /// refreshJWT
  /// Refresh current JWT token with the one stored on the Encrypted Box under
  /// User Shared Preferences.
  static void refreshJWT() {
    bearerToken = UserSharedPreferences.getUserJWT();
  }

  /// clearJWT
  /// Clear current JWT Token and set it as NULL
  static void clearJWT() {
    bearerToken = null;
  }

  /// get
  /// This is to sending GET request to the API Server
  /// Parameter needed for this are:
  /// - required : url         : String
  /// - optional : params      : Map\<String, dynamic\>
  static Future get({
    required String url,
    Map<String, dynamic>? params
  }) async {
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
    try {
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
      ).onError((error, stackTrace) {
        Log.error(
          message: 'Generic exception error',
          error: error,
          stackTrace: stackTrace,
        );

        throw NetException(
          code: -2,
          type: NetType.get,
          message: '[Exception] ${error.toString()}',
        );
      },);

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
    on http.ClientException catch(error, stackTrace) {
      Log.error(
        message: 'Client exception error',
        error: error,
        stackTrace: stackTrace,
      );

      throw NetException(
        code: -1,
        type: NetType.get,
        message: '[ClientException] ${error.toString()}',
      );
    }
    catch (_) {
      rethrow;
    }
  }

  /// post
  /// This is to sending POST request to the API Server
  /// Parameter needed for this are:
  /// - required : url         : String
  /// - optional : params      : Map\<String, dynamic\>
  /// - required : body        : Map\<String, dynamic\>
  /// - optional : requiredJWT : bool
  static Future post({
    required String url,
    Map<String, dynamic>? params,
    required Map<String, dynamic> body,
    bool? requiredJWT
  }) async {
    // check the JWT requirement
    bool isRequiredJWT = (requiredJWT ?? true);
    
    // default the headers value as empty
    Map<String, String> headers = {};

    // check if we need JWT on the request or not?
    if (isRequiredJWT) {
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

      // set the headers with bearer token
      headers = {
        HttpHeaders.authorizationHeader: "Bearer $bearerToken",
        'Content-Type': 'application/json',
      };
    }
    else {
      // set the headers with content type only
      headers = {
        'Content-Type': 'application/json',
      };
    }

    // generate the additional params
    var uri = Uri.parse(url);
    if (params != null) {
      uri = uri.replace(queryParameters: params);
    }

    try {
      // bearer token is not empty, we can perform call to the API
      final response = await http.post(
        uri,
        headers: headers,
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
      ).onError((error, stackTrace) {
        Log.error(
          message: 'Generic exception error',
          error: error,
          stackTrace: stackTrace,
        );

        throw NetException(
          code: -2,
          type: NetType.post,
          message: '[Exception] ${error.toString()}',
        );
      },);

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
    on http.ClientException catch(error, stackTrace) {
      Log.error(
        message: 'Client exception error',
        error: error,
        stackTrace: stackTrace,
      );

      throw NetException(
        code: -1,
        type: NetType.post,
        message: '[ClientException] ${error.toString()}',
      );
    }
    catch (_) {
      rethrow;
    }
  }

  /// delete
  /// This is to sending DELETE request to the API Server
  /// Parameter needed for this are:
  /// - required : url         : String
  /// - optional : params      : Map\<String, dynamic\>
  static Future delete({
    required String url,
    Map<String, dynamic>? params
  }) async {
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

    try {
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
      ).onError((error, stackTrace) {
        Log.error(
          message: 'Generic exception error',
          error: error,
          stackTrace: stackTrace,
        );

        throw NetException(
          code: -2,
          type: NetType.delete,
          message: '[Exception] ${error.toString()}',
        );
      },);

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
    on http.ClientException catch(error, stackTrace) {
      Log.error(
        message: 'Client exception error',
        error: error,
        stackTrace: stackTrace,
      );

      throw NetException(
        code: -1,
        type: NetType.delete,
        message: '[ClientException] ${error.toString()}',
      );
    }
    catch (_) {
      rethrow;
    }
  }

  /// patch
  /// This is to sending PATCH request to the API Server
  /// Parameter needed for this are:
  /// - required : url         : String
  /// - optional : params      : Map\<String, dynamic\>
  /// - required : body        : Map\<String, dynamic\>
  static Future patch({
    required String url,
    Map<String, dynamic>? params,
    required Map<String, dynamic> body
  }) async {
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

    try {
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
      ).onError((error, stackTrace) {
        Log.error(
          message: 'Generic exception error',
          error: error,
          stackTrace: stackTrace,
        );

        throw NetException(
          code: -2,
          type: NetType.patch,
          message: '[Exception] ${error.toString()}',
        );
      },);

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
    on http.ClientException catch(error, stackTrace) {
      Log.error(
        message: 'Client exception error',
        error: error,
        stackTrace: stackTrace,
      );

      throw NetException(
        code: -1,
        type: NetType.patch,
        message: '[ClientException] ${error.toString()}',
      );
    }
    catch (_) {
      rethrow;
    }
  }

  /// put
  /// This is to sending PUT request to the API Server
  /// Parameter needed for this are:
  /// - required : url         : String
  /// - optional : params      : Map\<String, dynamic\>
  /// - required : body        : Map\<String, dynamic\>
  static Future put({
    required String url,
    Map<String, dynamic>? params,
    required Map<String, dynamic> body
  }) async {
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

    try {
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
      ).onError((error, stackTrace) {
        Log.error(
          message: 'Generic exception error',
          error: error,
          stackTrace: stackTrace,
        );

        throw NetException(
          code: -2,
          type: NetType.put,
          message: '[Exception] ${error.toString()}',
        );
      },);

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
    on http.ClientException catch(error, stackTrace) {
      Log.error(
        message: 'Client exception error',
        error: error,
        stackTrace: stackTrace,
      );

      throw NetException(
        code: -1,
        type: NetType.put,
        message: '[ClientException] ${error.toString()}',
      );
    }
    catch (_) {
      rethrow;
    }
  }
}