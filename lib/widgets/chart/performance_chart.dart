import 'package:flutter/material.dart';
import 'package:my_wealth/model/watchlist/watchlist_detail_list_model.dart';
import 'package:my_wealth/model/watchlist/watchlist_performance_model.dart';
import 'package:my_wealth/utils/function/binary_computation.dart';
import 'package:my_wealth/widgets/chart/performance_chart_painter.dart';

class PerformanceChart extends StatefulWidget {
  final List<WatchlistPerformanceModel>? data;
  final List<PerformanceData>? perfData;
  final List<WatchlistDetailListModel>? watchlist;
  final double? height;

  const PerformanceChart({Key? key, this.data, this.perfData, this.watchlist, this.height}) : super(key: key);

  @override
  State<PerformanceChart> createState() => _PerformanceChartState();
}

class _PerformanceChartState extends State<PerformanceChart> {
  final Bit _bitData = Bit();
  late List<WatchlistPerformanceModel> _watchlistData;
  late List<PerformanceData> _data;
  late ChartProperties _dataProperties;
  late List<PerformanceData> _investment;
  late ChartProperties _investmentProperties;
  final Map<DateTime, int> _watchlist = {};

  double _min = double.infinity;
  double _max = 0;
  double _gap = 0;
  double _norm = 0;

  double _minInvestment = double.infinity;
  double _maxInvestment = 0;
  double _gapInvestment = 0;
  double _normInvestment = 0;
  bool _isLoaded = false;

  @override
  void initState() {
    // check if we already got performance data or not?
    // if got, then we can just put the performance data there
    _data = (widget.perfData ?? []);

    // initialize the investment data with empty data
    // we will only compute this, if the watchlist is available
    // since we will need the full data, not just performance data
    _investment = [];

    // put the watchlist performance data into watchlistData
    _watchlistData = (widget.data ?? []);

    // ensure that at least _data or _watchlistData is not empty
    if (_data.isEmpty && _watchlistData.isEmpty) {
      throw Exception('There are not data to be displayed on the performance data');
    }

    // perform computation
    _compute();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if (!_isLoaded) return const SizedBox.shrink();

    return CustomPaint(
      painter: PerformanceChartPainter(
        data: _data,
        dataProperties: _dataProperties,
        investment: _investment,
        investmentProperties: _investmentProperties,
        watchlist: _watchlist,
      ),
      child: SizedBox(
        height: (widget.height ?? 250),
      ),
    );
  }

  void _compute() {
    double gain;
    double value;

    // check if we already got performance data or not?
    if (_data.isEmpty) {
      // loop thru all the performance model data
      for (WatchlistPerformanceModel perf in _watchlistData) {
        // calculate the gain
        gain = (perf.buyTotal * perf.currentPrice) - (perf.buyTotal * perf.buyAvg);

        // check the gain with _min and _max
        if (gain < _min) {
          _min = gain;
        }

        if (gain > _max) {
          _max = gain;
        }

        // create the performance data
        PerformanceData dt = PerformanceData(
          date: perf.buyDate,
          gain: gain,
          total: perf.buyAmount
        );

        // add the performance data to the list
        _data.add(dt);

        // calculate the investment value at this date
        value = (perf.buyAvg * perf.buyTotal);
        if (value < _minInvestment) {
          _minInvestment = value;
        }
        if (value > _maxInvestment) {
          _maxInvestment = value;
        }

        PerformanceData iv = PerformanceData(
          date: perf.buyDate,
          gain: value,
          total: perf.buyAmount,
        );

        // add the investment data to the list
        _investment.add(iv);
      }
    }
    else {
      // loop thru _data to get the _min and _max
      for (PerformanceData perf in _data) {
        if (perf.gain < _min) {
          _min = perf.gain;
        }
        if (perf.gain > _max) {
          _max = perf.gain;
        }
      }
    }

    // check if we never set min before
    if (_min == double.infinity) {
      _min = 0;
    }

    // check the gap between _min and _max
    _gap = _max - _min;
    _gapInvestment = _maxInvestment - _minInvestment;

    // check if _gap is less than 0, if less than 0 it means that this watchlist
    // never even go to the green even once. thus we will need to make the gap
    // value into positive.
    if (_gap < 0) {
      _gap = _gap * (-1);
    }

    if (_gapInvestment < 0) {
      _gapInvestment = _gapInvestment * (-1);
    }

    // calculate the normalize value
    _norm = _gap - _max;
    _normInvestment = _gapInvestment - _maxInvestment;

    // create the chart properties
    _dataProperties = ChartProperties(min: _min, max: _max, gap: _gap, norm: _norm);
    _investmentProperties = ChartProperties(min: _minInvestment, max: _maxInvestment, gap: _gapInvestment, norm: _normInvestment);

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