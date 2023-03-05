import 'package:flutter/material.dart';
import 'package:my_wealth/model/user/user_login.dart';

class UserProvider extends ChangeNotifier {
  UserLoginInfoModel? userInfo;

  setUserLoginInfo(UserLoginInfoModel userInfoParam) {
    userInfo = userInfoParam;
    notifyListeners();
  }
}