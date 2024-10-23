import 'package:my_wealth/_index.g.dart';

class WatchlistListArgs {
  final String type;
  final WatchlistListModel watchList;
  final double? currentShare;
  final String shareName;
  final bool isLot;

  WatchlistListArgs({
    required this.type,
    required this.watchList,
    this.currentShare,
    this.shareName = "SHARE",
    this.isLot = false,
  });
}