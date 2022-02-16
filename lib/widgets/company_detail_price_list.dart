import 'package:flutter/material.dart';
import 'package:my_wealth/themes/colors.dart';

class CompanyDetailPriceList extends StatelessWidget {
  final String date;
  final String price;
  final String diff;
  final Color riskColor;
  const CompanyDetailPriceList({ Key? key, required this.date, required this.price, required this.diff, required this.riskColor }) : super(key: key);

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
                    flex: 1,
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
                    flex: 1,
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
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}