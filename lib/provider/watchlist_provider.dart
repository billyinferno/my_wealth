import 'package:flutter/material.dart';
import 'package:my_wealth/model/watchlist_list_model.dart';

class WatchlistProvider extends ChangeNotifier {
  List<WatchlistListModel>? watchlist;

  setWatchlist(List<WatchlistListModel> watchlistData) {
    watchlist = watchlistData;
    notifyListeners();
  }
}