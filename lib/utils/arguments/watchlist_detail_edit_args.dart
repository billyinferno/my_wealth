import 'package:my_wealth/_index.g.dart';

class WatchlistDetailEditArgs {
  final String type;
  final WatchlistListModel watchlist;
  final int index;

  const WatchlistDetailEditArgs({required this.type, required this.watchlist, required this.index});
}