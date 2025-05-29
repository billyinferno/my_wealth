import 'package:my_wealth/_index.g.dart';

class WatchlistDetailEditArgs {
  final String type;
  final WatchlistListModel watchlist;
  final int index;
  final bool isLot;
  final String shareName;

  const WatchlistDetailEditArgs({
    required this.type,
    required this.watchlist,
    required this.index,
    required this.isLot,
    required this.shareName,
  });
}