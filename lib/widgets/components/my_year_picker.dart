import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:my_wealth/themes/_index.g.dart';

enum MyYearPickerCalendarType {
  single,
  range
}

// 14 is a common font size used to compute the effective text scale.
const double _fontSizeToScale = 14.0;

const int _yearPickerColumnCount = 3;
const double _yearPickerRowHeight = 52.0;
const int _minYears = 18;

class MyYearDateResult {
  final DateTime startDate;
  final DateTime endDate;

  const MyYearDateResult({
    required this.startDate,
    required this.endDate,
  });
}

class MyYearPicker extends StatefulWidget {
  final DateTime? currentDate;
  final MyYearPickerCalendarType type;
  final DateTime firstDate;
  final DateTime lastDate;
  final DateTime startDate;
  final DateTime? endDate; // this is only if we have range
  final ValueChanged<MyYearDateResult> onChanged;

  const MyYearPicker({
    super.key,
    this.currentDate,
    this.type = MyYearPickerCalendarType.single,
    required this.firstDate,
    required this.lastDate,
    required this.startDate,
    this.endDate, // this is only if we have range
    required this.onChanged,
  });

  @override
  State<MyYearPicker> createState() => _MyYearPickerState();
}

class _MyYearPickerState extends State<MyYearPicker> {
  ScrollController? _scrollController;
  final WidgetStatesController _statesController = WidgetStatesController();

  // default the start and end date to single year first
  late DateTime _startDate;
  late DateTime _endDate;
  late DateTime _currentDate;

  @override
  void initState() {
    super.initState();

    // check if we have currentDate or not?
    _currentDate = widget.currentDate ?? DateTime.now();

    // set start date
    _startDate = DateTime(widget.startDate.year, 1, 1);
    if (widget.endDate != null) {
      _endDate = DateTime(widget.endDate!.year, 12, 31);
    }
    else {
      _endDate = DateTime(widget.startDate.year, 12, 31);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.start,
      children: <Widget>[
        Divider(),
        Expanded(
          child: GridView.builder(
            controller: _scrollController,
            padding: const EdgeInsets.all(0),
            gridDelegate: _YearPickerGridDelegate(context),
            itemBuilder: _buildYearItem,
            itemCount: math.max(_itemCount, _minYears),
          ),
        ),
        Divider(),
        _saveButton(),
      ],
    );
  }

  int get _itemCount {
    return widget.lastDate.year - widget.firstDate.year + 1;
  }

