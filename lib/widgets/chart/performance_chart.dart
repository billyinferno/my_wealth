import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:my_wealth/_index.g.dart';

class ChartComputeResult {
  final ChartProperties dataProperties;
  final ChartProperties investmentProperties;
  final ChartProperties? compareProperties;

  const ChartComputeResult({
    required this.dataProperties,
    required this.investmentProperties,
    required this.compareProperties,
  });
}

class PerformanceChart extends StatelessWidget {
  final List<WatchlistPerformanceModel>? watchlistPerfData;
  final List<PerformanceData>? perfData;
  final List<PerformanceData>? compare;
  final List<WatchlistDetailListModel>? watchlist;
  final double? height;
  final int? dateOffset;
  final DateFormat dateFormat;

  const PerformanceChart({
    super.key,
    this.watchlistPerfData,
    this.perfData,
    this.compare,
    this.watchlist,
    this.height,
    this.dateOffset,
    required this.dateFormat,
  });

  @override
  Widget build(BuildContext context) {
    // ensure that we have data for the chart
    if ((watchlistPerfData ?? []).isEmpty && (perfData ?? []).isEmpty) {
      return const SizedBox.shrink();
    }

    final Map<DateTime, int> watchlistResult = {};
    final List<WatchlistPerformanceModel> watchlistData = (watchlistPerfData ?? []);
    final List<PerformanceData> data = (perfData ?? []);
    
    final ChartComputeResult computeResult = _compute(
      watchlistData: watchlistData,
      watchlistResult: watchlistResult,
      data: data,
      compare: compare,
    );

    // get the date print offset based on the data length
    // try to calculate the datePrintOffset by checking from 2-10, which one
    // is the better date print offset
    int datePrintOffset = 1;
    if (dateOffset != null) {
      datePrintOffset = dateOffset!;
    }
    else {
      for(int i=2; i<=10; i++) {
        datePrintOffset = (data.length ~/ i);
        if (datePrintOffset <= 10) {
          // exit from loop
          break;
        }
      }
    }

    return CustomPaint(
      painter: PerformanceChartPainter(
        data: data,
        dataProperties: computeResult.dataProperties,
        compare: compare,
        compareProperties: computeResult.compareProperties,
        showInvestment: true,
        investmentProperties: computeResult.investmentProperties,
        watchlist: watchlistResult,
        datePrintOffset: datePrintOffset,
        dateFormat: dateFormat,
      ),
      child: SizedBox(
        height: (height ?? 250),
      ),
    );
  }

