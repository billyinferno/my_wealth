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
    }
  }

  Widget _monthYear() {
    // generate all the data needed
    List<CalendarDatePL> generatedData = List<CalendarDatePL>.generate(42, (index) {
      return CalendarDatePL(
        date: "",
      );
    },);

    // generate the actual date
    int startWeekday = DateTime(year, month, 1).weekday - 1;
    int maxDate = DateTime(year, month + 1, 1).subtract(Duration(days: 1)).day;

    // replace the generated data with correct date to be showed
    for (int i=0; i<maxDate; i++) {
      generatedData[startWeekday + i] = CalendarDatePL(
        date: (i+1).toString(),
      );
    }

    // loop thru the data and replace the generatedData with data
    int currentDay;
    for(int i=0; i<data.length; i++) {
      // convert the current date
      currentDay = (int.tryParse(data[i].date) ?? 0);
      generatedData[startWeekday + currentDay - 1] = data[i];
    }

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
          _dateRow(dateList: generatedData, start: 0),
          _dateRow(dateList: generatedData, start: 7),
          _dateRow(dateList: generatedData, start: 14),
          _dateRow(dateList: generatedData, start: 21),
          _dateRow(dateList: generatedData, start: 28),
          _dateRow(dateList: generatedData, start: 35),
        ],
      ),
    );
  }

  Widget _year() {
    // generate all the data needed
    List<CalendarDatePL> generatedData = List<CalendarDatePL>.generate(12, (index) {
      return CalendarDatePL(
        date: Globals.dfMMM.formatLocal(
          DateTime(
            year,
            (index + 1),
            1
          )
        ),
      );
    },);

    // for year we will need to knew the length of the data given, so we knew
    // that we should start from which month?
    int startIndex = 0;

    // check if the first month in the data is not 1, if not then we need
    // to calculate which month we will need to start
    if (data.first.date.toLowerCase() != 'jan') {
      startIndex = 12 - data.length;
    }

    // loop thru the data and replace the generatedData with data
    for(int i=0; i<data.length; i++) {
      generatedData[startIndex + i] = data[i];
    }

    return Container(
      padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          _monthRow(dateList: generatedData, start: 0),
          _monthRow(dateList: generatedData, start: 6),
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