import 'package:flutter/material.dart';
import 'package:my_wealth/model/watchlist_history_model.dart';
import 'package:my_wealth/model/watchlist_list_model.dart';

class WatchlistProvider extends ChangeNotifier {
  List<WatchlistListModel>? watchlistReksadana;
  List<WatchlistListModel>? watchlistSaham;
  List<WatchlistListModel>? watchlistCrypto;
  List<WatchlistListModel>? watchlistGold;
  List<WatchlistHistoryModel>? watchlistHistory;

  setWatchlist(String type, List<WatchlistListModel> watchlistData) {
    if(type == "reksadana") {
      watchlistReksadana = watchlistData;
    }
    else if(type == "saham") {
      watchlistSaham = watchlistData;
    }
    else if(type == "crypto") {
      watchlistCrypto = watchlistData;
    }
    else if(type == "gold") {
      watchlistGold = watchlistData;
    }
    notifyListeners();
  }

  setWatchlistHistory(List<WatchlistHistoryModel> watchlistData) {
    watchlistHistory = watchlistData;
    notifyListeners();
  }
}