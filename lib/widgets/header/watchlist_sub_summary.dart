import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:ionicons/ionicons.dart';
import 'package:my_wealth/_index.g.dart';

class WatchlistSubSummary extends StatelessWidget {
  final double dayGain;
  final double value;
  final double cost;
  final int riskFactor;
  final bool isVisible;
  final String type;
  final int totalData;
  final ComputeWatchlistAllResult? compResult;
  const WatchlistSubSummary({
    super.key,
    required this.dayGain,
    required this.value,
    required this.cost,
    required this.riskFactor,
    this.isVisible = true,
    required this.type,
    this.totalData = 0,
    this.compResult
  });

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Slidable(
        endActionPane: ActionPane(
        motion: const ScrollMotion(),
        extentRatio: 0.42,
        children: <Widget>[
          SlideButton(
            icon: Ionicons.pulse_outline,
            iconColor: (totalData > 0 ? Colors.purple : primaryLight),
            onTap: () {
              if (totalData > 0) {
                WatchlistSummaryPerformanceArgs args = WatchlistSummaryPerformanceArgs(type: type, computeResult: compResult!);
                Navigator.pushNamed(context, '/watchlist/summary/performance', arguments: args);
              }
            },
          ),
          SlideButton(
            icon: Ionicons.calendar_outline,
            iconColor: (totalData > 0 ? Colors.pink[300]! : primaryLight),
            onTap: () {
              if (totalData > 0) {
                WatchlistSummaryPerformanceArgs args = WatchlistSummaryPerformanceArgs(type: type, computeResult: compResult!);
                Navigator.pushNamed(context, '/watchlist/summary/calendar', arguments: args);
              }
            },
          ),
        ],
      ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Container(
              width: 10,
              color: (isVisible ? riskColor(
                value: value,
                cost: cost,
                riskFactor: riskFactor
              ) : Colors.white),
            ),
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(10),
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
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          formatCurrencyWithNull(isVisible ? (value - cost) : null),
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                            height: 1.0,
                          ),
                        ),
                        const SizedBox(width: 5,),
                        Visibility(
                          visible: (cost > 0),
                          child: Text(
                            (isVisible ? "(${formatDecimalWithNull(
                              (cost > 0 ? (value - cost) / cost : 0),
                              times: 100,
                              decimal: 2,
                            )}%)" : ""),
                            style: TextStyle(
                              color: riskColor(
                                value: value,
                                cost: cost,
                                riskFactor: riskFactor
                              )
                            ),
                          )
                        ),
                      ],
                    ),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: <Widget>[
                        WatchlistSummaryInfo(
                          text: "DAY GAIN",
                          amount: dayGain,
                          visibility: isVisible,
                          topPadding: 5,
                        ),
                        const SizedBox(width: 10,),
                        WatchlistSummaryInfo(
                          text: "VALUE",
                          amount: value,
                          visibility: isVisible,
                          topPadding: 5,
                        ),
                        const SizedBox(width: 10,),
                        WatchlistSummaryInfo(
                          text: "COST",
                          amount: cost,
                          visibility: isVisible,
                          topPadding: 5,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}