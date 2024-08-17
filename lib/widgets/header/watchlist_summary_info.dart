import 'package:flutter/material.dart';
import 'package:my_wealth/_index.g.dart';

class WatchlistSummaryInfo extends StatelessWidget {
  final String text;
  final double? amount;
  const WatchlistSummaryInfo({ super.key, required this.text, this.amount });

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
            const SizedBox(height: 10,),
            Text(
              text,
              style: const TextStyle(
                fontSize: 10,
              ),
            ),
            Text(formatCurrencyWithNull(amount)),
          ],
        ),
      ),
    );
  }
}