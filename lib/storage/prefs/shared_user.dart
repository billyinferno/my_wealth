import 'dart:convert';
import 'package:my_wealth/_index.g.dart';

class UserSharedPreferences {
  static const _userMeKey = "user_me";

  static Future<void> setUserJWT({required String bearerToken}) async {
    // put the bearerToken to the encrypted box
    LocalBox.putSecuredString(key: 'jwt', value: bearerToken);
  }

  static String getUserJWT() {
    String? bearerToken;
    // get the user bearer token
    bearerToken = LocalBox.getSecuredString(key: 'jwt');
    // if null then return blank string
    return (bearerToken ?? '');
  }

  static Future<void> setUserInfo({required UserLoginInfoModel userInfo}) async {
    // convert the json to string so we can stored it on the local storage
    String userInfoString = jsonEncode(userInfo.toJson());
    LocalBox.putString(key: _userMeKey, value: userInfoString);
  }
  
  static UserLoginInfoModel? getUserInfo() {
    // get the user information string from the local storage
    String userInfo = (LocalBox.getString(key: _userMeKey) ?? '');

    // check if the user information is available or not?
    if (userInfo.isNotEmpty) {
      // parse the user information string to json
      UserLoginInfoModel userInfoModel = UserLoginInfoModel.fromJson(jsonDecode(userInfo));
      return userInfoModel;
    }
    else {
      return null;
    }
  }

  static void setUserVisibility({required bool visibility}) {
    UserLoginInfoModel? currentUser = getUserInfo();

    // ensure current user is not null
    if (currentUser != null) {
      // now check if the visibility is the same or not?
      if (currentUser.visibility != visibility) {
        // create a new user info
        UserLoginInfoModel newUser = UserLoginInfoModel(
          id: currentUser.id,
          username: currentUser.username,
          email: currentUser.email,
          confirmed: currentUser.confirmed,
          blocked: currentUser.blocked,
          risk: currentUser.risk,
          visibility: visibility,
          showLots: currentUser.showLots,
          bot: currentUser.bot,
          showEmptyWatchlist: currentUser.showEmptyWatchlist
        );

        // assigned new user as the user info
        setUserInfo(userInfo: newUser);
      }
    }
  }
}