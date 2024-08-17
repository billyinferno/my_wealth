import 'dart:convert';
import 'package:my_wealth/_index.g.dart';

class UserAPI {
  Future<UserLoginModel> login(String username, String password) async {
    // post login information using netutils
    final String body = await NetUtils.post(
      url: Globals.apiAuthLocal,
      body: {'identifier': username, 'password': password},
      requiredJWT: false,
    ).onError((error, stackTrace) {
        throw Exception(error);
      }
    );

    // parse the response and put on user login model
    UserLoginModel userLogin = UserLoginModel.fromJson(jsonDecode(body));
    return userLogin;
  }

  Future<UserLoginInfoModel> me() async {
    // get user information data using netutils
    final String body = await NetUtils.get(
      url: '${Globals.apiUsers}/me'
    ).onError((error, stackTrace) {
        throw error as NetException;
      }
    );

    // parse the response and put on user login model
    UserLoginInfoModel userInfo = UserLoginInfoModel.fromJson(jsonDecode(body));
    return userInfo;
  }

  Future<UserLoginInfoModel> updateRisk(int risk) async {
    // patch user risk information using netutils
    final String body = await NetUtils.patch(
      url: Globals.apiRisk,
      body: {'risk': risk},
    ).onError((error, stackTrace) {
        throw Exception(error);
      }
    );

    // parse the response and put on user login model
    UserLoginInfoModel userInfo = UserLoginInfoModel.fromJson(jsonDecode(body));
    return userInfo;
  }

  Future<UserLoginInfoModel> updateVisibilitySummary(bool visibility) async {
    // patch user visibility using netutils
    final String body = await NetUtils.patch(
      url: '${Globals.apiVisibility}/summary',
      body: {'visibility': visibility},
    ).onError((error, stackTrace) {
        throw Exception(error);
      }
    );

    // parse the response and put on user login model
    UserLoginInfoModel userInfo = UserLoginInfoModel.fromJson(jsonDecode(body));
    return userInfo;
  }

  Future<UserLoginInfoModel> updateShowLots(bool showLots) async {
    // patch user show lots using netutils
    final String body = await NetUtils.patch(
      url: '${Globals.apiVisibility}/lots',
      body: {'show_lots': showLots},
    ).onError((error, stackTrace) {
        throw Exception(error);
      }
    );

    // parse the response and put on user login model
    UserLoginInfoModel userInfo = UserLoginInfoModel.fromJson(jsonDecode(body));
    return userInfo;
  }

  Future<UserLoginInfoModel> updateShowEmptyWatchlist(bool showEmptyWatchlist) async {
    // patch user show lots using netutils
    final String body = await NetUtils.patch(
      url: '${Globals.apiVisibility}/emptywatchlist',
      body: {'show_empty_watchlist': showEmptyWatchlist},
    ).onError((error, stackTrace) {
        throw Exception(error);
      }
    );

    // parse the response and put on user login model
    UserLoginInfoModel userInfo = UserLoginInfoModel.fromJson(jsonDecode(body));
    return userInfo;
  }

  Future<UserLoginInfoModel> updatePassword(String password, String newPassword) async {
    // patch user password lots using netutils
    final String body = await NetUtils.patch(
      url: Globals.apiPassword,
      body: {
        'password': password,
        'newPassword': newPassword
      },
    ).onError((error, stackTrace) {
        throw Exception(error);
      }
    );

    // parse the response and put on user login model
    UserLoginInfoModel userInfo = UserLoginInfoModel.fromJson(jsonDecode(body));
    return userInfo;
  }

  Future<UserLoginInfoModel> updateBotToken(String bot) async {
    // patch user bot token lots using netutils
    final String body = await NetUtils.post(
      url: Globals.apiBot,
      body: {'bot': bot},
    ).onError((error, stackTrace) {
        throw Exception(error);
      }
    );

    // parse the response and put on user login model
    UserLoginInfoModel userInfo = UserLoginInfoModel.fromJson(jsonDecode(body));
    return userInfo;
  }
}