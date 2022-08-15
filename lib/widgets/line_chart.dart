import 'package:flutter/material.dart';
import 'package:my_wealth/widgets/heat_graph.dart';
import 'package:my_wealth/widgets/line_chart_painter.dart';

class LineChart extends StatelessWidget {
  final Map<DateTime, GraphData> data;
  final Map<DateTime, double>? watchlist;
  final double? height;
  const LineChart({ Key? key, required this.data, this.height, this.watchlist }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    double chartHeight = (height ?? 250);
    return CustomPaint(
      painter: LineChartPainter(
        data: _convertDataToList(),
        watchlist: watchlist,
      ),
      child: Container(
        height: chartHeight,
      ),
    );
  }

  List<GraphData> _convertDataToList() {
    // we need to expand data incase that there are gap on date, because the heat graph
    // expect to get all the date without skipping. So what we can do is to expand the
    // date given to exactly 91 days (65/5) * 7.

    List<GraphData> dataExpand = [];
    data.forEach((key, value) => dataExpand.add(value));

    // // first get the 1st keys
    // DateTime firstDate = data.keys.first;
    // DateTime lastDate = data.keys.last;
    // // double prevPrice = -1;

    // for(int day=0; day<91; day++) {
    //   DateTime keys = firstDate.add(Duration(days: day));
    //   if(keys.compareTo(lastDate) <= 0) {
    //     // check if this weekend or weekday
    //     if(keys.weekday <= 5) {
    //       // check if exists?
    //       if(data.containsKey(keys)) {
    //         dataExpand.add(GraphData(date: keys, price: data[keys]!.price));
    //         // prevPrice = data[keys]!.price;
    //       }
    //       // else {
    //       //   dataExpand.add(GraphData(date: keys, price: prevPrice));
    //       // }
    //     }
    //   }
    //   else {
    //     // already end of data, exit from loop
    //     break;
    //   }
    // }

    return dataExpand;
  }
}