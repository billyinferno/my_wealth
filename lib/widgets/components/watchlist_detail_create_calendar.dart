import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:my_wealth/themes/colors.dart';
import 'package:my_wealth/utils/animation/animation_expand.dart';
import 'package:my_wealth/utils/globals.dart';

class WatchlistDetailCreateCalendar extends StatefulWidget {
  final Function(DateTime) onDateChange;
  final DateTime? initialDate;
  const WatchlistDetailCreateCalendar({ super.key, required this.onDateChange, this.initialDate });

  @override
  WatchlistDetailCreateCalendarState createState() => WatchlistDetailCreateCalendarState();
}

class WatchlistDetailCreateCalendarState extends State<WatchlistDetailCreateCalendar> {
  bool _isDateVisible = false;
  late DateTime _selectedDate;

  @override
  void initState() {
    super.initState();

    // initialize variable
    _isDateVisible = false;
    _selectedDate = (widget.initialDate ?? DateTime.now());
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.start,
      children: <Widget>[
        // start the form here
        InkWell(
          onTap: (() {
            setState(() {
              _isDateVisible = !_isDateVisible;
            });
          }),
          child: Container(
            padding: const EdgeInsets.fromLTRB(10, 20, 10, 20),
            decoration: const BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: primaryLight,
                  width: 1.0,
                  style: BorderStyle.solid,
                )
              )
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                const Text(
                  "Date",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: secondaryLight,
                  ),
                ),
                const SizedBox(width: 10,),
                Expanded(
                  child: Text(
                    Globals.dfddMMyyyy.format(_selectedDate.toLocal()),
                    textAlign: TextAlign.right,
                  ),
                ),
              ],
            ),
          ),
        ),
        AnimationExpand(
          expand: _isDateVisible,
          child: Container(
            height: 200,
            padding: const EdgeInsets.all(10),
            decoration: const BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: primaryLight,
                  width: 1.0,
                  style: BorderStyle.solid,
                )
              )
            ),
            child: CupertinoTheme(
              data: const CupertinoThemeData(
                brightness: Brightness.dark,
                textTheme: CupertinoTextThemeData(
                  textStyle: TextStyle(
                    fontFamily: '--apple-system',
                    fontSize: 20,
                  ),
                  dateTimePickerTextStyle: TextStyle(
                    fontFamily: '--apple-system',
                    fontSize: 20,
                  ),
                )
              ),
              child: CupertinoDatePicker(
                initialDateTime: _selectedDate.toLocal(),
                mode: CupertinoDatePickerMode.date,
                onDateTimeChanged: ((newDate) {
                  setState(() {
                    _selectedDate = newDate;
                  });
                  widget.onDateChange(newDate);
                }),
              ),
            ),
          ),
        ),
      ],
    );
  }
}