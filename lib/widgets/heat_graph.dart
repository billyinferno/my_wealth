import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:my_wealth/model/user_login.dart';
import 'package:my_wealth/themes/colors.dart';
import 'package:my_wealth/utils/function/risk_color.dart';

class GraphData {
  final DateTime date;
  final double price;

  const GraphData({required this.date, required this.price});
}

class HeatGraph extends StatelessWidget {
  final Widget? title;
  final Map<DateTime, GraphData> data;
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

  List<GraphData> _expandData() {
    // we need to expand data incase that there are gap on date, because the heat graph
    // expect to get all the date without skipping. So what we can do is to expand the
    // date given to exactly 91 days (65/5) * 7.

    List<GraphData> _dataExpand = [];

    // first get the 1st keys
    DateTime _firstDate = data.keys.first;

    for(int day=0; day<91; day++) {
      DateTime _keys = _firstDate.add(Duration(days: day));
      // check if exists?
      if(data.containsKey(_keys)) {
        _dataExpand.add(GraphData(date: _keys, price: data[_keys]!.price));
      }
      else {
        _dataExpand.add(GraphData(date: _keys, price: -1));
      }
    }

    return _dataExpand;
  }

  List<Widget> _generateRows() {
    final DateFormat _df = DateFormat("dd/MMM");

    List<Widget> _return = [];
    int i = 0;
    int _totalData = 0;

    // history data
    double _prevPrice = -1;
    Color _boxColor;

    // before we do, let's expand the data first
    List<GraphData> _dataExpand = _expandData();
    
    // totalData will be number of here + 5, as we will ended on the next loop of 5
    // before we perform check on total data again.
    while(_totalData < 65) {
      // do we still have data?
      if(i<_dataExpand.length) {
        // we will only do if the date of weekday is below 5
        if (_dataExpand[i].date.weekday <= 5) {
          // do this as this is weekday
          List<Widget> _boxes = _generateBoxes(primaryDark);

          // get the label that we will put on this graph based on the
          // 1st day that we will process
          // int _weekNumber = weekNumber(_dataExpand[i].date);
          DateTime _startDate = _dataExpand[i].date;
          DateTime? _endDate;

          // now loop from this weekday until friday, in case this is friday
          // then it will be only loop once
          for (var day=_dataExpand[i].date.weekday; day <= 5 && i < _dataExpand.length; day++, i++, _totalData++) {
            // debugPrint(_dataExpand[i].date.toString());
            if(_dataExpand[i].price > 0) {
              // change the box data with the current data
              // generate the color
              if(_prevPrice > 0) {
                _boxColor = riskColor(_dataExpand[i].price, _prevPrice, userInfo.risk);
              }
              else {
                _boxColor = Colors.white;
              }
              _prevPrice = _dataExpand[i].price;
            }
            else {
              _boxColor = primaryDark;
            }
            
            _boxes[day-1] = _generateBox(_boxColor);
            _endDate = _dataExpand[i].date;
          }
          // debugPrint("--- END OF WEEK ---");
          
          // last box will be put with text
          _boxes.add(Container(
            width: 10,
            margin: const EdgeInsets.all(5),
            child: RotatedBox(
              quarterTurns: 1,
              child: Text(
                // "Week " + _weekNumber.toString() + " (" + _monthName[_month-1] + ")",
                _df.format(_startDate) + " - " + _df.format(_endDate!),
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