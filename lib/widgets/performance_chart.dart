import 'package:flutter/material.dart';
import 'package:my_wealth/model/watchlist_detail_list_model.dart';
import 'package:my_wealth/model/watchlist_performance_model.dart';
import 'package:my_wealth/utils/function/binary_computation.dart';
import 'package:my_wealth/widgets/performance_chart_painter.dart';

class PerformanceChart extends StatefulWidget {
  final List<WatchlistPerformanceModel> data;
  final List<WatchlistDetailListModel>? watchlist;
  final double? height;

  const PerformanceChart({Key? key, required this.data, this.watchlist, this.height}) : super(key: key);

  @override
  State<PerformanceChart> createState() => _PerformanceChartState();
}

class _PerformanceChartState extends State<PerformanceChart> {
  final Bit _bitData = Bit();
  final List<PerformanceData> _data = [];
  final Map<DateTime, int> _watchlist = {};

  double _min = double.infinity;
  double _max = 0;
  double _gap = 0;
  double _norm = 0;
  bool _isLoaded = false;

  @override
  void initState() {
    _compute();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if (!_isLoaded) return const SizedBox.shrink();

    return CustomPaint(
      painter: PerformanceChartPainter(
        data: _data,
        watchlist: _watchlist,
        min: _min,
        max: _max,
        gap: _gap,
        norm: _norm,
      ),
      child: SizedBox(
        height: (widget.height ?? 250),
      ),
    );
  }

  void _compute() {
    double gain;

    // loop thru all the performance model data
    for (WatchlistPerformanceModel perf in widget.data) {
      // calculate the gain
      gain =
          (perf.buyTotal * perf.currentPrice) - (perf.buyTotal * perf.buyAvg);

      // check the gain with _min and _max
      if (gain < _min) {
        _min = gain;
      }

      if (gain > _max) {
        _max = gain;
      }

      // create the performance data
      PerformanceData dt = PerformanceData(date: perf.buyDate, gain: gain);

      // add the performance data to the list
      _data.add(dt);
    }

    // check the gap between _min and _max
    // print("$_max - $_min");
    _gap = _max - _min;

    // check if _gap is less than 0, if less than 0 it means that this watchlist
    // never even go to the green even once. thus we will need to make the gap
    // value into positive.
    if (_gap < 0) {
      _gap = _gap * (-1);
    }

    // calculate the normalize value
    _norm = _gap - _max;

    // loop thru the watchlist if available
    if (widget.watchlist != null) {
      DateTime tempDate;

      // loop thru all the watchlist
      for(WatchlistDetailListModel dt in widget.watchlist!) {
        tempDate = dt.watchlistDetailDate.toLocal();
        if (_watchlist.containsKey(DateTime(tempDate.year, tempDate.month, tempDate.day))) {
          // set the bit data value as current value on this date
          _bitData.set(_watchlist[DateTime(tempDate.year, tempDate.month, tempDate.day)]!);

          // check the type of transaction
          if (dt.watchlistDetailShare >= 0) {
            // this is buy
            _bitData[15] = 1;
            _watchlist[DateTime(tempDate.year, tempDate.month, tempDate.day)] =  _bitData.toInt();
          }
          if (dt.watchlistDetailShare < 0) {
            // this is sell
            _bitData[14] = 1;
            _watchlist[DateTime(tempDate.year, tempDate.month, tempDate.day)] = _bitData.toInt();
          }
        }
        else {
          if (dt.watchlistDetailShare >= 0) {
            // this is buy
            _watchlist[DateTime(tempDate.year, tempDate.month, tempDate.day)] = 1;
          }
          if (dt.watchlistDetailShare < 0) {
            _watchlist[DateTime(tempDate.year, tempDate.month, tempDate.day)] = 2;
          }
        }
      }
    }

    // set load to true, so we can show the graph
    setState(() {
      _isLoaded = true;
    });
  }
}