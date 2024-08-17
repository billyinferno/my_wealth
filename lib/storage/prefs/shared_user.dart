import 'dart:convert';
import 'package:my_wealth/_index.g.dart';

class UserSharedPreferences {
  static const _userMeKey = "user_me";

  static Future<void> setUserJWT(String bearerToken) async {
    // ensure that encrypted box is not null, by right as we always initialize this
    // on the startup of app, this wouldn't be null when it reach this point.
    if (LocalBox.encryptedBox == null) {
      LocalBox.init();
    }

    // now put the bearerToken to the encrypted box
    LocalBox.putSecuredString('jwt', bearerToken);
  }

  static String getUserJWT() {
    String? bearerToken;

    if (LocalBox.encryptedBox != null) {
      bearerToken = LocalBox.getSecuredString('jwt');
      // if not null then return blank string
      return (bearerToken ?? '');
    }
    else {
      return '';
    }
  }

  static Future<void> setUserInfo(UserLoginInfoModel userInfo) async {
    // stored the user info to box
    if(LocalBox.keyBox == null) {
      LocalBox.init();
    }

    // convert the json to string so we can stored it on the local storage
    String userInfoString = jsonEncode(userInfo.toJson());
    LocalBox.putString(_userMeKey, userInfoString);
  }
  
  static UserLoginInfoModel? getUserInfo() {
    // check if the key box is null or not?
    if(LocalBox.keyBox == null) {
      LocalBox.init();
    }

    // get the user information string from the local storage
    String userInfo = (LocalBox.getString(_userMeKey) ?? '');

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
        setUserInfo(newUser);
      }
    }
  }
}