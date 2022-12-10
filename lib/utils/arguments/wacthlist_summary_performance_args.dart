import 'package:my_wealth/utils/function/compute_watchlist.dart';

class WatchlistSummaryPerformanceArgs {
  final String type;
  final ComputeWatchlistResult? computeResult;

  WatchlistSummaryPerformanceArgs({required this.type, required this.computeResult});
}