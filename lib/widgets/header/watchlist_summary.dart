import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:ionicons/ionicons.dart';
import 'package:my_wealth/_index.g.dart';

class WatchlistSummary extends StatelessWidget {
  final double dayGain;
  final double value;
  final double cost;
  final int riskFactor;
  final bool visibility;
  final VoidCallback onVisibilityPress;
  final ComputeWatchlistAllResult? compResult;
  const WatchlistSummary({ super.key, required this.dayGain, required this.value, required this.cost, required this.riskFactor, required this.visibility, required this.onVisibilityPress, this.compResult});

  @override
  Widget build(BuildContext context) {
    return _summaryWidget();
  }

  String _totalGain() {
    // calculate the total gain by subtract the value and cost
    double gain = value - cost;
    return formatCurrency(gain);
  }

  Widget _summaryWidget() {
    if(visibility) {
      return _summaryWidgetVisible();
    }
    else {
      return _summaryWidgetHidden();
    }
  }

  Widget _summaryWidgetVisible() {
    return SingleChildScrollView(
      child: Slidable(
        endActionPane: ActionPane(
        motion: const ScrollMotion(),
        extentRatio: 0.43,
        children: <Widget>[
            SlidableAction(
              onPressed: ((BuildContext context) {
                WatchlistSummaryPerformanceArgs args = WatchlistSummaryPerformanceArgs(type: 'all', computeResult: compResult!);
                Navigator.pushNamed(context, '/watchlist/summary/performance', arguments: args);
              }),
              icon: Ionicons.pulse_outline,
              backgroundColor: primaryDark,
              foregroundColor: Colors.purple,
            ),
            SlidableAction(
              onPressed: ((BuildContext context) {
                WatchlistSummaryPerformanceArgs args = WatchlistSummaryPerformanceArgs(type: 'all', computeResult: compResult!);
                Navigator.pushNamed(context, '/watchlist/summary/calendar', arguments: args);
              }),
              icon: Ionicons.calendar_outline,
              backgroundColor: primaryDark,
              foregroundColor: Colors.pink[300],
            ),
          ],
        ),
        child: Container(
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
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Column(
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
                                    visible: (cost > 0),
                                    child: Text(
                                      "(${formatDecimalWithNull((cost > 0 ? (value - cost) / cost : 0), 100, 2)}%)",
                                      style: TextStyle(
                                        color: riskColor(value, cost, riskFactor),
                                      ),
                                    )
                                  ),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(width: 10,),
                          IconButton(
                            onPressed: (() {
                              onVisibilityPress();
                            }),
                            icon: const Icon(
                              Ionicons.eye_off_outline,
                              size: 15,
                              color: primaryLight,
                            )
                          )
                        ],
                      ),
                      const SizedBox(height: 5,),
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
        ),
      ),
    );
  }

  Widget _summaryWidgetHidden() {
    return Container(
      color: Colors.white,
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
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            "TOTAL GAIN",
                            style: TextStyle(
                              fontSize: 10,
                            ),
                          ),
                          Text(
                            "****",
                            style: TextStyle(
                              fontSize: 35,
                              fontWeight: FontWeight.bold,
                              height: 0.9,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(width: 10,),
                      IconButton(
                        onPressed: (() {
                          onVisibilityPress();
                        }),
                        icon: const Icon(
                          Ionicons.eye_outline,
                          size: 15,
                          color: primaryLight,
                        )
                      )
                    ],
                  ),
                  const SizedBox(height: 10,),
                  const Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      WatchlistSummaryInfo(text: "DAY GAIN", amount: null),
                      SizedBox(width: 10,),
                      WatchlistSummaryInfo(text: "VALUE", amount: null),
                      SizedBox(width: 10,),
                      WatchlistSummaryInfo(text: "COST", amount: null),
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
}
