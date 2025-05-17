import 'package:flutter/material.dart';
import 'package:ionicons/ionicons.dart';
import 'package:my_wealth/_index.g.dart';

class ScrollSegmentedControl<T> extends StatefulWidget {
  final Map<T, String> data;
  final T? initialSelected;
  final Color? borderColor;
  final Color? bgColor;
  final Color? textColor;
  final Color? selectedBgColor;
  final Color? selectedTextColor;
  final Function(T) onPress;
  const ScrollSegmentedControl({
    super.key,
    required this.data,
    this.initialSelected,
    this.borderColor,
    this.bgColor,
    this.textColor,
    this.selectedBgColor,
    this.selectedTextColor,
    required this.onPress
  });

  @override
  State<ScrollSegmentedControl<T>> createState() => ScrollSegmentedControlState<T>();
}

class ScrollSegmentedControlState<T> extends State<ScrollSegmentedControl<T>> {
  final ScrollController _scrollController = ScrollController();
  late Color _borderColor;
  late Color _bgColor;
  late Color _textColor;
  late Color _selectedBgColor;
  late Color _selectedTextColor;
  late BorderSide _borderSide;
  late T _selectedValue;

  @override
  void initState() {
    super.initState();

    // set the color
    _borderColor = (widget.borderColor ?? secondaryColor);
    _bgColor = (widget.bgColor ?? Colors.white);
    _textColor = (widget.textColor ?? secondaryColor);
    _selectedBgColor = (widget.selectedBgColor ?? secondaryColor);
    _selectedTextColor = (widget.selectedTextColor ?? textPrimary);

    _borderSide = BorderSide(
      color: _borderColor,
      width: 1.0,
      style: BorderStyle.solid
    );

    // get the first element
    _selectedValue = (widget.initialSelected ?? widget.data.keys.first);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        SingleChildScrollView(
          controller: _scrollController,
          physics: const AlwaysScrollableScrollPhysics(),
          scrollDirection: Axis.horizontal,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              const SizedBox(width: 35,),
              ..._generateSegment(),
              const SizedBox(width: 30,)
            ],
          ),
        ),
        Align(
          alignment: Alignment.centerLeft,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              Container(
                width: 30,
                height: 32,
                decoration: const BoxDecoration(
                  color: primaryColor,
                  border: Border(
                    right: BorderSide(
                      color: secondaryColor,
                      width: 1.0,
                      style: BorderStyle.solid,
                    )
                  ),
                  // gradient: LinearGradient(
                  //   begin: Alignment.centerLeft,
                  //   end: Alignment.centerRight,
                  //   colors: <Color>[
                  //     primaryColor,
                  //     primaryColor.withValues(alpha: 0),
                  //   ]
                  // )
                ),
                child: const Icon(
                  Ionicons.code,
                  size: 15,
                  color: secondaryColor,
                ),
              ),
            ],
          ),
        ),
        Align(
          alignment: Alignment.centerRight,
          child: Container(
            width: 30,
            height: 32,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
                colors: <Color>[
                  primaryColor.withValues(alpha: 0),
                  primaryColor
                ]
              )
            ),
          ),
        ),
      ],
    );
  }

  List<Widget> _generateSegment() {
    final Border borderLeft = Border(
      left: _borderSide,
      right: _borderSide,
      top: _borderSide,
      bottom: _borderSide,
    );

    final Border borderRight = Border(
      top: _borderSide,
      bottom: _borderSide,
      right: _borderSide,
      left: _borderSide,
    );

    final Border borderMid = Border(
      top: _borderSide,
      bottom: _borderSide,
    );

    final Border borderMid2 = Border(
      top: _borderSide,
      bottom: _borderSide,
      right: _borderSide,
    );

    const BorderRadius borderRadiusLeft = BorderRadius.only(
      topLeft: Radius.circular(5),
      bottomLeft: Radius.circular(5),
    );

    const BorderRadius borderRadiusRight = BorderRadius.only(
      topRight: Radius.circular(5),
      bottomRight: Radius.circular(5),
    );

    List<Widget> ret = [];
    int i = 0;
    bool isBeforeLast = false;

    widget.data.forEach((key, value) {
      // use i as determine whether this is before last
      i = i + 1;
      if (i == (widget.data.length - 1)) {
        isBeforeLast = true;
      }

      BoxDecoration decor = BoxDecoration(
        border: (isBeforeLast ? borderMid : borderMid2),
        color: (_selectedValue == key ? _selectedBgColor : _bgColor),
      );

      if (key == widget.data.keys.first) {
        decor = BoxDecoration(
          border: borderLeft,
          color: (_selectedValue == key ? _selectedBgColor : _bgColor),
          borderRadius: borderRadiusLeft
        );
      }
      else if (key == widget.data.keys.last) {
        decor = BoxDecoration(
          border: borderRight,
          color: (_selectedValue == key ? _selectedBgColor : _bgColor),
          borderRadius: borderRadiusRight
        );
      }

      ret.add(
        GestureDetector(
          onTap: (() {
            widget.onPress(key);
            setState(() {
              _selectedValue = key;
            });
          }),
          child: Container(
            padding: const EdgeInsets.all(5),
            decoration: decor,
            child: Text(
              value,
              style: TextStyle(
                color: (_selectedValue == key ? _selectedTextColor : _textColor),
              ),
            ),
          ),
        )
      );
    });

    return ret;
  }
}