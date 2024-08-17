import 'package:flutter/material.dart';
import 'package:my_wealth/_index.g.dart';

class ExpandedTileChildren extends StatelessWidget {
  final String date;
  final double shares;
  final bool isInLot;
  final double price;
  final double currentPrice;
  final double averagePrice;
  final int risk;
  final bool calculateLoss;

  const ExpandedTileChildren(
      {super.key,
      required this.date,
      required this.shares,
      required this.isInLot,
      required this.price,
      required this.currentPrice,
      required this.averagePrice,
      required this.risk,
      required this.calculateLoss,
    });

  @override
  Widget build(BuildContext context) {
    Color rColor = riskColor((shares * currentPrice), (shares * price), risk);
    if (!calculateLoss) {
      rColor = Colors.black;
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.start,
      children: <Widget>[
        Container(
          width: 5,
          height: 16,
          color: (shares > 0 ? rColor : Colors.blue),
        ),
        const SizedBox(width: 10,),
        Expanded(
          child: Text(
            date,
            style: const TextStyle(
              fontSize: 10,
            ),
          )
        ),
        const SizedBox(width: 10,),
        Expanded(
          child: Text(
            formatDecimal((shares > 0 ? (isInLot ? shares / 100 : shares) : ((isInLot ? shares / 100 : shares) * -1)), 2),
            style: const TextStyle(
              fontSize: 10,
            ),
            overflow: TextOverflow.ellipsis,
          )
        ),
        const SizedBox(width: 10,),
        Expanded(
          child: Align(
            alignment: Alignment.centerRight,
            child: Text(
              formatCurrency(price),
              style: const TextStyle(
                fontSize: 10,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          )
        ),
        const SizedBox(width: 10,),
        Expanded(
          child: Align(
            alignment: Alignment.centerRight,
            child: Container(
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: (shares > 0 ? rColor : Colors.blue),
                    width: 2.0,
                    style: BorderStyle.solid,
                  )
                )
              ),
              child: Text(
                (calculateLoss ? (shares > 0 ? formatCurrency((currentPrice - price) * shares) : formatCurrency(averagePrice * (shares * -1))) : "-"),
                style: const TextStyle(
                  fontSize: 10,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          )
        ),
        const SizedBox(width: 35,),
      ],
    );
  }
}
