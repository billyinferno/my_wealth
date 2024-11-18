import 'package:flutter/material.dart';
import 'package:my_wealth/themes/colors.dart';

class WeekdayPerformanceChart extends StatelessWidget {
  const WeekdayPerformanceChart({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.start,
      children: <Widget>[
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            ...List<Widget>.generate(10, (index) {
              return RotatedBox(
                quarterTurns: 1,
                child: Container(
                  height: 10,
                  margin: const EdgeInsets.fromLTRB(2, 0, 2, 0),
                  child: Text(
                    "${index * -10}%",
                    style: TextStyle(
                      fontSize: 10,
                      color: textPrimary,
                    ),
                  ),
                ),
              );
            },),
            RotatedBox(
              quarterTurns: 1,
              child: Container(
                height: 10,
                margin: const EdgeInsets.fromLTRB(2, 0, 2, 0),
                child: Text(
                  "0%",
                  style: TextStyle(
                    fontSize: 10,
                    color: textPrimary,
                  ),
                ),
              ),
            ),
            ...List<Widget>.generate(10, (index) {
              return RotatedBox(
                quarterTurns: 1,
                child: Container(
                  height: 10,
                  margin: const EdgeInsets.fromLTRB(2, 0, 2, 0),
                  child: Text(
                    "${index * 10}%",
                    style: TextStyle(
                      fontSize: 10,
                      color: textPrimary,
                    ),
                  ),
                ),
              );
            },),
          ],
        ),
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            ...List<Widget>.generate(10, (index) {
              return Container(
                width: 10,
                height: 20,
                margin: const EdgeInsets.fromLTRB(2, 0, 2, 0),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: Colors.red,
                ),
              );
            },),
            Container(
              width: 10,
              height: 20,
              margin: const EdgeInsets.fromLTRB(2, 0, 2, 0),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: Colors.orange,
                ),
            ),
            ...List<Widget>.generate(10, (index) {
              return Container(
                width: 10,
                height: 20,
                margin: const EdgeInsets.fromLTRB(2, 0, 2, 0),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: Colors.green,
                ),
              );
            },),
          ],
        ),
      ],
    );
  }
}