import 'dart:convert';
import 'package:my_wealth/model/watchlist/watchlist_history_model.dart';
import 'package:my_wealth/model/watchlist/watchlist_list_model.dart';
import 'package:my_wealth/storage/box/local_box.dart';

class WatchlistSharedPreferences {
  static const _watchlistKey = "watchlists_list";
  static const _watchlistHistoryKey = "watchlist_history";

  static Future<void> setWatchlist(String type, List<WatchlistListModel> watchlistData) async {
    // stored the user info to box
    if(LocalBox.keyBox == null) {
      LocalBox.init();
    }

    // convert the json to string so we can stored it on the local storage
    List<String> watchlistList = [];
    for (WatchlistListModel watchlist in watchlistData) {
      watchlistList.add(jsonEncode(watchlist.toJson()));
    }
    LocalBox.putStringList("${_watchlistKey}_$type", watchlistList);
  }

  static List<WatchlistListModel> getWatchlist(String type) {
    // check if the key box is null or not?
    if(LocalBox.keyBox == null) {
      LocalBox.init();
    }

    // get the data from local box
    List<String> watchlistList = (LocalBox.getStringList("${_watchlistKey}_$type") ?? []);

    // check if the list is empty or not?
    if (watchlistList.isNotEmpty) {
      // list is not empty, parse the string to FavouriteModel
      List<WatchlistListModel> ret = [];
      for (String watchlistString in watchlistList) {
        WatchlistListModel watchlist = WatchlistListModel.fromJson(jsonDecode(watchlistString));
        ret.add(watchlist);
      }

      // return the favourites list
      return ret;
    }
    else {
      // no data
      return [];
    }
  }

  static WatchlistListModel? getWatchlistId(String type, int id) {
    // check if the key box is null or not?
    if(LocalBox.keyBox == null) {
      LocalBox.init();
    }

    // get the data from local box
    List<String> watchlistList = (LocalBox.getStringList("${_watchlistKey}_$type") ?? []);

    // check if the list is empty or not?
    if (watchlistList.isNotEmpty) {
      // list is not empty, parse the string to FavouriteModel
      for (String watchlistString in watchlistList) {
        WatchlistListModel watchlist = WatchlistListModel.fromJson(jsonDecode(watchlistString));
        // check if the current watchlist is the same ID as the one we request
        if (watchlist.watchlistId == id) {
          // if same return the watchlist
          return watchlist;
        }
      }

      // return null if not found
      return null;
    }
    else {
      // no data
      return null;
    }
  }

  static Future<void> setWatchlistHistory(List<WatchlistHistoryModel> watchlistData) async {
    // stored the user info to box
    if(LocalBox.keyBox == null) {
      LocalBox.init();
    }

    // convert the json to string so we can stored it on the local storage
    List<String> watchlistList = [];
    for (WatchlistHistoryModel watchlist in watchlistData) {
      watchlistList.add(jsonEncode(watchlist.toJson()));
    }
    LocalBox.putStringList(_watchlistHistoryKey, watchlistList);
  }

  static List<WatchlistHistoryModel> getWatchlistHistory() {
    // check if the key box is null or not?
    if(LocalBox.keyBox == null) {
      LocalBox.init();
    }

    // get the data from local box
    List<String> watchlistList = (LocalBox.getStringList(_watchlistHistoryKey) ?? []);

    // check if the list is empty or not?
    if (watchlistList.isNotEmpty) {
      // list is not empty, parse the string to FavouriteModel
      List<WatchlistHistoryModel> ret = [];
      for (String watchlistString in watchlistList) {
        WatchlistHistoryModel watchlist = WatchlistHistoryModel.fromJson(jsonDecode(watchlistString));
        ret.add(watchlist);
      }

      // return the favourites list
      return ret;
    }
    else {
      // no data
      return [];
    }
  }
}