import 'package:flutter/material.dart';
import 'package:my_wealth/themes/colors.dart';
import 'package:my_wealth/utils/function/format_currency.dart';
import 'package:my_wealth/utils/function/risk_color.dart';

class FavouriteList extends StatelessWidget {
  final String name;
  final String date;
  final double price;
  final double percentChange;
  final double priceChange;
  final int riskFactor;

  const FavouriteList({ Key? key, required this.name, required this.date, required this.price, required this.percentChange, required this.priceChange, required this.riskFactor }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final Color _color = riskColor((price + priceChange), price, riskFactor);

    return Container(
      decoration: BoxDecoration(
        color: _color,
        border: const Border(
          bottom: BorderSide(
            color: primaryLight,
            width: 1.0,
            style: BorderStyle.solid,
          )
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          const SizedBox(width: 5,),
          Expanded(
            child: Container(
              color: primaryColor,
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  Text(
                    name,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 10,),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: const <Widget>[
                      Expanded(
                        child: Text(
                          "Date",
                          style: TextStyle(
                            fontSize: 10,
                          )
                        )
                      ),
                      Expanded(
                        child: Align(
                          alignment: Alignment.centerRight,
                          child: Text(
                            "Price",
                            style: TextStyle(
                              fontSize: 10,
                            )
                          ),
                        )
                      ),
                      Expanded(
                        child: Align(
                          alignment: Alignment.centerRight,
                          child: Text(
                            "% Change",
                            style: TextStyle(
                              fontSize: 10,
                            )
                          ),
                        )
                      ),
                      Expanded(
                        child: Align(
                          alignment: Alignment.centerRight,
                          child: Text(
                            "Change",
                            style: TextStyle(
                              fontSize: 10,
                            )
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
                      Expanded(
                        child: Text(
                          date,
                          style: const TextStyle(
                            fontSize: 12,
                          )
                        )
                      ),
                      Expanded(
                        child: Align(
                          alignment: Alignment.centerRight,
                          child: Text(
                            formatCurrency(price),
                            style: const TextStyle(
                              fontSize: 12,
                            )
                          ),
                        )
                      ),
                      Expanded(
                        child: Align(
                          alignment: Alignment.centerRight,
                          child: Container(
                            decoration: BoxDecoration(
                              border: Border(
                                bottom: BorderSide(
                                  color: _color,
                                  width: 2.0,
                                  style: BorderStyle.solid,
                                )
                              ),
                            ),
                            child: Text(
                              formatCurrency(percentChange) + "%",
                              style: const TextStyle(
                                fontSize: 12,
                              )
                            ),
                          ),
                        )
                      ),
                      Expanded(
                        child: Align(
                          alignment: Alignment.centerRight,
                          child: Container(
                            decoration: BoxDecoration(
                              border: Border(
                                bottom: BorderSide(
                                  color: _color,
                                  width: 2.0,
                                  style: BorderStyle.solid,
                                )
                              ),
                            ),
                            child: Text(
                              formatCurrency(priceChange),
                              style: const TextStyle(
                                fontSize: 12,
                              )
                            ),
                          ),
                        )
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 5,),
        ],
      ),
    );
  }
}