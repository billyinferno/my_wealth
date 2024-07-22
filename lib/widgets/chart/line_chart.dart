import 'package:flutter/material.dart';
import 'package:my_wealth/themes/colors.dart';
import 'package:my_wealth/widgets/chart/heat_graph.dart';
import 'package:my_wealth/widgets/chart/line_chart_painter.dart';

class LineChart extends StatelessWidget {
  final List<GraphData> data;
  final List<GraphData>? compare;
  final List<DateTime>? dividend;
  final Map<DateTime, int>? watchlist;
  final double? height;
  final bool? showLegend;
  final int? dateOffset;
  const LineChart({
    super.key,
    required this.data,
    this.compare,
    this.dividend,
    this.height,
    this.watchlist,
    this.showLegend,
    this.dateOffset
  });

  @override
  Widget build(BuildContext context) {
    double chartHeight = (height ?? 250);
    bool isShowLegend = (showLegend ?? true);

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

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        SizedBox(
          width: double.infinity,
          child: CustomPaint(
            painter: LineChartPainter(
              data: data,
              compare: compare,
              dividend: dividend,
              watchlist: watchlist,
              showLegend: showLegend,
              dateOffset: datePrintOffset,
            ),
            child: Container(
              height: chartHeight,
            ),
          ),
        ),
        Visibility(
          visible: isShowLegend,
          child: Container(
            padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                _legend(color: Colors.orange, text: "Average"),
                _legend(color: Colors.green, text: "MA5"),
                _legend(color: Colors.pink, text: "MA8"),
                _legend(color: Colors.blue, text: "MA13"),
              ],
            ),
          ),
        ),
        const SizedBox(height: 10,),
      ],
    );
  }

  Widget _legend({required Color color, required String text}) {
    return Expanded(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          const SizedBox(width: 5,),
          Text(
            text,
            style: const TextStyle(
              fontSize: 10,
              color: textPrimary,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}