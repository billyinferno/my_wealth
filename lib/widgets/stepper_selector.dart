import 'package:flutter/material.dart';
import 'package:ionicons/ionicons.dart';
import 'package:my_wealth/themes/colors.dart';
import 'package:my_wealth/widgets/stepper_selector_controller.dart';

class StepperSelector extends StatefulWidget {
  final StepperSelectorController controller;
  final String title;
  final double? titleSize;
  final IconData icon;
  final Color iconColor;
  final double? iconSize;
  final int? defaultValue;
  final int? minValue;
  final int? maxValue;
  final double? width; 
  const StepperSelector({ Key? key, required this.controller, required this.title, this.titleSize, required this.icon, required this.iconColor, this.iconSize, this.defaultValue, this.minValue, this.maxValue, this.width }) : super(key: key);

  @override
  _StepperSelectorState createState() => _StepperSelectorState();
}

class _StepperSelectorState extends State<StepperSelector> {
  late double _titleSize = 18;
  late double _iconSize = 15;
  late double _width = 110;
  late int _currentValue = 0;
  late int _minValue = 1;
  late int _maxValue = 5;

  @override
  void initState() {
    super.initState();
    _minValue = (widget.minValue ?? 1);
    _maxValue = (widget.maxValue ?? 5);
    _currentValue = (widget.defaultValue ?? _minValue);
    _titleSize = (widget.titleSize ?? 18);
    _iconSize = (widget.iconSize ?? 15);
    _width = (widget.width ?? (_iconSize * _maxValue) + 25);
    widget.controller.changeValue(_currentValue);
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Text(
          widget.title,
          style: TextStyle(
            fontSize: _titleSize,
            fontFamily: '--apple-system',
          ),
        ),
        const SizedBox(width: 10,),
        GestureDetector(
          onTap: (() {
            if(_currentValue < _maxValue) {
              setState(() {                
                _currentValue = _currentValue + 1;
                widget.controller.changeValue(_currentValue);
              });
            }
          }),
          child: Container(
            width: 27,
            height: 27,
            decoration: BoxDecoration(
              border: Border.all(
                color: Colors.blue,
                width: 1.0,
                style: BorderStyle.solid,
              ),
              color: primaryColor,
            ),
            child: Icon(
              Ionicons.add,
              size: _iconSize,
              color: Colors.blue,
            ),
          ),
        ),
        Container(
          width: _width,
          padding: const EdgeInsets.all(5),
          decoration: BoxDecoration(
            border: Border.all(
              color: primaryColor,
              width: 1.0,
              style: BorderStyle.solid,
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: List<Widget>.generate(_currentValue, (index) {
              return Icon(
                widget.icon,
                color: widget.iconColor,
                size: _iconSize,
              );
            }),
          ),
        ),
        GestureDetector(
          onTap: (() {
            if(_currentValue > _minValue) {
              setState(() {                
                _currentValue = _currentValue - 1;
                widget.controller.changeValue(_currentValue);
              });
            }
          }),
          child: Container(
            width: 27,
            height: 27,
            decoration: BoxDecoration(
              border: Border.all(
                color: Colors.blue,
                width: 1.0,
                style: BorderStyle.solid,
              ),
              color: primaryColor,
            ),
            child: Icon(
              Ionicons.remove,
              size: _iconSize,
              color: Colors.blue,
            ),
          ),
        ),
      ],
    );
  }
}