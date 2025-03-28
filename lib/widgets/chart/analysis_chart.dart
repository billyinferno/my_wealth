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
    final List<Color> pointerColorList = [
      Color(0xFFFF867C),
      Color(0xFFFFA49D),
      Color(0xFFFFC3BE),
      Color(0xFFFFE1DE),
      Color(0xFFFFFFFF),
      Color(0xFFE2F0D2),
      Color(0xFFC5E1A5),
      Color(0xFFA8D277),
      Color(0xFF8BC34A),
    ];
    // calculate for the left and right padding
    double minData = pesimistic;
    double maxData = optimistic;
    
    // check if current data is below pesimistic or current data is above
    // optimistic value. if so, set apropriate min and max data.
    if (current < minData) {
      minData = current;
    }
    if (current > maxData) {
      maxData = current;
    }

    // calculate the range
    double range = (maxData - minData);

    // calculate the bar flex
    int leftBarFlex = 0;
    int rightBarFlex = 0;

    // only calculate left bar flex if current is less than pesimistic
    if (current < pesimistic) {
      leftBarFlex = (((pesimistic - current) / range) * 100).toInt();
    }

    // only calculateright bar flex if current is more than optimistic
    if (current > optimistic) {
      rightBarFlex = (((current - optimistic) / range) * 100).toInt();
    }

    // calculate the flex needed for the pointer
    int pointerFlex = (((current  - minData) / range) * 100).toInt();
    
    // check what color should we put for the pointer
    int pointerColorIndex = ((((current - minData) / range) * 100).toInt() ~/ 10) - 1;    
    Color pointerColor = Colors.white;
    if (pointerColorIndex < 0) {
      pointerColor = secondaryLight;
    }
    else if (pointerColorIndex >= 0 && pointerColorIndex < pointerColorList.length) {
      pointerColor = pointerColorList[pointerColorIndex];
    }
    else {
      pointerColor = Colors.lightGreen;
    }
    
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
        Stack(
          alignment: Alignment.topLeft,
          children: <Widget>[
            Visibility(
              visible: (current < pesimistic || current > optimistic),
              child: Container(
                height: 10,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: primaryDark,
                  border: Border.all(
                    color: primaryLight,
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                Visibility(
                  visible: (leftBarFlex > 0),
                  child: Expanded(
                    flex: leftBarFlex,
                    child: const SizedBox(),
                  ),
                ),
                Expanded(
                  flex: (100 - (leftBarFlex + rightBarFlex)),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      Container(
                        height: 10,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: <Color>[
                              Colors.red,
                              Colors.green,
                            ]
                          ),
                          border: Border.all(
                            color: primaryLight,
                          ),
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      //TODO: in case the flex is too much like GOTO it causing render flex due to the text is passed the render page
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
                ),
                Visibility(
                  visible: (rightBarFlex > 0),
                  child: Expanded(
                    flex: rightBarFlex,
                    child: const SizedBox(),
                  ),
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
                      visible: (pointerFlex > 0),
                      child: Expanded(
                        flex: pointerFlex,
                        child: const SizedBox(),
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Container(
                          width: 10,
                          height: 10,
                          decoration: BoxDecoration(
                            color: pointerColor,
                            borderRadius: BorderRadius.circular(15),
                            border: Border.all(
                              color: Colors.white,
                              width: 1.0,
                              style: BorderStyle.solid,
                            ),
                          ),
                        ),
                        Container(
                          width: 1,
                          height: 30,
                          decoration: BoxDecoration(
                            color: pointerColor,
                          ),
                        ),
                      ],
                    ),
                    Expanded(
                      flex: (100 - pointerFlex),
                      child: const SizedBox(),
                    ),
                  ],
                ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    Visibility(
                      visible: (pointerFlex > 0),
                      child: Expanded(
                        flex: pointerFlex,
                        child: const SizedBox(),
                      ),
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
                      flex: (100 - pointerFlex),
                      child: const SizedBox(),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }
}