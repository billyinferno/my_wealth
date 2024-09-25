import 'package:flutter/material.dart';
import 'package:ionicons/ionicons.dart';
import 'package:my_wealth/_index.g.dart';

class NumberStepper extends StatefulWidget {
  final double height;
  final Color borderColor;
  final Color buttonColor;
  final Color bgColor;
  final Color iconColor;
  final double iconSize;
  final Color textColor;
  final int initialRate;
  final String ratePrefix;
  final int minRate;
  final int maxRate;
  final int stepper;
  final int stepperMultiply;
  final Function(int) onTap;
  const NumberStepper({
    super.key,
    this.height = 30,
    this.borderColor = secondaryColor,
    this.buttonColor = secondaryColor,
    this.bgColor = Colors.white,
    this.iconColor = Colors.white,
    this.iconSize = 20,
    this.textColor = secondaryColor,
    required this.initialRate,
    this.ratePrefix = '%',
    this.minRate = 1,
    this.maxRate = 100,
    this.stepper = 1,
    this.stepperMultiply = 10,
    required this.onTap,
  });

  @override
  State<NumberStepper> createState() => _NumberStepperState();
}

class _NumberStepperState extends State<NumberStepper> {
  late int _currentRate;

  @override
  void initState() {
    super.initState();
    
    // get the current rate
    _currentRate = widget.initialRate;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: widget.height,
      decoration: BoxDecoration(
        border: Border.all(
          color: widget.borderColor,
          width: 1.0,
          style: BorderStyle.solid
        ),
        color: widget.bgColor,
        borderRadius: BorderRadius.circular(5),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          InkWell(
            onTap: (() {
              setState(() {
                _currentRate = _currentRate - (widget.stepper);
                if (_currentRate < widget.minRate) {
                  _currentRate = widget.minRate;
                }
              });
              widget.onTap(_currentRate);
            }),
            onDoubleTap: (() {
              setState(() {
                _currentRate = _currentRate - (widget.stepper * widget.stepperMultiply);
                if (_currentRate < widget.minRate) {
                  _currentRate = widget.minRate;
                }
              });
              widget.onTap(_currentRate);
            }),
            child: Container(
              width: widget.height,
              height: widget.height,
              decoration: BoxDecoration(
                color: widget.buttonColor,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(5),
                  bottomLeft: Radius.circular(5)
                )
              ),
              child: Icon(
                Ionicons.remove,
                color: widget.iconColor,
                size: widget.iconSize,
              ),
            ),
          ),
          Expanded(
            child: SizedBox(
              height: 30,
              child: Center(
                child: Text(
                  "$_currentRate${widget.ratePrefix}",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: widget.textColor,
                  ),
                ),
              ),
            ),
          ),
          InkWell(
            onTap: (() {
              setState(() {
                _currentRate = _currentRate + 1;
                if (_currentRate >= widget.maxRate) {
                  _currentRate = widget.maxRate;
                }
              });
              widget.onTap(_currentRate);
            }),
            onDoubleTap: (() {
              setState(() {
                _currentRate = _currentRate + (widget.stepper * widget.stepperMultiply);
                if (_currentRate >= widget.maxRate) {
                  _currentRate = widget.maxRate;
                }
              });
              widget.onTap(_currentRate);
            }),
            child: Container(
              width: widget.height,
              height: widget.height,
              decoration: BoxDecoration(
                color: widget.buttonColor,
                borderRadius: const BorderRadius.only(
                  topRight: Radius.circular(5),
                  bottomRight: Radius.circular(5)
                )
              ),
              child: Icon(
                Ionicons.add,
                color: widget.iconColor,
                size: widget.iconSize,
              ),
            ),
          ),
        ],
      ),
    );
  }
}