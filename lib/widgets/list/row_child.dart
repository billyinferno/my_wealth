import 'package:flutter/material.dart';
import 'package:my_wealth/_index.g.dart';

class RowChild extends StatelessWidget {
  final String headerText;
  final Color headerColor;
  final double? value;
  final bool autoColor;
  const RowChild({
    super.key,
    required this.headerText,
    this.headerColor = textPrimary,
    required this.value,
    this.autoColor = false,
  });

  @override
  Widget build(BuildContext context) {
    Color valueColor = textPrimary;
    if (autoColor) {
      // if auto color is set into true, then we need to check if the
      if ((value ?? 0) < 0) {
        valueColor = secondaryColor;
      }
      if ((value ?? 0) > 0) {
        valueColor = Colors.green;
      }
    }

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
                color: headerColor
              ),
            ),
          ),
          Text(
            formatCurrencyWithNull(value),
            style: TextStyle(
              color: valueColor,
            ),
          ),
        ],
      ),
    );
  }
}