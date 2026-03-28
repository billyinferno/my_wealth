import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:ionicons/ionicons.dart';
import 'package:my_wealth/_index.g.dart';

class SimpleListItem extends StatelessWidget {
  final bool? fca;
  final String name;
  final String date;
  final String? dateTitle;
  final double price;
  final String? priceTitle;
  final double percentChange;
  final String? percentChangeTitle;
  final int? percentChangeDecimal;
  final double priceChange;
  final String? priceChangeTitle;
  final int? priceChangeDecimal;
  final int riskFactor;

  const SimpleListItem({
    super.key,
    this.fca,
    required this.name,
    required this.date,
    this.dateTitle,
    required this.price,
    this.priceTitle,
    required this.percentChange,
    this.percentChangeTitle,
    this.percentChangeDecimal,
    required this.priceChange,
    this.priceChangeDecimal,
    this.priceChangeTitle,
    required this.riskFactor,
  });

  @override
  Widget build(BuildContext context) {
    final Color color = riskColor(
      value: (price + priceChange),
      cost: price,
      riskFactor: riskFactor
    );

    return IntrinsicHeight(
      child: Container(
        decoration: BoxDecoration(
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
            Container(
              color: color,
              width: 5,
            ),
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: <Widget>[
                        Visibility(
                          visible: (fca ?? false),
                          child: const Icon(
                            Ionicons.warning,
                            color: secondaryColor,
                            size: 15,
                          )
                        ),
                        Visibility(
                          visible: (fca ?? false),
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
                      ],
                    ),
                    const SizedBox(height: 5,),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: <Widget>[
                        Expanded(
                          child: Text(
                            (dateTitle ?? "Date"),
                            style: TextStyle(
                              fontSize: 10,
                              overflow: TextOverflow.ellipsis,
                            )
                          )
                        ),
                        Expanded(
                          child: Align(
                            alignment: Alignment.centerRight,
                            child: Text(
                              (priceTitle ?? "Price"),
                              style: TextStyle(
                                fontSize: 10,
                                overflow: TextOverflow.ellipsis,
                              )
                            ),
                          )
                        ),
                        Expanded(
                          child: Align(
                            alignment: Alignment.centerRight,
                            child: Text(
                              (percentChangeTitle ?? "% Change"),
                              style: TextStyle(
                                fontSize: 10,
                                overflow: TextOverflow.ellipsis,
                              )
                            ),
                          )
                        ),
                        Expanded(
                          child: Align(
                            alignment: Alignment.centerRight,
                            child: Text(
                              (priceChangeTitle ?? "Change"),
                              style: TextStyle(
                                fontSize: 10,
                                overflow: TextOverflow.ellipsis,
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
                                    color: color,
                                    width: 2.0,
                                    style: BorderStyle.solid,
                                  )
                                ),
                              ),
                              child: Text(
                                "${formatCurrency(
                                  percentChange,
                                  decimalNum: (percentChangeDecimal ?? 2)
                                )}%",
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
                                    color: color,
                                    width: 2.0,
                                    style: BorderStyle.solid,
                                  )
                                ),
                              ),
                              child: Text(
                                formatCurrency(
                                  priceChange,
                                  decimalNum: (priceChangeDecimal ?? 2),
                                ),
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
          ],
        ),
      ),
    );
  }
}