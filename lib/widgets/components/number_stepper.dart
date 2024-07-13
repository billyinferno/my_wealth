import 'package:flutter/material.dart';
import 'package:ionicons/ionicons.dart';
import 'package:my_wealth/themes/colors.dart';

class NumberStepper extends StatefulWidget {
  final double? height;
  final Color? borderColor;
  final Color? buttonColor;
  final Color? bgColor;
  final Color? iconColor;
  final double? iconSize;
  final Color? textColor;
  final int initialRate;
  final String? ratePrefix;
  final int? minRate;
  final int? maxRate;
  final int? stepper;
  final int? stepperMultiply;
  final Function(int) onTap;
  const NumberStepper({
    super.key,
    this.height,
    this.borderColor,
    this.buttonColor,
    this.bgColor,
    this.iconColor,
    this.iconSize,
    this.textColor,
    required this.initialRate,
    this.ratePrefix,
    this.minRate,
    this.maxRate,
    required this.onTap,
    this.stepper,
    this.stepperMultiply,
  });

  @override
  State<NumberStepper> createState() => _NumberStepperState();
}

class _NumberStepperState extends State<NumberStepper> {
  late int _oneDayRate;
  late int _minRate;
  late int _maxRate;
  late int _stepper;
  late int _stepperMultiply;

  @override
  void initState() {
    // get the one day rate
    _oneDayRate = widget.initialRate;
    _minRate = (widget.minRate ?? 1);
    _maxRate = (widget.maxRate ?? 100);
    _stepper = (widget.stepper ?? 1);
    _stepperMultiply = (widget.stepperMultiply ?? 10);

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: (widget.height ?? 30),
      decoration: BoxDecoration(
        border: Border.all(
          color: (widget.borderColor ?? secondaryColor),
          width: 1.0,
          style: BorderStyle.solid
        ),
        color: (widget.bgColor ?? Colors.white),
        borderRadius: BorderRadius.circular(5),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          InkWell(
            onTap: (() {
              setState(() {
                _oneDayRate = _oneDayRate - (_stepper);
                if (_oneDayRate < _minRate) {
                  _oneDayRate = _minRate;
                }
              });
              widget.onTap(_oneDayRate);
            }),
            onDoubleTap: (() {
              setState(() {
                _oneDayRate = _oneDayRate - (_stepper * _stepperMultiply);
                if (_oneDayRate < _minRate) {
                  _oneDayRate = _minRate;
                }
              });
              widget.onTap(_oneDayRate);
            }),
            child: Container(
              width: (widget.height ?? 30),
              height: (widget.height ?? 30),
              decoration: BoxDecoration(
                color: (widget.buttonColor ?? secondaryColor),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(5),
                  bottomLeft: Radius.circular(5)
                )
              ),
              child: Icon(
                Ionicons.remove,
                color: (widget.iconColor ?? Colors.white),
                size: (widget.iconSize ?? 20),
              ),
            ),
          ),
          Expanded(
            child: SizedBox(
              height: 30,
              child: Center(
                child: Text(
                  "$_oneDayRate${widget.ratePrefix ?? '%'}",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: (widget.textColor ?? secondaryColor),
                  ),
                ),
              ),
            ),
          ),
          InkWell(
            onTap: (() {
              setState(() {
                _oneDayRate = _oneDayRate + 1;
                if (_oneDayRate >= _maxRate) {
                  _oneDayRate = _maxRate;
                }
              });
              widget.onTap(_oneDayRate);
            }),
            onDoubleTap: (() {
              setState(() {
                _oneDayRate = _oneDayRate + 10;
                if (_oneDayRate >= _maxRate) {
                  _oneDayRate = _maxRate;
                }
              });
              widget.onTap(_oneDayRate);
            }),
            child: Container(
              width: (widget.height ?? 30),
              height: (widget.height ?? 30),
              decoration: BoxDecoration(
                color: (widget.buttonColor ?? secondaryColor),
                borderRadius: const BorderRadius.only(
                  topRight: Radius.circular(5),
                  bottomRight: Radius.circular(5)
                )
              ),
              child: Icon(
                Ionicons.add,
                color: (widget.iconColor ?? Colors.white),
                size: (widget.iconSize ?? 20),
              ),
            ),
          ),
        ],
      ),
    );
  }
}