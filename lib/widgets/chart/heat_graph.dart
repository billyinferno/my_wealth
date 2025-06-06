import 'package:flutter/material.dart';
import 'package:my_wealth/_index.g.dart';

class GraphData {
  final DateTime date;
  final double price;

  const GraphData({required this.date, required this.price});
}

class HeatGraph extends StatelessWidget {
  final Widget? title;
  final double currentPrice;
  final Map<DateTime, GraphData> data;
  final bool? enableDailyComparison;
  final UserLoginInfoModel userInfo;
  final bool? weekend;
  const HeatGraph({
    super.key,
    this.title,
    required this.currentPrice,
    required this.data,
    required this.userInfo,
    this.enableDailyComparison,
    this.weekend
  });

  @override
  Widget build(BuildContext context) {
    bool isTitleShow = false;
    bool showWeekend = (weekend ?? false);

    if(title != null) {
      isTitleShow = true;
    }

    return Container(
      padding: const EdgeInsets.all(5),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          Visibility(
            visible: isTitleShow,
            child: Center(
              child: title,
            )
          ),
          Visibility(
            visible: isTitleShow,
            child: const SizedBox(height: 10,)
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              SizedBox(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: List<Widget>.generate((showWeekend ? 7 : 5), (index) {
                    return Container(
                      height: 10,
                      margin: const EdgeInsets.all(5),
                      child: Text(
                        Globals.shortWeekdayName[index],
                        style: const TextStyle(
                          fontSize: 9,
                        ),
                      ),
                    );
                  }),
                ),
              ),
              ..._generateRows(showWeekend: showWeekend),
            ],
          ),
        ],
      ),
    );
  }

  List<GraphData> _expandData() {
    // we need to expand data incase that there are gap on date, because the heat graph
    // expect to get all the date without skipping. So what we can do is to expand the
    // date given to exactly 91 days (65/5) * 7.

    List<GraphData> dataExpand = [];

    // first get the 1st date
    DateTime firstDate = data.keys.last.add(const Duration(days: -90));

    for(int day=0; day<91; day++) {
      DateTime keys = firstDate.add(Duration(days: day));
      // check if exists?
      if(data.containsKey(keys)) {
        dataExpand.add(GraphData(date: keys, price: data[keys]!.price));
      }
      else {
        dataExpand.add(GraphData(date: keys, price: -1));
      }
    }

    return dataExpand;
  }

  List<Widget> _generateRows({required bool showWeekend}) {
    final bool isEnableDailyComparison = (enableDailyComparison ?? false);

    List<Widget> response = [];
    int i = 0;
    int totalData = 0;
    int maxData = (showWeekend ? 91 : 65);
    int loopLimit = (showWeekend ? 7 : 5);

    // history data
    double prevPrice = -1;
    Color boxColor;

    // before we do, let's expand the data first
    List<GraphData> dataExpand = _expandData();
    
    // totalData will be number of here + 5, as we will ended on the next loop of 5
    // before we perform check on total data again.
    while(totalData < maxData) {
      // do we still have data?
      if(i<dataExpand.length) {
        // we will only do if the date of weekday is below 5
        if (dataExpand[i].date.weekday <= loopLimit) {
          // do this as this is weekday
          List<Widget> boxes = _generateBoxes(
            numBox: loopLimit,
            boxColor: primaryDark,
          );

          // get the label that we will put on this graph based on the
          // 1st day that we will process
          DateTime startDate = dataExpand[i].date;
          DateTime? endDate;

          // now loop from this weekday until friday, in case this is friday
          // then it will be only loop once
          for (var day=dataExpand[i].date.weekday; day <= loopLimit && i < dataExpand.length; day++, i++, totalData++) {
            if(dataExpand[i].price > 0) {
              // change the box data with the current data
              // generate the color
              if(prevPrice > 0) {
                boxColor = riskColor(
                  value: dataExpand[i].price,
                  cost: prevPrice,
                  riskFactor: userInfo.risk
                );
              }
              else {
                boxColor = Colors.white;
              }
              prevPrice = dataExpand[i].price;
            }
            else {
              boxColor = primaryDark;
            }
            
            // check for the foreground color
            if (isEnableDailyComparison) {
              if(currentPrice == dataExpand[i].price) {
                boxColor = Colors.white;
              }
              else {
                if(currentPrice > 0 && dataExpand[i].price > 0) {
                  boxColor = riskColor(
                    value: currentPrice,
                    cost: dataExpand[i].price,
                    riskFactor: userInfo.risk
                  );
                }
              }
            }

            boxes[day-1] = _generateBox(
              boxColor: boxColor,
              decorationColor: Colors.transparent,
            );
            endDate = dataExpand[i].date;
          }
          
          // last box will be put with text
          boxes.add(Container(
            width: 10,
            margin: const EdgeInsets.all(5),
            child: RotatedBox(
              quarterTurns: 1,
              child: Text(
                "${Globals.dfddMM.formatLocal(startDate)} - ${Globals.dfddMM.formatDateWithNull(endDate)}",
                style: const TextStyle(
                  fontSize: 9,
                ),
              ),
            ),
          ));

          // end of this week, so add this to the return variable
          response.add(_generateBoxColumn(childs: boxes));
        }
        else {
          // skip this data
          i += 1;
        }
      }
      else {
        // no more data, so here we can just print black boxes
        response.add(_generateBoxColumn(
          childs: _generateBoxes(
            numBox: loopLimit,
            boxColor: primaryDark,
          )
        ));
        totalData += 5;
      }
    }

    return response;
  }

  Widget _generateBox({
    required Color boxColor,
    required Color decorationColor
  }) {
    return Container(
      width: 18,
      height: 18,
      margin: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        color: boxColor,
        borderRadius: BorderRadius.circular(6)
      ),
    );
  }

  List<Widget> _generateBoxes({
    required int numBox,
    required Color boxColor
  }) {
    return List<Widget>.generate(numBox, (index) {
      return _generateBox(
        boxColor: boxColor,
        decorationColor: Colors.transparent,
      );
    });
  }

  Widget _generateBoxColumn({required List<Widget> childs}) {
    return SizedBox(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: childs,
      ),
    );
  }
}