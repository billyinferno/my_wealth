import 'package:flutter/material.dart';
import 'package:ionicons/ionicons.dart';
import 'package:my_wealth/themes/colors.dart';
import 'package:my_wealth/utils/function/format_currency.dart';

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

  const ExpandedTileTitle({ Key? key, required this.name, required this.buy, required this.sell, required this.share, this.shareTitle, required this.price, this.prevPrice, required this.gain, required this.lastUpdate, this.riskColor, this.checkThousandOnPrice }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final rColor = (riskColor ?? primaryLight);
    final diffPrice = (price - (prevPrice ?? price));
    
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

    return Container(
      color: rColor,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          const SizedBox(width: 5,),
          Expanded(
            flex: 1,
            child: Container(
              color: primaryColor,
              padding: const EdgeInsets.fromLTRB(10, 10, 0, 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
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
                          (share > 0 ? "${formatCurrency(share, true, true, true)} ${shareTitle ?? "Shares"}" : "- ${shareTitle ?? "Shares"}"),
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
                            Container(
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
                                  (checkThousandOnPrice ?? false),
                                ),
                                style: const TextStyle(
                                  fontSize: 12,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            )
                          ],
                        ),
                      ),
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