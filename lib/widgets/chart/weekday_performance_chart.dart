import 'package:flutter/material.dart';
import 'package:my_wealth/_index.g.dart';

class WeekdayPerformanceChart extends StatelessWidget {
  final CompanyWeekdayPerformanceModel data;
  const WeekdayPerformanceChart({
    super.key,
    required this.data,
  });

  @override
  Widget build(BuildContext context) {
   return Container(
      padding: const EdgeInsets.all(10),
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
                ...List<Widget>.generate(5, (weekday) {
                  WeekdayData? weekdayData = data.data["${weekday + 1}"];
                  return Container(
                    margin: const EdgeInsets.fromLTRB(0, 0, 0, 5),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: _generateBarChart(
                        data: weekdayData,
                        total: _totalCount(weekdayData: weekdayData),
                      ),
                    ),
                  );
                },),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    ...List<Widget>.generate(10, (index) {
                      return _rotatedText(text: "${formatDecimal((((10 - index) * 10)/100) * data.ceil, decimal: 2)}%", color: secondaryColor);
                    },),
                    _rotatedText(text: "0%"),
                    ...List<Widget>.generate(10, (index) {
                      return _rotatedText(text: "${formatDecimal((((index + 1) * 10)/100) * data.ceil, decimal: 2)}%", color: Colors.green);
                    },),
                  ],
                ),
                const SizedBox(height: 5,),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: _generateTotalWidget(),
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
              children: List<Widget>.generate(5, (weekday) {
                return _avgBox(percentage: data.data["${weekday + 1}"]?.average); 
              })
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _generateTotalWidget() {
    List<Widget> ret = [];
    Map<String, int> total = {};

    // loop thru the all the data to generate the total map
    data.data.forEach((key, weekdayData) {
      // loop thru the weekdayData
      weekdayData.list.forEach((key, count) {
        debugPrint("Key: $key, Count: $count");
        // calculate the total for this key
        total[key] = (total[key] ?? 0) + count;
        debugPrint("Total[$key] = ${total[key]}");
      },);
    },);

    // now loop thru all the possible data
    for(int i=-10; i<=10; i++) {
      // check if we have the data in the total map or not?
      if (total.containsKey("${i * 10}")) {
        ret.add(_rotatedText(text: "${i * 10} - ${total["${i * -10}"]}"));
      }
      else {
        ret.add(_rotatedText(text: ""));
      }
    }

    return ret;
  }

  Widget _rotatedText({
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

  List<Widget> _generateBarChart({
    required WeekdayData? data,
    required int total
  }) {
    List<Widget> ret = [];
    int barLocation;
    int colorShade;
    // add for the minus location
    for(int i=1; i<=10; i++) {
      barLocation = (i * -10);
      if (data != null) {
        // check if we got the data or not?
        if (data.list["$barLocation"] != null) {
          colorShade = ((data.list["$barLocation"]!/total) * 10).round() * 100;
          if (colorShade > 900) {
            colorShade = 900;
          }
          if (colorShade < 100) {
            colorShade = 100;
          }
          ret.add(_bar(color: Colors.red[colorShade]!, borderColor: Colors.red.shade50));
        }
        else {
          ret.add(_bar(color: Colors.transparent, borderColor: primaryLight));  
        }
      }
      else {
        ret.add(_bar(color: Colors.transparent, borderColor: primaryLight));
      }
    }

    // add the 0%
    if (data != null) {
      // check if we got 0 or not on the data
      if (data.list["0"] != null) {
        colorShade = ((data.list["0"]!/total) * 10).round() * 100;
          if (colorShade > 900) {
            colorShade = 900;
          }
          if (colorShade < 100) {
            colorShade = 100;
          }
        ret.add(_bar(color: Colors.orange[colorShade]!, borderColor: Colors.orange.shade50));
      }
      else {
        ret.add(_bar(color: Colors.transparent, borderColor: primaryLight));
      }
    }

    // add for the positive
    for(int i=1; i<=10; i++) {
      barLocation = (i * 10);
      if (data != null) {
        // check if we got the data or not?
        if (data.list["$barLocation"] != null) {
          colorShade = ((data.list["$barLocation"]!/total) * 10).round() * 100;
          if (colorShade > 900) {
            colorShade = 900;
          }
          if (colorShade < 100) {
            colorShade = 100;
          }
          ret.add(_bar(color: Colors.green[colorShade]!, borderColor: Colors.green.shade50));
        }
        else {
          ret.add(_bar(color: Colors.transparent, borderColor: primaryLight));  
        }
      }
      else {
        ret.add(_bar(color: Colors.transparent, borderColor: primaryLight));
      }
    }

    return ret;
  }

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

  Widget _avgBox({required double? percentage}) {
    Color textColor = textPrimary;
    String text = formatDecimalWithNull(percentage, decimal: 2);

    if ((percentage ?? 0) > 0) {
      textColor = Colors.green;
    }
    if ((percentage ?? 0) < 0) {
      textColor = secondaryColor;
    }

    return Container(
      margin: const EdgeInsets.fromLTRB(0, 0, 0, 5),
      height: 20,
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          "$text%",
          style: TextStyle(
            fontSize: 8,
            color: textColor
          ),
        ),
      ),
    );
  }

  int _totalCount({required WeekdayData? weekdayData}) {
    if (weekdayData == null) {
      return 0;
    }

    int count = 0;
    weekdayData.list.forEach((key, data) {
      count += data;
    },);

    return count;
  }
}