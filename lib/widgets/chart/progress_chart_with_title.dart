import 'package:flutter/material.dart';
import 'package:my_wealth/_index.g.dart';

class ProgressChartWithTitle extends StatelessWidget {
  final String title;
  final double percentage;
  final int min;
  final int max;
  final int current;
  const ProgressChartWithTitle({
    super.key,
    required this.title,
    required this.percentage,
    required this.min,
    required this.max,
    required this.current,
  });

  @override
  Widget build(BuildContext context) {
    Color currentColor = Colors.white;
    if (percentage < 0) {
      currentColor = Colors.red;
    } else if (percentage > 0) {
      currentColor = Colors.green;
    }

    int leftFlex = current - min;
    int rightFlex = max - current;

    return Container(
      padding: const EdgeInsets.fromLTRB(0, 10, 0, 10),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: primaryLight,
            width: 1,
            style: BorderStyle.solid,
          ),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          SizedBox(
            width: 120,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.bold
                  ),
                ),
                const SizedBox(width: 5,),
                Text(
                  "(${formatDecimalWithNull((percentage * 100), decimal: 2)}%)",
                  style: TextStyle(
                    color: currentColor,
                  ),
                )
              ],
            ),
          ),
          const SizedBox(width: 5,),
          Expanded(
            child: SizedBox(
              child: Column(
                children: <Widget>[
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Text(
                        "$min",
                        style: TextStyle(
                          fontSize: 10,
                        ),
                      ),
                      Text(
                        "$max",
                        style: TextStyle(
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2,),
                  Stack(
                    alignment: Alignment.center,
                    children: <Widget>[
                      Row(
                        children: <Widget>[
                          Expanded(
                            child: Container(
                              height: 8,
                              decoration: BoxDecoration(
                                color: primaryLight,
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          ),
                        ],
                      ),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: <Widget>[
                          Expanded(
                            flex: leftFlex,
                            child: SizedBox(),
                          ),
                          Container(
                            width: 10,
                            height: 10,
                            decoration: BoxDecoration(
                              color: currentColor,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: primaryColor,
                                width: 1,
                                style: BorderStyle.solid,
                              ),
                            ),
                          ),
                          Expanded(
                            flex: rightFlex,
                            child: SizedBox(),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}