import 'package:flutter/material.dart';
import 'package:my_wealth/themes/colors.dart';
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        SizedBox(
          width: double.infinity,
          child: CustomPaint(
            painter: LineChartPainter(
              data: _convertDataToList(),
              watchlist: watchlist,
            ),
            child: Container(
              height: chartHeight,
            ),
          ),
        ),
        Container(
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

  List<GraphData> _convertDataToList() {
    // convert the data from map into list
    List<GraphData> dataExpand = [];
    data.forEach((key, value) => dataExpand.add(value));

    return dataExpand;
  }
}