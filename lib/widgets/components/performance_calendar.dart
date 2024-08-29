import 'package:flutter/material.dart';
import 'package:my_wealth/_index.g.dart';

class CalendarDatePL {
  final String date;
  final double? pl;
  final double? plRatio;

  const CalendarDatePL({
    required this.date,
    this.pl,
    this.plRatio
  });
}

enum PerformanceCalendarType { monthYear, year }

class PerformanceCalendar extends StatelessWidget {
  final int month;
  final int year;
  final List<CalendarDatePL> data;
  final PerformanceCalendarType type;
  const PerformanceCalendar({
    super.key,
    required this.month,
    required this.year,
    required this.data,
    required this.type
  });

  @override
  Widget build(BuildContext context) {
    switch(type) {
      case PerformanceCalendarType.monthYear:
        return _monthYear();
      case PerformanceCalendarType.year:
        return _year();
      default:
        return _monthYear();
    }
  }

  Widget _monthYear() {
    return Container(
      padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          Container(
            padding: const EdgeInsets.fromLTRB(0, 0, 0, 5),
            width: double.infinity,
            decoration: const BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: primaryLight,
                  width: 1.0,
                  style: BorderStyle.solid,
                )
              ),
            ),
            child: const Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                Expanded(child: Center(child: Text("Mon"))),
                Expanded(child: Center(child: Text("Tue"))),
                Expanded(child: Center(child: Text("Wed"))),
                Expanded(child: Center(child: Text("Thu"))),
                Expanded(child: Center(child: Text("Fri"))),
                Expanded(child: Center(child: Text("Sat"))),
                Expanded(child: Center(child: Text("Sun"))),
              ],
            ),
          ),
          _dateRow(dateList: data, start: 0),
          _dateRow(dateList: data, start: 7),
          _dateRow(dateList: data, start: 14),
          _dateRow(dateList: data, start: 21),
          _dateRow(dateList: data, start: 28),
          _dateRow(dateList: data, start: 35),
        ],
      ),
    );
  }

  Widget _year() {
    return Container(
      padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          _monthRow(dateList: data, start: 0),
          _monthRow(dateList: data, start: 6),
        ],
      ),
    );
  }

  Widget _dateRow({
    required List<CalendarDatePL> dateList,
    required int start
  }) {
    
    // check if all the date list from this is have data?
    // if have then we generate the correct calendar, otherwise
    // just return SizedBox.shrink
    String checkData = "";
    for(int i=start; i<=(start+6); i++) {
      checkData += dateList[i].date;
    }

    // check the string length
    if (checkData.trim().isEmpty) {
      return const SizedBox.shrink();
    }

    // we have data, so generate the correct calendar
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(0, 10, 0, 5),
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: primaryLight,
            width: 1.0,
            style: BorderStyle.solid,
          )
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: List<Widget>.generate(7, (index) {
          Color plColor = primaryLight;
          Color plRatioColor = primaryLight;
          
          if ((dateList[start+index].pl ?? 0) > 0) {
            plColor = Colors.green;
          }
          else if ((dateList[start+index].pl ?? 0) < 0) {
            plColor = secondaryColor;
          }

          if ((dateList[start+index].plRatio ?? 0) > 0) {
            plRatioColor = Colors.green;
          }
          else if ((dateList[start+index].plRatio ?? 0) < 0) {
            plRatioColor = secondaryColor;
          }

          return _calendarItem(
            text: dateList[start+index].date,
            pl: dateList[start+index].pl,
            plColor: plColor,
            plRatio: dateList[start+index].plRatio,
            plRatioColor: plRatioColor,
          );
        }),
      ),
    );
  }

  Widget _monthRow({
    required List<CalendarDatePL> dateList,
    required int start
  }) {
    // generate the month row
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(0, 10, 0, 5),
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: primaryLight,
            width: 1.0,
            style: BorderStyle.solid,
          )
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: List<Widget>.generate(6, (index) {
          Color plColor = primaryLight;
          Color plRatioColor = primaryLight;
          
          if ((dateList[start+index].pl ?? 0) > 0) {
            plColor = Colors.green;
          }
          else if ((dateList[start+index].pl ?? 0) < 0) {
            plColor = secondaryColor;
          }

          if ((dateList[start+index].plRatio ?? 0) > 0) {
            plRatioColor = Colors.green;
          }
          else if ((dateList[start+index].plRatio ?? 0) < 0) {
            plRatioColor = secondaryColor;
          }

          return _calendarItem(
            text: dateList[start+index].date,
            pl: dateList[start+index].pl,
            plColor: plColor,
            plRatio: dateList[start+index].plRatio,
            plRatioColor: plRatioColor,
          );
        }),
      ),
    );
  }

  Widget _calendarItem({
    required String text,
    required double? pl,
    Color? plColor,
    required double? plRatio,
    Color? plRatioColor,
  }) {
    // ensure we have text, if not then just return expanded with sized box only
    if (text.trim().isEmpty) {
      return const Expanded(child: SizedBox.shrink(),);
    }

    // we have text, show the correct calendar data
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text(text),
          const SizedBox(height: 5,),
          Text(
            formatCurrencyWithNull(
              pl,
              checkThousand: true,
              showDecimal: true,
              shorten: true,
              decimalNum: 2
            ),
            style: TextStyle(
              fontSize: 10,
              color: (plColor ?? primaryLight),
            ),
          ),
          Text(
            "${formatDecimalWithNull(
              plRatio,
              times: 1,
              decimal: 2,
            )}${plRatio != null ? "%" : ""}",
            style: TextStyle(
              fontSize: 10,
              color: (plRatioColor ?? primaryLight),
            ),
          ),
        ],
      ),
    );
  }
}