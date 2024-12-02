import 'package:flutter/material.dart';
import 'package:my_wealth/_index.g.dart';

class AnalysisChart extends StatelessWidget {
  final String title;
  final double pesimistic;
  final double? potentialPesimistic;
  final double neutral;
  final double? potentialNeutral;
  final double optimistic;
  final double? potentialOptimistic;
  final double current;
  const AnalysisChart({
    super.key,
    required this.title,
    required this.pesimistic,
    this.potentialPesimistic,
    required this.neutral,
    this.potentialNeutral,
    required this.optimistic,
    this.potentialOptimistic,
    required this.current,
  });

  @override
  Widget build(BuildContext context) {
    double range = (optimistic - pesimistic);
    int flexPER = (((current  - pesimistic) / range) * 100).toInt();
    Color pointerColor = textPrimary;
    if (current < pesimistic) {
      pointerColor = secondaryDark;
    }

    //TODO: to represent the pointer correctly when the current price is off the chart
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.start,
      children: <Widget>[
        Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 5,),
        SizedBox(
          width: double.infinity,
          child: Stack(
            alignment: Alignment.topLeft,
            children: <Widget>[
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  const SizedBox(height: 2.5,),
                  Container(
                    width: double.infinity,
                    height: 5,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(5),
                      gradient: LinearGradient(
                        colors: <Color>[
                          Colors.red,
                          Colors.green,
                        ]
                      )
                    ),
                  ),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Text(
                        "Pesimistic\n${formatCurrency(pesimistic)}${(potentialPesimistic != null ? " (${formatDecimalWithNull(potentialPesimistic, times: 100, decimal: 2)}%)" : '')}",
                        textAlign: TextAlign.left,
                        style: TextStyle(
                          fontSize: 10,
                          color: secondaryColor,
                        ),
                      ),
                      Text(
                        "Neutral\n${formatCurrency(neutral)}${(potentialNeutral != null ? " (${formatDecimalWithNull(potentialNeutral, times: 100, decimal: 2)}%)" : '')}",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 10,
                          color: Colors.grey,
                        ),
                      ),
                      Text(
                        "Optimistic\n${formatCurrency(optimistic)}${(potentialOptimistic != null ? " (${formatDecimalWithNull(potentialOptimistic, times: 100, decimal: 2)}%)" : '')}",
                        textAlign: TextAlign.right,
                        style: TextStyle(
                          fontSize: 10,
                          color: Colors.green,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      Visibility(
                        visible: (current > pesimistic),
                        child: Expanded(
                          flex: flexPER,
                          child: SizedBox(),
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: <Widget>[
                          Container(
                            width: 10,
                            height: 10,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              color: pointerColor,
                            ),
                          ),
                          Container(
                            height: 25,
                            width: 1,
                            color: pointerColor,
                          ),
                        ],
                      ),
                      Visibility(
                        visible: (current < optimistic),
                        child: Expanded(
                          flex: (100 - flexPER),
                          child: SizedBox(),
                        ),
                      ),
                    ],
                  ),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      Expanded(
                        flex: flexPER,
                        child: SizedBox(),
                      ),
                      Text(
                        "Current\n${formatCurrency(current)}",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 10,
                          color: pointerColor,
                        ),
                      ),
                      Expanded(
                        flex: (100 - flexPER),
                        child: SizedBox(),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}