import 'package:flutter/material.dart';
import 'package:my_wealth/themes/colors.dart';

class RowChild extends StatelessWidget {
  final String headerText;
  final Color? headerColor;
  final String valueText;
  final Color? valueColor;
  const RowChild({
    super.key,
    required this.headerText,
    this.headerColor,
    required this.valueText,
    this.valueColor
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          SizedBox(
            width: double.infinity,
            child: Text(
              headerText,
              style: TextStyle(
                fontSize: 10,
                color: (headerColor ?? textPrimary)
              ),
            ),
          ),
          Text(
            valueText,
            style: TextStyle(
              color: (valueColor ?? textPrimary),
            ),
          ),
        ],
      ),
    );
  }
}