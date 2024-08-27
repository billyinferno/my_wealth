import 'package:flutter/material.dart';
import 'package:my_wealth/_index.g.dart';

class WatchlistProvider extends ChangeNotifier {
  List<WatchlistListModel>? watchlistReksadana;
  List<WatchlistListModel>? watchlistSaham;
  List<WatchlistListModel>? watchlistCrypto;
  List<WatchlistListModel>? watchlistGold;
  List<WatchlistHistoryModel>? watchlistHistory;

  setWatchlist({
    required String type,
    required List<WatchlistListModel> watchlistData
  }) {
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

  setWatchlistHistory({required List<WatchlistHistoryModel> watchlistData}) {
    watchlistHistory = watchlistData;
    notifyListeners();
  }
}