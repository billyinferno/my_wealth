import 'package:flutter/material.dart';
import 'package:my_wealth/themes/colors.dart';
import 'package:my_wealth/utils/function/format_currency.dart';
import 'package:my_wealth/utils/function/risk_color.dart';

class ExpandedTileChildren extends StatelessWidget {
  final String date;
  final double shares;
  final double price;
  final double currentPrice;
  final int risk;

  const ExpandedTileChildren({ Key? key, required this.date, required this.shares, required this.price, required this.currentPrice, required this.risk }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final _riskColor  = riskColor((shares * currentPrice), (shares * price), risk);
    
    return Container(
      color: _riskColor,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          const SizedBox(width: 5,),
          Expanded(
            child: Container(
              padding: const EdgeInsets.fromLTRB(10, 0, 0, 0),
              color: primaryColor,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  Expanded(
                    flex: 2,
                    child: Text(
                      date,
                      style: const TextStyle(
                        fontSize: 12,
                      ),
                    )
                  ),
                  const SizedBox(width: 10,),
                  Expanded(
                    flex: 3,
                    child: Text(
                      formatCurrency(shares),
                      style: const TextStyle(
                        fontSize: 12,
                      ),
                      overflow: TextOverflow.ellipsis,
                    )
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
                    )
                  ),
                  const SizedBox(width: 45,),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}