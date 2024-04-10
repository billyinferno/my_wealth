import 'package:flutter/material.dart';

class BarChartData {
  final String title;
  final double value;
  final double total;
  final Color color;

  BarChartData({required this.title, required this.value, required this.total, required this.color});
}

class BarChart extends StatelessWidget {
  final List<BarChartData> data;
  final EdgeInsets? padding;
  final BoxDecoration? decoration;
  final double? barHeight;
  final double? legendPadding;
  final bool? showLegend;
  const BarChart({super.key, required this.data, this.padding, this.decoration, this.barHeight, this.legendPadding, this.showLegend});

  @override
  Widget build(BuildContext context) {
    // check if we got the data or not?
    if (data.isEmpty) {
      return const SizedBox.shrink();
    }

    EdgeInsets currentPadding = (padding ?? const EdgeInsets.all(0));
    BoxDecoration currentDecoration = (decoration ?? const BoxDecoration());
    double currentLegendPadding = (legendPadding ?? 5);
    bool isShowLegend = (showLegend ?? true);

    return Container(
      padding: currentPadding,
      decoration: currentDecoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(10),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: _generateBar(),
            ),
          ),
          Visibility(
            visible: isShowLegend,
            child: SizedBox(height: currentLegendPadding,)
          ),
          Visibility(
            visible: isShowLegend,
            child: Container(
              padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: List<Widget>.generate(data.length, (index) {
                  return _barLegend(data[index].title, data[index].color);
                }),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _barLegend(String text, Color color) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Container(
          height: 10,
          width: 10,
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
          ),
        ),
      ],
    );
  }

  List<Widget> _generateBar() {
    List<Widget> result = [];
    int flexCalc = 0;
    double currentBarHeight = (barHeight ?? 25);

    // loop thru all the data
    for (BarChartData bar in data) {
      if (bar.value > 0) {
        // calculate the flex calc
        flexCalc = ((bar.value / bar.total) * 100).toInt();
        // ensure that at least we will have 1 flex calc for percentage that not touching 1%
        if (flexCalc <= 0) {
          flexCalc = 1;
        }

        result.add(
          Expanded(
            flex: flexCalc,
            child: Container(
              height: currentBarHeight,
              color: bar.color,
            ),
          )
        );
      }
    }

    return result;
  }
}