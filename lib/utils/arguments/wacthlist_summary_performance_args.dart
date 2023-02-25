import 'package:my_wealth/utils/function/compute_watchlist_all.dart';

class WatchlistSummaryPerformanceArgs {
  final String type;
  final ComputeWatchlistAllResult? computeResult;

  WatchlistSummaryPerformanceArgs({required this.type, required this.computeResult});
}