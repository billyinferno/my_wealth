import 'package:flutter/material.dart';
import 'package:ionicons/ionicons.dart';
import 'package:my_wealth/_index.g.dart';

class ExpandedTileTitle extends StatelessWidget {
  final String name;
  final int buy;
  final int sell;
  final double share;
  final String shareTitle;
  final double price;
  final double? prevPrice;
  final double? gain;
  final String lastUpdate;
  final Color riskColor;
  final bool checkThousandOnPrice;
  final Color? subHeaderRiskColor;
  final double? totalDayGain;
  final double? totalValue;
  final double? totalCost;
  final double? averagePrice;
  final double realisedGain;
  final bool fca;
  final bool showDecimal;
  final bool visibility;
  final bool isLot;

  const ExpandedTileTitle({
    super.key,
    required this.name, 
    required this.buy, 
    required this.sell,
    required this.share,
    this.shareTitle = "Shares",
    required this.price, 
    this.prevPrice,
    required this.gain,
    required this.lastUpdate,
    this.riskColor = primaryLight,
    this.checkThousandOnPrice = false,
    this.subHeaderRiskColor,
    this.totalDayGain,
    this.totalValue,
    this.totalCost,
    this.averagePrice,
    this.realisedGain = 0,
    this.fca = false,
    this.showDecimal = true,
    this.visibility = true,
    this.isLot = false,
  });

  @override
  Widget build(BuildContext context) {
    final diffPrice = (price - (prevPrice ?? price));
    
    Color trendColor = Colors.white;
    IconData trendIcon = Ionicons.remove;
    int decimalNum = 2;
    if (isLot) {
      // check if share is 1K+ or not
      if (share < 1000) {
        decimalNum = 0;
      }
    }
    
    if (diffPrice > 0) {
      trendColor = Colors.green;
      trendIcon = Ionicons.caret_up;
    }
    else if(diffPrice < 0) {
      trendColor = secondaryColor;
      trendIcon = Ionicons.caret_down;
    }

    //TODO: to create different sub header if the total shares are 0, instead
    // showing day gain, we can showed the realized gain for this stock instead
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.start,
      children: <Widget>[
        IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              Container(
                width: 5,
                color: riskColor,
              ),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.fromLTRB(10, 0, 0, 5),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: <Widget>[
                          Visibility(
                            visible: fca,
                            child: const Icon(
                              Ionicons.warning,
                              color: secondaryColor,
                              size: 15,
                            )
                          ),
                          Visibility(
                            visible: fca,
                            child: const SizedBox(width: 5,)
                          ),
                          Expanded(
                            child: Text(
                              name,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 10,),
                          Container(
                            decoration: BoxDecoration(
                              border: Border(
                                bottom: BorderSide(
                                  color: riskColor,
                                  width: 2.0,
                                  style: BorderStyle.solid,
                                )
                              )
                            ),
                            child: Text(
                              formatCurrencyWithNull(gain),
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          )
                        ],
                      ),
                      const SizedBox(height: 5,),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: <Widget>[
                          Expanded(
                            flex: 2,
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: <Widget>[
                                const Icon(
                                  Ionicons.time_outline,
                                  size: 15,
                                  color: primaryLight,
                                ),
                                const SizedBox(width: 5,),
                                Text(
                                  lastUpdate,
                                  style: const TextStyle(
                                    fontSize: 12,
                                  ),
                                )
                              ],
                            ),
                          ),
                          const SizedBox(width: 10,),
                          Expanded(
                            flex: 2,
                            child: Text(
                              "${buy > 0 ? "$buy" : "-"}${sell > 0 ? "($sell)" : ""} Txn",
                              style: const TextStyle(
                                fontSize: 12,
                              ),
                            ),
                          ),
                          const SizedBox(width: 10,),
                          Expanded(
                            flex: 2,
                            child: Text(
                              (share > 0 ? "${
                                formatCurrency(
                                  share,
                                  checkThousand: true,
                                  decimalNum: decimalNum,
                                )
                              } $shareTitle" : "- $shareTitle"),
                              style: const TextStyle(
                                fontSize: 12,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 10,),
                          Expanded(
                            flex: 2,
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: <Widget>[
                                Icon(
                                  trendIcon,
                                  color: trendColor,
                                  size: 12,
                                ),
                                const SizedBox(width: 2,),
                                Expanded(
                                  child: Container(
                                    decoration: BoxDecoration(
                                      border: Border(
                                        bottom: BorderSide(
                                          color: trendColor,
                                          width: 2.0,
                                          style: BorderStyle.solid,
                                        )
                                      )
                                    ),
                                    child: Text(
                                      formatCurrency(
                                        price,
                                        checkThousand: checkThousandOnPrice,
                                        showDecimal: showDecimal,
                                      ),
                                      style: const TextStyle(
                                        fontSize: 12,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                      textAlign: TextAlign.right,
                                    ),
                                  ),
                                )
                              ],
                            ),
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
        IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              Container(
                width: 5,
                color: (subHeaderRiskColor ?? Colors.white),
              ),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.fromLTRB(10, 0, 0, 0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      WatchlistSummaryInfo(
                        text: "DAY GAIN",
                        amount: totalDayGain,
                        amountSize: 12,
                        visibility: visibility,
                        topPadding: 5,
                      ),
                      const SizedBox(width: 10,),
                      WatchlistSummaryInfo(
                        text: "VALUE",
                        amount: totalValue,
                        amountSize: 12,
                        visibility: visibility,
                        topPadding: 5,
                      ),
                      const SizedBox(width: 10,),
                      WatchlistSummaryInfo(
                        text: "COST",
                        amount: totalCost,
                        amountSize: 12,
                        visibility: visibility,
                        topPadding: 5,
                      ),
                      const SizedBox(width: 10,),
                      WatchlistSummaryInfo(
                        text: "AVERAGE",
                        amount: averagePrice,
                        amountSize: 12,
                        visibility: visibility,
                        topPadding: 5,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}