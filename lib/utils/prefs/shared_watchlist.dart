import 'dart:convert';
import 'package:my_wealth/model/watchlist_list_model.dart';
import 'package:my_wealth/storage/local_box.dart';

class WatchlistSharedPreferences {
  static const _watchlistKey = "watchlists_list";

  static Future<void> setWatchlist(String type, List<WatchlistListModel> watchlistData) async {
    // stored the user info to box
    if(LocalBox.keyBox == null) {
      LocalBox.init();
    }

    // convert the json to string so we can stored it on the local storage
    List<String> _watchlistList = [];
    for (WatchlistListModel _watchlist in watchlistData) {
      _watchlistList.add(jsonEncode(_watchlist.toJson()));
    }
    LocalBox.putStringList(_watchlistKey + "_" + type, _watchlistList);
  }

  static List<WatchlistListModel> getWatchlist(String type) {
    // check if the key box is null or not?
    if(LocalBox.keyBox == null) {
      LocalBox.init();
    }

    // get the data from local box
    List<String> _watchlistList = (LocalBox.getStringList(_watchlistKey + "_" + type) ?? []);

    // check if the list is empty or not?
    if (_watchlistList.isNotEmpty) {
      // list is not empty, parse the string to FavouriteModel
      List<WatchlistListModel> _ret = [];
      for (String _watchlistString in _watchlistList) {
        WatchlistListModel _watchlist = WatchlistListModel.fromJson(jsonDecode(_watchlistString));
        _ret.add(_watchlist);
      }

      // return the favourites list
      return _ret;
    }
    else {
      // no data
      return [];
    }
  }
}