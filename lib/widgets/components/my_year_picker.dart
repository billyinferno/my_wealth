import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

enum MyYearPickerCalendarType {
  single,
  range
}

// 14 is a common font size used to compute the effective text scale.
const double _fontSizeToScale = 14.0;

const int _yearPickerColumnCount = 3;
const double _yearPickerRowHeight = 52.0;
const double _yearPickerRowSpacing = 8.0;
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
  DateTime _startDate = DateTime(DateTime.now().year, 1, 1);
  DateTime _endDate = DateTime(DateTime.now().year, 12, 31);
  DateTime? _currentDate;

  @override
  void initState() {
    super.initState();

    // check if we have currentDate or not?
    _currentDate = widget.currentDate ?? DateTime.now();
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
            gridDelegate: _YearPickerGridDelegate(context),
            itemBuilder: _buildYearItem,
            itemCount: math.max(_itemCount, _minYears),
          ),
        ),
        Divider(),
      ],
    );
  }

  int get _itemCount {
    return widget.lastDate.year - widget.firstDate.year + 1;
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
    final bool isCurrentYear = year == _currentDate!.year;
    final bool isDisabled = year < widget.firstDate.year || year > widget.lastDate.year;
    final double decorationHeight = 36.0 * textScaleFactor;
    final double decorationWidth = 72.0 * textScaleFactor;

    final Set<WidgetState> states = <WidgetState>{
      if (isDisabled) WidgetState.disabled,
    };

    final Color? textColor = resolve<Color?>(
      (DatePickerThemeData? theme) =>
          isCurrentYear ? theme?.todayForegroundColor : theme?.yearForegroundColor,
      states,
    );
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
    if (isCurrentYear) {
      final BorderSide? todayBorder = datePickerTheme.todayBorder ?? defaults.todayBorder;
      if (todayBorder != null) {
        border = Border.fromBorderSide(todayBorder.copyWith(color: textColor));
      }
    }
    final BoxDecoration decoration = BoxDecoration(
      border: border,
      color: background,
      borderRadius: BorderRadius.circular(decorationHeight / 2),
    );

    final TextStyle? itemStyle = (datePickerTheme.yearStyle ?? defaults.yearStyle)?.apply(
      color: textColor,
    );
    Widget yearItem = Center(
      child: Container(
        decoration: decoration,
        height: decorationHeight,
        width: decorationWidth,
        alignment: Alignment.center,
        child: Semantics(
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
            // this is range
            // means that we need to know whether this is before or after the start and end date
            if (_startDate.year > year) {
              // change the start date
              _startDate = DateTime(year, 1, 1);
            }
            else {
              // it means we need to change the _endDate
              _endDate = DateTime(year, 12, 31);
            }

            widget.onChanged(MyYearDateResult(startDate: _startDate, endDate: _endDate));
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
        (constraints.crossAxisExtent - (scaledYearPickerColumnCount - 1) * _yearPickerRowSpacing) /
        scaledYearPickerColumnCount;
    final double scaledYearPickerRowHeight =
        textScaleFactor > 1
            ? _yearPickerRowHeight + ((textScaleFactor - 1) * 9)
            : _yearPickerRowHeight;
    return SliverGridRegularTileLayout(
      childCrossAxisExtent: tileWidth,
      childMainAxisExtent: scaledYearPickerRowHeight,
      crossAxisCount: scaledYearPickerColumnCount,
      crossAxisStride: tileWidth + _yearPickerRowSpacing,
      mainAxisStride: scaledYearPickerRowHeight,
      reverseCrossAxis: axisDirectionIsReversed(constraints.crossAxisDirection),
    );
  }

  @override
  bool shouldRelayout(_YearPickerGridDelegate oldDelegate) => false;
}