import 'package:flutter/material.dart';
import 'package:my_wealth/themes/colors.dart';
import 'package:my_wealth/utils/function/format_currency.dart';
import 'package:my_wealth/utils/function/risk_color.dart';
import 'package:my_wealth/widgets/watchlist_summary_info.dart';

class WatchlistSummary extends StatelessWidget {
  final double dayGain;
  final double value;
  final double cost;
  final int riskFactor;

  const WatchlistSummary({ Key? key, required this.dayGain, required this.value, required this.cost, required this.riskFactor }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: riskColor(value, cost, riskFactor),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          const SizedBox(
            width: 10,
          ),
          Expanded(
            flex: 1,
            child: Container(
              color: primaryDark,
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  const Text(
                    "TOTAL GAIN",
                    style: TextStyle(
                      fontSize: 10,
                    ),
                  ),
                  Text(
                    _totalGain(),
                    style: const TextStyle(
                      fontSize: 35,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10,),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      WatchlistSummaryInfo(text: "DAY GAIN", amount: dayGain),
                      const SizedBox(width: 10,),
                      WatchlistSummaryInfo(text: "VALUE", amount: value),
                      const SizedBox(width: 10,),
                      WatchlistSummaryInfo(text: "COST", amount: cost),
                    ],
                  )
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  String _totalGain() {
    // calculate the total gain by subtract the value and cost
    double _gain = value - cost;
    return formatCurrency(_gain);
  }
}