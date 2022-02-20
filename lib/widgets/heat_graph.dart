import 'package:flutter/material.dart';
import 'package:my_wealth/model/user_login.dart';
import 'package:my_wealth/themes/colors.dart';
import 'package:my_wealth/utils/function/date_utils.dart';
import 'package:my_wealth/utils/function/risk_color.dart';

class GraphData {
  final DateTime date;
  final double price;

  const GraphData({required this.date, required this.price});
}

class HeatGraph extends StatelessWidget {
  final Widget? title;
  final List<GraphData> data;
  final UserLoginInfoModel userInfo;
  const HeatGraph({ Key? key, this.title, required this.data, required this.userInfo }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final List<String> _weekDayName = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri'];
    bool _isTitleShow = false;

    if(title != null) {
      _isTitleShow = true;
    }

    return Container(
      padding: const EdgeInsets.all(5),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          Visibility(
            visible: _isTitleShow,
            child: Center(
              child: title,
            )
          ),
          Visibility(
            visible: _isTitleShow,
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
                  children: List<Widget>.generate(5, (index) {
                    return Container(
                      height: 10,
                      margin: const EdgeInsets.all(5),
                      child: Text(
                        _weekDayName[index],
                        style: const TextStyle(
                          fontSize: 10,
                        ),
                      ),
                    );
                  }),
                ),
              ),
              ..._generateRows(),
            ],
          ),
        ],
      ),
    );
  }

  List<Widget> _generateRows() {
    List<Widget> _return = [];
    int i = 0;
    int _totalData = 0;

    // history data
    double _prevPrice = -1;
    Color _boxColor;
    
    // totalData will be number of here + 5, as we will ended on the next loop of 5
    // before we perform check on total data again.
    while(_totalData < 70) {
      // do we still have data?
      if(i<data.length) {
        // we will only do if the date of weekday is below 5
        if (data[i].date.weekday <= 5) {
          // do this as this is weekday
          List<Widget> _boxes = _generateBoxes(primaryDark);

          // get the label that we will put on this graph based on the
          // 1st day that we will process
          int _weekNumber = weekNumber(data[i].date);
          int _year = data[i].date.year;

          // now loop from this weekday until friday, in case this is friday
          // then it will be only loop once
          for (var day=data[i].date.weekday; day <= 5 && i < data.length; day++, i++, _totalData++) {
            // change the box data with the current data
            // generate the color
            if(_prevPrice > 0) {
              _boxColor = riskColor(data[i].price, _prevPrice, userInfo.risk);
            }
            else {
              _boxColor = Colors.white;
            }
            _boxes[day-1] = _generateBox(_boxColor);
            _prevPrice = data[i].price;
          }
          
          // last box will be put with text
          _boxes.add(Container(
            width: 10,
            margin: const EdgeInsets.all(5),
            child: RotatedBox(
              quarterTurns: 1,
              child: Text(
                "Week " + _weekNumber.toString() + " of " + _year.toString(),
                style: const TextStyle(
                  fontSize: 10,
                ),
              ),
            ),
          ));

          // end of this week, so add this to the return variable
          _return.add(_generateBoxColumn(_boxes));
        }
        else {
          // skip this data
          i += 1;
        }
      }
      else {
        // no more data, so here we can just print black boxes
        _return.add(_generateBoxColumn(_generateBoxes(primaryDark)));
        _totalData += 5;
      }
    }

    return _return;
  }

  Widget _generateBox(Color boxColor) {
    return Container(
      width: 10,
      height: 10,
      margin: const EdgeInsets.all(5),
      color: boxColor,
    );
  }

  List<Widget> _generateBoxes(Color boxColor) {
    return List<Widget>.generate(5, (index) {
      return _generateBox(boxColor);
    });
  }

  Widget _generateBoxColumn(List<Widget> child) {
    return SizedBox(
      width: 20,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: child,
      ),
    );
  }
}