import 'package:flutter/material.dart';
import 'package:ionicons/ionicons.dart';
import 'package:my_wealth/themes/colors.dart';
import 'package:my_wealth/widgets/stepper_selector_controller.dart';

class StepperSelector extends StatefulWidget {
  final StepperSelectorController controller;
  final IconData icon;
  final Color iconColor;
  final double? iconSize;
  final int? defaultValue;
  final int? minValue;
  final int? maxValue;
  final double? width; 
  final String? clearText;
  final Function(int) onChanged;
  const StepperSelector({ Key? key, required this.controller, required this.icon, required this.iconColor, this.iconSize, this.defaultValue, this.minValue, this.maxValue, this.width, this.clearText, required this.onChanged }) : super(key: key);

  @override
  _StepperSelectorState createState() => _StepperSelectorState();
}

class _StepperSelectorState extends State<StepperSelector> {
  late double _iconSize = 20;
  late double _width = 100;
  late int _currentValue = 0;
  late int _minValue = 0;
  late int _maxValue = 5;
  late String _clearText = "All";

  @override
  void initState() {
    super.initState();
    _minValue = (widget.minValue ?? 0);
    _maxValue = (widget.maxValue ?? 5);
    _currentValue = (widget.defaultValue ?? _minValue);
    _iconSize = (widget.iconSize ?? 20);
    _width = (widget.width ?? (_iconSize * _maxValue));
    _clearText = (widget.clearText ?? "All");
    widget.controller.changeValue(_currentValue);
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        GestureDetector(
          onTap: (() {
            if(_currentValue > _minValue) {
              setState(() {                
                _currentValue = _currentValue - 1;
                widget.controller.changeValue(_currentValue);
                widget.onChanged(_currentValue);
              });
            }
          }),
          child: const SizedBox(
            width: 25,
            height: 25,
            child: Icon(
              Ionicons.remove_circle_outline,
              color: accentColor,
            ),
          ),
        ),
        SizedBox(
          height: 20,
          width: _width,
          child: (_currentValue == 0 ? _generateClear() : _generateStars()),
        ),
        GestureDetector(
          onTap: () {
            if(_currentValue < _maxValue) {
              setState(() {                
                _currentValue = _currentValue + 1;
                widget.controller.changeValue(_currentValue);
                widget.onChanged(_currentValue);
              });
            }
          },
          child: const SizedBox(
            width: 25,
            height: 25,
            child: Icon(
              Ionicons.add_circle_outline,
              color: accentColor,
            ),
          ),
        ),
      ],
    );
  }

  Widget _generateClear() {
    return Center(child: Text(_clearText),);
  }

  Widget _generateStars() {
    return ListView.builder(
      scrollDirection: Axis.horizontal,
      itemCount: _maxValue,
      itemBuilder: ((context, index) {
        return SizedBox(
          width: 20,
          child: Center(
            child: Icon(
              widget.icon,
              size: 20,
              color: ((index + 1) <= _currentValue ? widget.iconColor : textPrimary),
            ),
          ),
        );
      }),
    );
  }
}