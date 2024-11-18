import 'package:flutter/material.dart';
import 'package:my_wealth/themes/colors.dart';

class WeekdayPerformanceChart extends StatelessWidget {
  const WeekdayPerformanceChart({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(10, 0, 10, 0),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        border: Border.all(
          color: primaryLight,
          width: 1.0,
          style: BorderStyle.solid,
        )
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              _dayBox(day: "Mon"),
              _dayBox(day: "Tue"),
              _dayBox(day: "Wed"),
              _dayBox(day: "Thu"),
              _dayBox(day: "Fri"),
            ],
          ),
          const SizedBox(width: 5,),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                ...List<Widget>.generate(5, (index) {
                  return Container(
                    margin: const EdgeInsets.fromLTRB(0, 0, 0, 5),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: <Widget>[
                        ...List<Widget>.generate(10, (index) {
                          return _bar(color: Colors.red, borderColor: secondaryLight);
                        },),
                        _bar(color: Colors.orange, borderColor: Colors.orange[200]!),
                        ...List<Widget>.generate(10, (index) {
                          return _bar(color: Colors.green, borderColor: Colors.green[200]!);
                        },),
                      ],
                    ),
                  );
                },),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    ...List<Widget>.generate(10, (index) {
                      return _percentageText(text: "${(10 - index) * 10}%", color: secondaryColor);
                    },),
                    _percentageText(text: "0%"),
                    ...List<Widget>.generate(10, (index) {
                      return _percentageText(text: "${(index + 1) * 10}%", color: Colors.green);
                    },),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 5,),
          SizedBox(
            width: 30,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                _averageBox(percentage: 100),
                _averageBox(percentage: 100),
                _averageBox(percentage: 100),
                _averageBox(percentage: 100),
                _averageBox(percentage: 100),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _percentageText({
    Color color = textPrimary,
    required String text
  }) {
    return RotatedBox(
      quarterTurns: 1,
      child: Text(
        text,
        style: TextStyle(
          fontSize: 9,
          color: color,
        ),
      ),
    );
  }

  //TODO: to calculate automatically the color based on the percentage and the count total
  Widget _bar({
    Color borderColor = primaryLight,
    Color color = Colors.transparent
  }) {
    return Container(
      width: 8,
      height: 20,
      decoration: BoxDecoration(
        border: Border.all(
          color: borderColor,
        ),
        borderRadius: BorderRadius.circular(10),
        color: color,
      ),
    );
  }

  Widget _dayBox({required String day}) {
    return Container(
      margin: const EdgeInsets.fromLTRB(0, 0, 0, 5),
      height: 20,
      child: Align(
        alignment: Alignment.centerRight,
        child: Text(
          day,
          style: TextStyle(
            fontSize: 10,
          ),
        ),
      ),
    );
  }

  Widget _averageBox({required double percentage}) {
    return Container(
      margin: const EdgeInsets.fromLTRB(0, 0, 0, 5),
      height: 20,
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          "$percentage%",
          style: TextStyle(
            fontSize: 8,
          ),
        ),
      ),
    );
  }
}