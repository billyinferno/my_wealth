import 'package:my_wealth/_index.g.dart';

class WatchlistListArgs {
  final String type;
  final WatchlistListModel watchlist;
  final double? currentShare;
  final String shareName;
  final bool isLot;

  WatchlistListArgs({
    required this.type,
    required this.watchlist,
    this.currentShare,
    this.shareName = "SHARE",
    this.isLot = false,
  });
}