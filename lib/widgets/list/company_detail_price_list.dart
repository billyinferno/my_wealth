import 'package:flutter/material.dart';
import 'package:my_wealth/themes/colors.dart';

class CompanyDetailList {
  final DateTime date;
  final double price;
  final double diff;
  final Color riskColor;
  final double? dayDiff;
  final Color dayDiffColor;

  const CompanyDetailList({
    required this.date,
    required this.price,
    required this.diff,
    required this.riskColor,
    this.dayDiff,
    required this.dayDiffColor,
  });
}

class CompanyDetailPriceList extends StatelessWidget {
  final String date;
  final String price;
  final String diff;
  final Color riskColor;
  final String dayDiff;
  final Color dayDiffColor;
  const CompanyDetailPriceList({ super.key, required this.date, required this.price, required this.diff, required this.riskColor, required this.dayDiff, required this.dayDiffColor });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: riskColor,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          const SizedBox(width: 10,),
          Expanded(
            child: Container(
              color: primaryColor,
              padding: const EdgeInsets.all(10),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  Expanded(
                    flex: 3,
                    child: Text(
                      date,
                      style: const TextStyle(
                        fontSize: 12,
                      ),
                    )
                  ),
                  const SizedBox(width: 10,),
                  Expanded(
                    flex: 2,
                    child: Text(
                      price,
                      textAlign: TextAlign.right,
                      style: const TextStyle(
                        fontSize: 12,
                      ),
                    )
                  ),
                  const SizedBox(width: 10,),
                  Expanded(
                    flex: 2,
                    child: Container(
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
                        diff,
                        textAlign: TextAlign.right,
                        style: const TextStyle(
                          fontSize: 12,
                        ),
                      )
                    )
                  ),
                  const SizedBox(width: 10,),
                  Expanded(
                    flex: 2,
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border(
                          bottom: BorderSide(
                            color: dayDiffColor,
                            width: 2.0,
                            style: BorderStyle.solid,
                          )
                        )
                      ),
                      child: Text(
                        dayDiff,
                        textAlign: TextAlign.right,
                        style: const TextStyle(
                          fontSize: 12,
                        ),
                      )
                    )
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}