  ChartComputeResult _compute({
    required List<WatchlistPerformanceModel> watchlistData,
    required Map<DateTime, int> watchlistResult,
    required List<PerformanceData> data,
    List<PerformanceData>? compare,
  }) {
    final Bit bitData = Bit();
    DateTime tempDate;
    
    double gain;
    double min = double.infinity;
    double max = 0;
    double gap = 0;
    double norm = 0;

    double minInvestment = double.infinity;
    double maxInvestment = 0;
    double gapInvestment = 0;
    double normInvestment = 0;

    double minCompare = double.infinity;
    double maxCompare = 0;
    double gapCompare = 0;
    double normCompare = 0;

    // always clear the watchlist before we perform computation
    watchlistResult.clear();

    // check if we already got performance data or not?
    if (data.isEmpty) {
      // loop thru all the performance model data
      for (WatchlistPerformanceModel perf in watchlistData) {
        // calculate the gain
        gain = (perf.buyTotal * perf.currentPrice) - (perf.buyTotal * perf.buyAvg);

        // check the gain with _min and _max
        if (gain < min) {
          min = gain;
        }

        if (gain > max) {
          max = gain;
        }

        // create the performance data
        PerformanceData dt = PerformanceData(
          date: perf.buyDate,
          gain: gain,
          total: perf.buyAmount
        );

        // add the performance data to the list
        data.add(dt);

        // calculate the investment value at this date
        if (perf.buyAmount < minInvestment) {
          minInvestment = perf.buyAmount;
        }
        if (perf.buyAmount > maxInvestment) {
          maxInvestment = perf.buyAmount;
        }
      }
    }
    else {
      // loop thru _data to get the _min and _max
      for (PerformanceData perf in data) {
        if (perf.gain < min) {
          min = perf.gain;
        }
        if (perf.gain > max) {
          max = perf.gain;
        }

        // since investment also coming from performance data, just add the
        // performance data to the investment, we just need to check what is
        // the maximum and minimum of the investment to generate the data.
        if (perf.total < minInvestment) {
          minInvestment = perf.total;
        }
        if (perf.total > maxInvestment) {
          maxInvestment = perf.total;
        }
      }
    }

    // check if data length is only 1
    if (data.length == 1) {
      // means we need to fake the 1st data with all 0
      PerformanceData currData = data[0];
      PerformanceData fakeData = PerformanceData(
        date: currData.date.subtract(Duration(days: 1)),
        gain: 0,
        total: 0
      );

      data.clear();
      data.add(fakeData);
      data.add(currData);
    }

    // check if we never set min before
    if (min == double.infinity) {
      min = 0;
    }

    // check the gap between _min and _max
    gap = max - min;
    gapInvestment = maxInvestment - minInvestment;

    // check if _gap is less than 0, if less than 0 it means that this watchlist
    // never even go to the green even once. thus we will need to make the gap
    // value into positive.
    if (gap < 0) {
      gap = gap * (-1);
    }

    if (gapInvestment < 0) {
      gapInvestment = gapInvestment * (-1);
    }

    // calculate the normalize value
    norm = gap - max;
    normInvestment = gapInvestment - maxInvestment;

    // check if we have compare or not?
    if ((compare ?? []).isNotEmpty) {
      // loop thru compare and calculate the compare properties
      for(PerformanceData cmp in compare!) {
        if (cmp.total < minCompare) {
          minCompare = cmp.total;
        }
        if (cmp.total > maxCompare) {
          maxCompare = cmp.total;
        }
      }

      // once finished we can get the gap and normalize value for the compare
      gapCompare = maxCompare - minCompare;
      normCompare = gapCompare - maxCompare;
    }

    // loop thru the watchlist if available
    if ((watchlist ?? []).isNotEmpty) {
      // loop thru all the watchlist
      for(WatchlistDetailListModel dt in watchlist!) {
        // get the current watchlist date
        tempDate = dt.watchlistDetailDate.toLocal();

        // check if we already have this date on the watchlist result map
        if (watchlistResult.containsKey(DateTime(tempDate.year, tempDate.month, tempDate.day))) {
          // already have this date on the watchlist result map, so we need to
          // set the bit data value as current value on this date.
          // this is only happen if we have 2 same watchlist data being add
          // on the same day (buy and sell on the same day).
          bitData.set(watchlistResult[DateTime(tempDate.year, tempDate.month, tempDate.day)]!);

          // check the type of transaction
          if (dt.watchlistDetailShare >= 0) {
            // this is buy
            bitData[15] = 1;
            watchlistResult[DateTime(tempDate.year, tempDate.month, tempDate.day)] =  bitData.toInt();
          }
          if (dt.watchlistDetailShare < 0) {
            // this is sell
            bitData[14] = 1;
            watchlistResult[DateTime(tempDate.year, tempDate.month, tempDate.day)] = bitData.toInt();
          }
        }
        else {
          if (dt.watchlistDetailShare >= 0) {
            // this is buy
            watchlistResult[DateTime(tempDate.year, tempDate.month, tempDate.day)] = 1;
          }
          if (dt.watchlistDetailShare < 0) {
            watchlistResult[DateTime(tempDate.year, tempDate.month, tempDate.day)] = 2;
          }
        }
      }
    }

    // result the compute res
    return ChartComputeResult(
      dataProperties: ChartProperties(min: min, max: max, gap: gap, norm: norm),
      investmentProperties: ChartProperties(min: minInvestment, max: maxInvestment, gap: gapInvestment, norm: normInvestment),
      compareProperties: ChartProperties(min: minCompare, max: maxCompare, gap: gapCompare, norm: normCompare),
    );
  }
}