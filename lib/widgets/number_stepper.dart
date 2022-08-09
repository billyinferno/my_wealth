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
  final Function(int) onTap;
  const NumberStepper({Key? key, this.height, this.borderColor, this.buttonColor, this.bgColor, this.iconColor, this.iconSize, this.textColor, required this.initialRate, this.ratePrefix, required this.onTap}) : super(key: key);

  @override
  State<NumberStepper> createState() => _NumberStepperState();
}

class _NumberStepperState extends State<NumberStepper> {
  late int _oneDayRate;

  @override
  void initState() {
    // get the one day rate
    _oneDayRate = widget.initialRate;

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
                _oneDayRate = _oneDayRate - 1;
                if (_oneDayRate <= 0) {
                  _oneDayRate = 1;
                }
              });
              widget.onTap(_oneDayRate);
            }),
            onDoubleTap: (() {
              setState(() {
                _oneDayRate = _oneDayRate - 10;
                if (_oneDayRate <= 0) {
                  _oneDayRate = 1;
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
          InkWell(
            onTap: (() {
              setState(() {
                _oneDayRate = _oneDayRate + 1;
                if (_oneDayRate >= 100) {
                  _oneDayRate = 100;
                }
              });
              widget.onTap(_oneDayRate);
            }),
            onDoubleTap: (() {
              setState(() {
                _oneDayRate = _oneDayRate + 10;
                if (_oneDayRate >= 100) {
                  _oneDayRate = 100;
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