import 'package:flutter/material.dart';
import 'package:my_wealth/themes/colors.dart';

class ScrollSegmentedControl extends StatefulWidget {
  final Map<String, String> data;
  final Color? borderColor;
  final Color? bgColor;
  final Color? textColor;
  final Color? selectedBgColor;
  final Color? selectedTextColor;
  final Function(String) onPress;
  const ScrollSegmentedControl({super.key, required this.data, this.borderColor, this.bgColor, this.textColor, this.selectedBgColor, this.selectedTextColor, required this.onPress});

  @override
  State<ScrollSegmentedControl> createState() => ScrollSegmentedControlState();
}

class ScrollSegmentedControlState extends State<ScrollSegmentedControl> {
  final ScrollController _scrollController = ScrollController();
  late Color _borderColor;
  late Color _bgColor;
  late Color _textColor;
  late Color _selectedBgColor;
  late Color _selectedTextColor;
  late BorderSide _borderSide;
  late String _selectedValue;

  @override
  void initState() {
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
    _selectedValue = widget.data.keys.first;

    super.initState();
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
              const SizedBox(width: 30,),
              ..._generateSegment(),
              const SizedBox(width: 30,)
            ],
          ),
        ),
        Align(
          alignment: Alignment.centerLeft,
          child: Container(
            width: 30,
            height: 32,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
                colors: <Color>[
                  primaryColor,
                  primaryColor.withOpacity(0),
                ]
              )
            ),
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
                  primaryColor.withOpacity(0),
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