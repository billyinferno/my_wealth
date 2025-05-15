import 'package:flutter/material.dart';
import 'package:my_wealth/_index.g.dart';

class BarChartData {
  final String title;
  final double value;
  final double total;
  final Color color;

  BarChartData({
    required this.title,
    required this.value,
    required this.total,
    required this.color
  });
}

class BarChart extends StatelessWidget {
  final List<BarChartData> data;
  final EdgeInsets padding;
  final BoxDecoration decoration;
  final double barHeight;
  final BoxDecoration barDecoration;
  final double legendPadding;
  final bool showLegend;
  final bool showEmpty;
  const BarChart({
    super.key,
    required this.data,
    this.padding = const EdgeInsets.fromLTRB(10, 0, 10, 0),
    this.decoration = const BoxDecoration(),
    this.barHeight = 25,
    this.barDecoration = const BoxDecoration(
      border: Border(
        bottom: BorderSide(
          color: primaryDark,
          width: 1.0,
          style: BorderStyle.solid,
        ),
        left: BorderSide(
          color: primaryDark,
          width: 1.0,
          style: BorderStyle.solid,
        ),
        right: BorderSide(
          color: primaryDark,
          width: 1.0,
          style: BorderStyle.solid,
        ),
        top: BorderSide(
          color: primaryDark,
          width: 1.0,
          style: BorderStyle.solid,
        ),
      )
    ),
    this.legendPadding = 5,
    this.showLegend = true,
    this.showEmpty = true,
  });

  @override
  Widget build(BuildContext context) {
    // check if we got the data or not?
    if (data.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: padding,
      decoration: decoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          const SizedBox(height: 10,),
          Container(
            width: double.infinity,
            decoration: barDecoration,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: _generateBar(),
            ),
          ),
          const SizedBox(height: 5,),
          Visibility(
            visible: showLegend,
            child: SizedBox(height: legendPadding,)
          ),
          Visibility(
            visible: showLegend,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
              child: Wrap(
                alignment: WrapAlignment.center,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: List<Widget>.generate(data.length, (index) {
                  // check whether we need to show empty data or not?
                  if (!showEmpty) {
                    // if not then we need to check whether we have value on
                    // this or not?
                    if (data[index].value <= 0) {
                      return const SizedBox.shrink();
                    }
                  }

                  return _barLegend(
                    text: data[index].title,
                    color: data[index].color
                  );
                }),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _barLegend({required String text, required Color color}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        const SizedBox(width: 5,),
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
        const SizedBox(width: 5,),
      ],
    );
  }

  List<Widget> _generateBar() {
    List<Widget> result = [];
    int flexCalc = 0;

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
              height: barHeight,
              color: bar.color,
            ),
          )
        );
      }
    }

    return result;
  }
}