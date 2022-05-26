import 'package:flutter/material.dart';
import 'package:my_wealth/themes/colors.dart';
import 'package:my_wealth/utils/function/format_currency.dart';
import 'package:my_wealth/utils/function/risk_color.dart';

class WatchlistSubSummary extends StatelessWidget {
  final double dayGain;
  final double value;
  final double cost;
  final int riskFactor;
  final bool? isVisible;
  const WatchlistSubSummary({Key? key, required this.dayGain, required this.value, required this.cost, required this.riskFactor, this.isVisible}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // defaulted the _isVisible to true if the parameter not being sent to the widget
    bool isUserVisible = isVisible ?? true;
    
    return Container(
      width: double.infinity,
      height: 80,
      padding: const EdgeInsets.fromLTRB(0, 0, 0, 5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          Container(
            width: 10,
            height: double.infinity,
            color: riskColor(value, cost, riskFactor),
          ),
          const SizedBox(width: 10,),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                const Text(
                  "SUB TOTAL",
                  style: TextStyle(
                    fontSize: 10,
                  ),
                ),
                Text(
                  formatCurrencyWithNull(isUserVisible ? (value - cost) : null),
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                const SizedBox(height: 5,),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Expanded(
                      flex: 1,
                      child: Container(
                        margin: const EdgeInsets.fromLTRB(0,0,10,0),
                        padding: const EdgeInsets.fromLTRB(0, 5, 0, 0),
                        decoration: const BoxDecoration(
                          border: Border(top: BorderSide(width: 1.0, style: BorderStyle.solid, color: primaryLight))
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: <Widget>[
                            const Text(
                              "DAY GAIN",
                              style: TextStyle(
                                fontSize: 10,
                              ),
                            ),
                            Text(
                              formatCurrencyWithNull(isUserVisible ? dayGain : null),
                              style: const TextStyle(
                                fontSize: 15,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 1,
                      child: Container(
                        margin: const EdgeInsets.fromLTRB(0,0,10,0),
                        padding: const EdgeInsets.fromLTRB(0, 5, 0, 0),
                        decoration: const BoxDecoration(
                          border: Border(top: BorderSide(width: 1.0, style: BorderStyle.solid, color: primaryLight))
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: <Widget>[
                            const Text(
                              "VALUE",
                              style: TextStyle(
                                fontSize: 10,
                              ),
                            ),
                            Text(
                              formatCurrencyWithNull(isUserVisible ? value : null),
                              style: const TextStyle(
                                fontSize: 15,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 1,
                      child: Container(
                        margin: const EdgeInsets.fromLTRB(0,0,10,0),
                        padding: const EdgeInsets.fromLTRB(0, 5, 0, 0),
                        decoration: const BoxDecoration(
                          border: Border(top: BorderSide(width: 1.0, style: BorderStyle.solid, color: primaryLight))
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: <Widget>[
                            const Text(
                              "COST",
                              style: TextStyle(
                                fontSize: 10,
                              ),
                            ),
                            Text(
                              formatCurrencyWithNull(isUserVisible ? cost : null),
                              style: const TextStyle(
                                fontSize: 15,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}