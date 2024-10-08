import 'package:flutter/material.dart';
import 'package:my_wealth/_index.g.dart';

class UserProvider extends ChangeNotifier {
  UserLoginInfoModel? userInfo;
  bool? _isSummaryVisible;
  bool? _isShowLots;
  bool? _isShowEmptyWatchlists;

  setUserLoginInfo({required UserLoginInfoModel user}) {
    userInfo = user;
    notifyListeners();
  }

  setSummaryVisibility({required bool visibility}) {
    _isSummaryVisible = visibility;
  }

  bool getSummaryVisibility() {
    return (_isSummaryVisible ?? false);
  }

  setShowLots({required bool visibility}) {
    _isShowLots = visibility;
  }

  bool getShowLots() {
    return (_isShowLots ?? false);
  }

  setShowEmptyWatchlists({required bool visibility}) {
    _isShowEmptyWatchlists = visibility;
  }

  bool getShowEmptyWatchlists() {
    return (_isShowEmptyWatchlists ?? true);
  }
}