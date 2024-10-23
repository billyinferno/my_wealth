import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:ionicons/ionicons.dart';
import 'package:my_wealth/_index.g.dart';

class WatchlistSummary extends StatelessWidget {
  final BuildContext context;
  final double dayGain;
  final double value;
  final double cost;
  final int riskFactor;
  final bool visibility;
  final VoidCallback onVisibilityPress;
  final ComputeWatchlistAllResult? compResult;
  const WatchlistSummary({
    super.key,
    required this.context,
    required this.dayGain,
    required this.value,
    required this.cost,
    required this.riskFactor,
    required this.visibility,
    required this.onVisibilityPress,
    this.compResult}
  );

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Slidable(
        endActionPane: ActionPane(
          motion: const ScrollMotion(),
          extentRatio: 0.43,
          children: <Widget>[
            SlideButton(
              icon: Ionicons.pulse_outline,
              iconColor: Colors.purple,
              bgColor: primaryDark,
              onTap: () {
                WatchlistSummaryPerformanceArgs args = WatchlistSummaryPerformanceArgs(type: 'all', computeResult: compResult!);
                Navigator.pushNamed(context, '/watchlist/summary/performance', arguments: args);
              },
            ),
            SlideButton(
              icon: Ionicons.calendar_outline,
              iconColor: Colors.pink[300]!,
              bgColor: primaryDark,
              onTap: () {
                WatchlistSummaryPerformanceArgs args = WatchlistSummaryPerformanceArgs(type: 'all', computeResult: compResult!);
                Navigator.pushNamed(context, '/watchlist/summary/calendar', arguments: args);
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
              color: (visibility ? riskColor(
                  value: value,
                  cost: cost,
                  riskFactor: riskFactor
                ) : Colors.white
              ),
            ),
            Expanded(
              child: Container(
                color: primaryDark,
                padding: const EdgeInsets.fromLTRB(10, 10, 0, 10),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    Expanded(
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
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: <Widget>[
                              Text(
                                _totalGain(),
                                style: const TextStyle(
                                  fontSize: 35,
                                  fontWeight: FontWeight.bold,
                                  height: 0.9,
                                ),
                              ),
                              const SizedBox(width: 5,),
                              Visibility(
                                visible: (cost > 0 && visibility),
                                child: Text(
                                  "(${formatDecimalWithNull(
                                    (cost > 0 ? (value - cost) / cost : 0),
                                    times: 100,
                                    decimal: 2
                                  )}%)",
                                  style: TextStyle(
                                    color: riskColor(
                                      value: value,
                                      cost: cost,
                                      riskFactor: riskFactor
                                    ),
                                  ),
                                )
                              ),
                            ],
                          ),
                          const SizedBox(height: 5,),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: <Widget>[
                              WatchlistSummaryInfo(
                                text: "DAY GAIN",
                                amount: dayGain,
                                visibility: visibility,
                              ),
                              const SizedBox(width: 10,),
                              WatchlistSummaryInfo(
                                text: "VALUE",
                                amount: value,
                                visibility: visibility,
                              ),
                              const SizedBox(width: 10,),
                              WatchlistSummaryInfo(
                                text: "COST",
                                amount: cost,
                                visibility: visibility,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: (() {
                        onVisibilityPress();
                      }),
                      icon: const Icon(
                        Ionicons.eye_off_outline,
                        size: 15,
                        color: primaryLight,
                      )
                    ),
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  String _totalGain() {
    if (visibility) {
      // calculate the total gain by subtract the value and cost
      double gain = value - cost;
      return formatCurrency(gain);
    }
    return "****";
  }
}
