import 'package:flutter/material.dart';
import 'package:my_wealth/_index.g.dart';

class LineChart extends StatelessWidget {
  final List<GraphData> data;
  final List<GraphData>? compare;
  final List<DateTime>? dividend;
  final Map<DateTime, int>? watchlist;
  final double? height;
  final bool? showLegend;
  final int? dateOffset;
  final bool fillDate;
  final bool onlyWeekday;
  const LineChart({
    super.key,
    required this.data,
    this.compare,
    this.dividend,
    this.height,
    this.watchlist,
    this.showLegend,
    this.dateOffset,
    this.fillDate = false,
    this.onlyWeekday = true,
  });

  @override
  Widget build(BuildContext context) {
    double chartHeight = (height ?? 250);
    bool isShowLegend = (showLegend ?? true);

    List<GraphData> generatedData = [];
    if (fillDate) {
      // generate the data to fill all the date
      generatedData = _generateData();
    }
    else {
      // default the generated data into the data being sent from parent widget
      generatedData = data;
    }
    
    // get the date print offset based on the data length
    // try to calculate the datePrintOffset by checking from 2-10, which one
    // is the better date print offset
    int datePrintOffset = 1;
    if (dateOffset != null) {
      datePrintOffset = dateOffset!;
    }
    else {
      for(int i=2; i<=10; i++) {
        datePrintOffset = (generatedData.length ~/ i);
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
              data: generatedData,
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

  List<GraphData> _generateData() {
    List<GraphData> combineData = [];
    Map<DateTime, GraphData> mapData = {};

    // get the data first and last date
    DateTime firstDate = data.first.date;
    DateTime lastDate = data.last.date;

    // first convert data to map
    for(int i=0; i<data.length; i++) {
      mapData[data[i].date] = data[i];
    }

    // loop from first date to last date and check on the map, whether we have
    // this data or not? if not then use the previous day data for this
    GraphData? prevGraphData;
    bool skip = false;
    while (firstDate.isSameOrBefore(date: lastDate)) {
      // default skip to false
      skip = false;
      if (
        onlyWeekday &&
        (
          firstDate.weekday == DateTime.saturday ||
          firstDate.weekday == DateTime.sunday
        )
      ) {
        // skip the data
        skip = true; 
      }

      // check whether we need to skip this data or not?
      if (!skip) {
        // check if we have the data or not?
        if (mapData.containsKey(firstDate)) {
          // add this to the combine data
          combineData.add(mapData[firstDate]!);

          // set prevData as current data
          prevGraphData = mapData[firstDate]!;
        }
        else {
          if (prevGraphData != null) {
            // generate the new data to be added on the combine data based on the
            // previous data
            GraphData newGraphData = GraphData(
              date: firstDate,
              price: prevGraphData.price,
            );

            combineData.add(newGraphData);
          }
        }
      }

      // go to the next date
      firstDate = firstDate.add(Duration(days: 1));
    }
    return combineData;
  }
}