  Widget _saveButton() {
    final double textScaleFactor =
        MediaQuery.textScalerOf(context).clamp(maxScaleFactor: 3.0).scale(_fontSizeToScale) /
        _fontSizeToScale;
    final double decorationHeight = 36.0 * textScaleFactor;

    if (widget.type == MyYearPickerCalendarType.single) {
      return const SizedBox.shrink();
    }

    // create the save button
    return Container(
      padding: const EdgeInsets.fromLTRB(0, 10, 0, 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          Expanded(
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                foregroundColor: textPrimary,
                textStyle: TextStyle(
                  color: textPrimary,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(decorationHeight / 2),
                )
              ),
              onPressed: (() {
                // pop the dialog
                Navigator.of(context).pop();
              }),
              child: const Text("CANCEL"),
            ),
          ),
          const SizedBox(width: 10,),
          Expanded(
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: secondaryColor,
                foregroundColor: textPrimary,
                textStyle: TextStyle(
                  color: textPrimary,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(decorationHeight / 2),
                )
              ),
              onPressed: (() {
                widget.onChanged(MyYearDateResult(startDate: _startDate, endDate: _endDate));
              }),
              child: const Text("SAVE"),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildYearItem(BuildContext context, int index) {
    final DatePickerThemeData datePickerTheme = DatePickerTheme.of(context);
    final DatePickerThemeData defaults = DatePickerTheme.defaults(context);

    T? effectiveValue<T>(T? Function(DatePickerThemeData? theme) getProperty) {
      return getProperty(datePickerTheme) ?? getProperty(defaults);
    }

    T? resolve<T>(
      WidgetStateProperty<T>? Function(DatePickerThemeData? theme) getProperty,
      Set<WidgetState> states,
    ) {
      return effectiveValue((DatePickerThemeData? theme) {
        return getProperty(theme)?.resolve(states);
      });
    }

    final double textScaleFactor =
        MediaQuery.textScalerOf(context).clamp(maxScaleFactor: 3.0).scale(_fontSizeToScale) /
        _fontSizeToScale;

    // Backfill the _YearPicker with disabled years if necessary.
    final int offset = _itemCount < _minYears ? (_minYears - _itemCount) ~/ 2 : 0;
    final int year = widget.firstDate.year + index - offset;
    final bool isCurrentYear = year == _currentDate.year;
    final bool isDisabled = year < widget.firstDate.year || year > widget.lastDate.year;
    final double decorationHeight = 36.0 * textScaleFactor;

    // default the isSelected into false
    bool isSelected = false;
    // check whether this is being selected or not?
    if (widget.type == MyYearPickerCalendarType.range) {
      if (year >= _startDate.year && year <= _endDate.year) {
        isSelected = true;
      }
    }
    else {
      // for single if the start and end date in different year, then no need
      // to check the selected
      if (_startDate.year == _endDate.year) {
        // check if the year is the same
        if (year == _startDate.year) {
          isSelected = true;
        }
      }
    }

    final Set<WidgetState> states = <WidgetState>{
      if (isDisabled) WidgetState.disabled,
      if (isSelected) WidgetState.selected,
    };

    final Color? textColor = resolve<Color?>(
      (DatePickerThemeData? theme) =>
          isCurrentYear ? theme?.todayForegroundColor : theme?.yearForegroundColor,
      states,
    );

    // generate the background color based on whether it's being selected or not?
    final Color? background = resolve<Color?>(
      (DatePickerThemeData? theme) =>
          isCurrentYear ? theme?.todayBackgroundColor : theme?.yearBackgroundColor,
      states,
    );
    final WidgetStateProperty<Color?> overlayColor = WidgetStateProperty.resolveWith<Color?>(
      (Set<WidgetState> states) =>
          effectiveValue((DatePickerThemeData? theme) => theme?.yearOverlayColor?.resolve(states)),
    );

    BoxBorder? border;
    if (isCurrentYear && !isSelected) {
      final BorderSide? todayBorder = datePickerTheme.todayBorder ?? defaults.todayBorder;
      if (todayBorder != null) {
        border = Border.fromBorderSide(todayBorder.copyWith(color: textColor));
      }
    }

    // calculate the radius
    BorderRadius? radius;
    if (
      (_startDate.year == year && _endDate.year == year) ||
      (isCurrentYear && widget.type == MyYearPickerCalendarType.single) ||
      (isCurrentYear && !isSelected && widget.type == MyYearPickerCalendarType.range)
    ) {
      radius = BorderRadius.circular(decorationHeight / 2);
    }
    else {
      if (_startDate.year == year) {
        radius = BorderRadius.only(
          topLeft: Radius.circular(decorationHeight / 2),
          bottomLeft: Radius.circular(decorationHeight / 2),
        );
      }
      else if (_endDate.year == year) {
        radius = BorderRadius.only(
          topRight: Radius.circular(decorationHeight / 2),
          bottomRight: Radius.circular(decorationHeight / 2),
        );
      }
    }

    final BoxDecoration decoration = BoxDecoration(
      border: border,
      color: background,
      borderRadius: radius,
    );

    final TextStyle? itemStyle = (datePickerTheme.yearStyle ?? defaults.yearStyle)?.apply(
      color: textColor,
    );
    
    Widget yearItem = Center(
      child: Container(
        decoration: decoration,
        height: decorationHeight,
        alignment: Alignment.center,
        child: Semantics(
          selected: isSelected,
          button: true,
          child: Text(year.toString(), style: itemStyle),
        ),
      ),
    );

    if (isDisabled) {
      yearItem = ExcludeSemantics(child: yearItem);
    } else {
      _statesController.value = states;
      yearItem = InkWell(
        key: ValueKey<int>(year),
        onTap: () {
          // check what is the current type, whether this is single or range?
          if (widget.type == MyYearPickerCalendarType.single) {
            // this is single
            _startDate = DateTime(year, 1, 1);
            _endDate = DateTime(year, 12, 31);
            widget.onChanged(MyYearDateResult(startDate: _startDate, endDate: _endDate));
          }
          else {
            // rebuild the widget
            setState(() {
              // this is range
              // check if this year is the same as start date or end date
              if (year == _startDate.year) {
                // then set the end date same as start year
                _endDate = DateTime(_startDate.year, 12, 31);
              }
              else if (year == _endDate.year) {
                // then  set the start year same as the end year
                _startDate = DateTime(_endDate.year, 1, 1);
              }
              else {
                // check normally the year
                if (_startDate.year > year) {
                  // change the start date
                  _startDate = DateTime(year, 1, 1);
                }
                else {
                  // it means we need to change the _endDate
                  _endDate = DateTime(year, 12, 31);
                }
              }
            });
          }
        },
        statesController: _statesController,
        overlayColor: overlayColor,
        child: yearItem,
      );
    }

    return yearItem;
  }
}

class _YearPickerGridDelegate extends SliverGridDelegate {
  const _YearPickerGridDelegate(this.context);

  final BuildContext context;

  @override
  SliverGridLayout getLayout(SliverConstraints constraints) {
    final double textScaleFactor =
        MediaQuery.textScalerOf(context).clamp(maxScaleFactor: 3.0).scale(_fontSizeToScale) /
        _fontSizeToScale;
    final int scaledYearPickerColumnCount =
        textScaleFactor > 1.65 ? _yearPickerColumnCount - 1 : _yearPickerColumnCount;
    final double tileWidth =
        (constraints.crossAxisExtent - (scaledYearPickerColumnCount - 1)) /
        scaledYearPickerColumnCount;
    final double scaledYearPickerRowHeight =
        textScaleFactor > 1
            ? _yearPickerRowHeight + ((textScaleFactor - 1) * 9)
            : _yearPickerRowHeight;
    return SliverGridRegularTileLayout(
      childCrossAxisExtent: tileWidth,
      childMainAxisExtent: scaledYearPickerRowHeight,
      crossAxisCount: scaledYearPickerColumnCount,
      crossAxisStride: tileWidth,
      mainAxisStride: scaledYearPickerRowHeight,
      reverseCrossAxis: axisDirectionIsReversed(constraints.crossAxisDirection),
    );
  }

  @override
  bool shouldRelayout(_YearPickerGridDelegate oldDelegate) => false;
}