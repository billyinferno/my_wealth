import 'dart:convert';
import 'package:my_wealth/_index.g.dart';

class UserAPI {
  Future<UserLoginModel> login({
    required String username,
    required String password
  }) async {
    // post login information using netutils
    final String body = await NetUtils.post(
      url: Globals.apiAuthLocal,
      body: {'identifier': username, 'password': password},
      requiredJWT: false,
    ).onError((error, stackTrace) {
      Log.error(
        message: 'Error on login',
        error: error,
        stackTrace: stackTrace,
      );
      throw error as NetException;
    });

    // parse the response and put on user login model
    UserLoginModel userLogin = UserLoginModel.fromJson(jsonDecode(body));
    return userLogin;
  }

  Future<UserLoginInfoModel> me() async {
    // get user information data using netutils
    final String body = await NetUtils.get(
      url: '${Globals.apiUsers}/me'
    ).onError((error, stackTrace) {
      Log.error(
        message: 'Error on me',
        error: error,
        stackTrace: stackTrace,
      );
      throw error as NetException;
    });

    // parse the response and put on user login model
    UserLoginInfoModel userInfo = UserLoginInfoModel.fromJson(jsonDecode(body));
    return userInfo;
  }

  Future<UserLoginInfoModel> updateRisk({required int risk}) async {
    // patch user risk information using netutils
    final String body = await NetUtils.patch(
      url: Globals.apiRisk,
      body: {'risk': risk},
    ).onError((error, stackTrace) {
      Log.error(
        message: 'Error on updateRisk',
        error: error,
        stackTrace: stackTrace,
      );
      throw error as NetException;
    });

    // parse the response and put on user login model
    UserLoginInfoModel userInfo = UserLoginInfoModel.fromJson(jsonDecode(body));
    return userInfo;
  }

  Future<UserLoginInfoModel> updateVisibilitySummary({
    required bool visibility
  }) async {
    // patch user visibility using netutils
    final String body = await NetUtils.patch(
      url: '${Globals.apiVisibility}/summary',
      body: {'visibility': visibility},
    ).onError((error, stackTrace) {
      Log.error(
        message: 'Error on updateVisibilitySummary',
        error: error,
        stackTrace: stackTrace,
      );
      throw error as NetException;
    });

    // parse the response and put on user login model
    UserLoginInfoModel userInfo = UserLoginInfoModel.fromJson(jsonDecode(body));
    return userInfo;
  }

  Future<UserLoginInfoModel> updateShowLots({
    required bool showLots
  }) async {
    // patch user show lots using netutils
    final String body = await NetUtils.patch(
      url: '${Globals.apiVisibility}/lots',
      body: {'show_lots': showLots},
    ).onError((error, stackTrace) {
      Log.error(
        message: 'Error on updateShowLots',
        error: error,
        stackTrace: stackTrace,
      );
      throw error as NetException;
    });

    // parse the response and put on user login model
    UserLoginInfoModel userInfo = UserLoginInfoModel.fromJson(jsonDecode(body));
    return userInfo;
  }

  Future<UserLoginInfoModel> updateShowEmptyWatchlist({
    required bool showEmptyWatchlist
  }) async {
    // patch user show lots using netutils
    final String body = await NetUtils.patch(
      url: '${Globals.apiVisibility}/emptywatchlist',
      body: {'show_empty_watchlist': showEmptyWatchlist},
    ).onError((error, stackTrace) {
      Log.error(
        message: 'Error on updateShowEmptyWatchlist',
        error: error,
        stackTrace: stackTrace,
      );
      throw error as NetException;
    });

    // parse the response and put on user login model
    UserLoginInfoModel userInfo = UserLoginInfoModel.fromJson(jsonDecode(body));
    return userInfo;
  }

  Future<UserLoginInfoModel> updatePassword({
    required String password,
    required String newPassword
  }) async {
    // patch user password lots using netutils
    final String body = await NetUtils.patch(
      url: Globals.apiPassword,
      body: {
        'password': password,
        'newPassword': newPassword
      },
    ).onError((error, stackTrace) {
      Log.error(
        message: 'Error on updatePassword',
        error: error,
        stackTrace: stackTrace,
      );
      throw error as NetException;
    });

    // parse the response and put on user login model
    UserLoginInfoModel userInfo = UserLoginInfoModel.fromJson(jsonDecode(body));
    return userInfo;
  }

  Future<UserLoginInfoModel> updateBotToken({required String bot}) async {
    // patch user bot token lots using netutils
    final String body = await NetUtils.post(
      url: Globals.apiBot,
      body: {'bot': bot},
    ).onError((error, stackTrace) {
      Log.error(
        message: 'Error on updateBotToken',
        error: error,
        stackTrace: stackTrace,
      );
      throw error as NetException;
    });

    // parse the response and put on user login model
    UserLoginInfoModel userInfo = UserLoginInfoModel.fromJson(jsonDecode(body));
    return userInfo;
  }
}