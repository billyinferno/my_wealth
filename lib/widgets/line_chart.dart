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
        data: data,
      ),
    );
  }
}