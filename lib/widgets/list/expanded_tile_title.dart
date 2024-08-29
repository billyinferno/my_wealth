import 'package:flutter/material.dart';
import 'package:ionicons/ionicons.dart';
import 'package:my_wealth/_index.g.dart';

class ExpandedTileTitle extends StatelessWidget {
  final String name;
  final int buy;
  final int sell;
  final double share;
  final String? shareTitle;
  final double price;
  final double? prevPrice;
  final double? gain;
  final String lastUpdate;
  final Color? riskColor;
  final bool? checkThousandOnPrice;
  final Color? subHeaderRiskColor;
  final double? totalDayGain;
  final double? totalValue;
  final double? totalCost;
  final double? averagePrice;
  final bool? fca;
  final bool? showDecimal;

  const ExpandedTileTitle({
    super.key,
    required this.name, 
    required this.buy, 
    required this.sell,
    required this.share,
    this.shareTitle,
    required this.price, 
    this.prevPrice,
    required this.gain,
    required this.lastUpdate,
    this.riskColor,
    this.checkThousandOnPrice,
    this.subHeaderRiskColor,
    this.totalDayGain,
    this.totalValue,
    this.totalCost,
    this.averagePrice,
    this.fca,
    this.showDecimal,
  });

  @override
  Widget build(BuildContext context) {
    final rColor = (riskColor ?? primaryLight);
    final diffPrice = (price - (prevPrice ?? price));
    final isFca = (fca ?? false);
    
    Color trendColor = Colors.white;
    IconData trendIcon = Ionicons.remove;
    
    if (diffPrice > 0) {
      trendColor = Colors.green;
      trendIcon = Ionicons.caret_up;
    }
    else if(diffPrice < 0) {
      trendColor = secondaryColor;
      trendIcon = Ionicons.caret_down;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.start,
      children: <Widget>[
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Container(
              width: 5,
              height: 50,
              color: rColor,
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  Container(
                    padding: const EdgeInsets.fromLTRB(10, 0, 0, 0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: <Widget>[
                            Visibility(
                              visible: isFca,
                              child: const Icon(
                                Ionicons.warning,
                                color: secondaryColor,
                                size: 15,
                              )
                            ),
                            Visibility(
                              visible: isFca,
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
                                    color: rColor,
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
                                    shorten: true
                                  )
                                } ${shareTitle ?? "Shares"}" : "- ${shareTitle ?? "Shares"}"),
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
                                          checkThousand: (checkThousandOnPrice ?? false),
                                          showDecimal: (showDecimal ?? true),
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
                ],
              ),
            ),
          ],
        ),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Container(
              width: 5,
              height: 35,
              color: (subHeaderRiskColor ?? Colors.white),
            ),
            const SizedBox(width: 10,),
            _subHeaderInformation(
              header: "DAY GAIN",
              value: formatCurrencyWithNull(totalDayGain),
            ),
            const SizedBox(width: 10,),
            _subHeaderInformation(
              header: "VALUE",
              value: formatCurrencyWithNull(totalValue),
            ),
            const SizedBox(width: 10,),
            _subHeaderInformation(
              header: "COST",
              value: formatCurrencyWithNull(totalCost),
            ),
            const SizedBox(width: 10,),
            _subHeaderInformation(
              header: "AVERAGE",
              value: formatCurrencyWithNull(averagePrice),
            ),
          ],
        ),
      ],
    );
  }

  Widget _subHeaderInformation({required String header, required String value}) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.fromLTRB(0, 5, 0, 0),
        decoration: const BoxDecoration(
            border: Border(
          top: BorderSide(
            color: primaryLight,
            width: 1.0,
            style: BorderStyle.solid,
          ),
        )),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Text(
              header,
              style: const TextStyle(
                fontSize: 10,
              ),
            ),
            Text(
              value,
              style: const TextStyle(
                fontSize: 12,
              ),
              overflow: TextOverflow.ellipsis,
            )
          ],
        ),
      ),
    );
  }
}