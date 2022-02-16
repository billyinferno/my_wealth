import 'package:my_wealth/model/watchlist_list_model.dart';

class WatchlistDetailEditArgs {
  final WatchlistListModel watchlist;
  final int index;

  const WatchlistDetailEditArgs({required this.watchlist, required this.index});
}