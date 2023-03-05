import 'package:my_wealth/model/watchlist/watchlist_list_model.dart';

class WatchlistListArgs {
  final String type;
  final WatchlistListModel watchList;
  final double? currentShare;

  WatchlistListArgs({required this.type, required this.watchList, this.currentShare});
}