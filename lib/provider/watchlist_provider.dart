import 'package:flutter/material.dart';
import 'package:my_wealth/_index.g.dart';

class WatchlistProvider extends ChangeNotifier {
  Map<String, List<WatchlistListModel>>? watchlistData;
  List<WatchlistHistoryModel>? watchlistHistory;

  void setWatchlist({
    required String type,
    required List<WatchlistListModel> data
  }) {
    // check if watchlist data is null
    watchlistData ??= {};

    // set the type of watchlist data with data
    watchlistData![type] = data;

    notifyListeners();
  }

  void setWatchlistHistory({required List<WatchlistHistoryModel> data}) {
    watchlistHistory = data;
    notifyListeners();
  }
}