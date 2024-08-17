import 'package:my_wealth/_index.g.dart';

class WatchlistListArgs {
  final String type;
  final WatchlistListModel watchList;
  final double? currentShare;

  WatchlistListArgs({required this.type, required this.watchList, this.currentShare});
}