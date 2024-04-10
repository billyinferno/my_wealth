import 'package:flutter/material.dart';
import 'package:my_wealth/themes/colors.dart';

class ColumnInfo extends StatelessWidget {
  final String title;
  final Color? titleColor;
  final double? titleSize;
  final String value;
  final Color? valueColor;
  final double? valueSize;

  const ColumnInfo({
    super.key,
    required this.title,
    this.titleColor,
    this.titleSize,
    required this.value,
    this.valueColor,
    this.valueSize,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          Text(
            title,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: (titleSize ?? 12),
              color: (titleColor ?? extendedLight),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: (valueSize ?? 12),
              color: (valueColor ?? textPrimary),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}