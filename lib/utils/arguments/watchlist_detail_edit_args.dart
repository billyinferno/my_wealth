import 'package:my_wealth/model/watchlist_list_model.dart';

class WatchlistDetailEditArgs {
  final String type;
  final WatchlistListModel watchlist;
  final int index;

  const WatchlistDetailEditArgs({required this.type, required this.watchlist, required this.index});
}