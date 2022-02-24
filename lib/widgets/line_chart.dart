import 'package:flutter/material.dart';
import 'package:my_wealth/widgets/heat_graph.dart';
import 'package:my_wealth/widgets/line_chart_painter.dart';

class LineChart extends StatelessWidget {
  final Map<DateTime, GraphData> data;
  final double? height;
  const LineChart({ Key? key, required this.data, this.height }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    double _height = (height ?? 250);
    return CustomPaint(
      child: Container(
        height: _height,
      ),
      painter: LineChartPainter(
        data: _convertDataToList(),
      ),
    );
  }

  List<GraphData> _convertDataToList() {
    // we need to expand data incase that there are gap on date, because the heat graph
    // expect to get all the date without skipping. So what we can do is to expand the
    // date given to exactly 91 days (65/5) * 7.

    List<GraphData> _dataExpand = [];

    // first get the 1st keys
    DateTime _firstDate = data.keys.first;
    DateTime _lastDate = data.keys.last;
    double _prevPrice = -1;

    for(int day=0; day<91; day++) {
      DateTime _keys = _firstDate.add(Duration(days: day));
      if(_keys.compareTo(_lastDate) <= 0) {
        // check if this weekend or weekday
        if(_keys.weekday <= 5) {
          // check if exists?
          if(data.containsKey(_keys)) {
            _dataExpand.add(GraphData(date: _keys, price: data[_keys]!.price));
            _prevPrice = data[_keys]!.price;
          }
          else {
            _dataExpand.add(GraphData(date: _keys, price: _prevPrice));
          }
        }
      }
      else {
        // already end of data, exit from loop
        break;
      }
    }

    return _dataExpand;
  }
}