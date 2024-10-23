import 'package:flutter/material.dart';
import 'package:my_wealth/_index.g.dart';

class WatchlistSummaryInfo extends StatelessWidget {
  final String text;
  final double textSize;
  final double? amount;
  final double amountSize;
  final bool visibility;
  final double topPadding;
  const WatchlistSummaryInfo({
    super.key,
    required this.text,
    this.textSize = 10,
    this.amount,
    this.amountSize = 12,
    this.visibility = true,
    this.topPadding = 10,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        decoration: const BoxDecoration(
          border: Border(
            top: BorderSide(
              color: primaryLight,
              style: BorderStyle.solid,
              width: 1.0,
            )
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            SizedBox(height: topPadding,),
            Text(
              text,
              style: TextStyle(
                fontSize: textSize,
              ),
            ),
            Text(
              (visibility ? formatCurrencyWithNull(amount) : "-"),
              style: TextStyle(
                fontSize: amountSize,
              ),
            ),
          ],
        ),
      ),
    );
  }
}