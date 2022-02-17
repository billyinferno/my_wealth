import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:ionicons/ionicons.dart';
import 'package:my_wealth/themes/colors.dart';
import 'package:my_wealth/utils/function/format_currency.dart';

class ExpandedTileTitle extends StatelessWidget {
  final String name;
  final int lot;
  final double share;
  final double price;
  final double gain;
  final String lastUpdate;
  final Color? riskColor;

  const ExpandedTileTitle({ Key? key, required this.name, required this.lot, required this.share, required this.price, required this.gain, required this.lastUpdate, this.riskColor }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final _riskColor = (riskColor ?? primaryLight);
    return Container(
      color: _riskColor,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          const SizedBox(width: 5,),
          Expanded(
            flex: 1,
            child: Container(
              color: primaryColor,
              padding: const EdgeInsets.all(10),
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
                              color: _riskColor,
                              width: 2.0,
                              style: BorderStyle.solid,
                            )
                          )
                        ),
                        child: Text(
                          formatCurrency(gain),
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
                          (lot > 0 ? lot.toString() + " Lots" : "- Lots"),
                          style: const TextStyle(
                            fontSize: 12,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10,),
                      Expanded(
                        flex: 3,
                        child: Text(
                          (share > 0 ? formatCurrency(share) + " Shares" : "- Shares"),
                          style: const TextStyle(
                            fontSize: 12,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 10,),
                      Expanded(
                        flex: 2,
                        child: Align(
                          alignment: Alignment.centerRight,
                          child: Text(
                            formatCurrency(price),
                            style: const TextStyle(
                              fontSize: 12,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
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