import 'package:flutter/material.dart';
import 'package:my_wealth/_index.g.dart';

Color riskColor({
  required double value,
  required double cost,
  required int riskFactor,
  Color positiveColor = Colors.green,
  Color negativeColor = Colors.red,
}) {
  // assuming that the colors is green
  Color result = positiveColor;
  // calculate the gain
  double gain = value - cost;

  // if gain is 0, then just return white
  if (gain == 0) {
    result = Colors.white;
    return result;
  }

  // check if gain is less than 0, it means that
  if (gain < 0) {
    gain = gain * (-1);
    result = negativeColor;
  }

  // now calculate the gain percentage from cost
  double gainPercentage = (gain / cost) * 100;
  double riskDouble = riskFactor.toDouble();

  // if gain is more (either positif or negatif), we need to darken the colors
  // else, we can just lighten the color.
  if (gainPercentage > riskDouble) {
    // darken the color
    double darkenValue = ((gainPercentage - riskDouble) / 100);

    // clamp the value to max at 0.3
    if (darkenValue > 0.3) {
      darkenValue = 0.3;
    }

    // print("Darken : " + _darken.toString());
    return darken(result, amount: darkenValue);
  }
  else {
    // lighten the color
    double lightenValue = (riskDouble - gainPercentage) / 100;

    // clamp the value to max at 0.3
    if (lightenValue > 0.3) {
      lightenValue = 0.3;
    }

    // print("Lighten : " + _lighten.toString());
    return lighten(result, amount: lightenValue);
  }
}

Color riskColor2({
  required double percentage,
  required double diff,
  bool reverse = false,
  List<int> colorNumber = const [700, 800, 900],
}) {
  double absPercentage = (percentage < 0 ? percentage * (-1) : percentage);
  int value = (((absPercentage * 100).toInt()) % 100) ~/ 10;
 
  if (reverse) {
    value = 1000 - (value * 100);
  }

  if (value >= 0 && value <= 300) {
    value = colorNumber[0];
  }
  else if(value >= 400 && value <= 700) {
    value = colorNumber[1];
  }
  else {
    value = colorNumber[2];
  }
  
  if (diff < 0) {
    return Colors.red[value]!;
  }
  else {
    return Colors.green[value]!;
  }
}

Color riskColorReverse({required double value, required double cost}) {
  // assuming that the colors is green
  Color result = Colors.green;

  // calculate the gain
  double gain = value - cost;
  int colorIndex = 0;

  // if gain is 0, then just return white
  if (gain == 0) {
    result = primaryDark;
    return result;
  }

  // check if gain is less than 0, it means that
  colorIndex = ((((1 - gain) - 0.1) * 10).toInt() * 100);
  
  // clamp value for color index
  if (colorIndex <= 0 || colorIndex > 900) {
    result = Colors.white;
    return result;
  }
  
  if (colorIndex > 0 && colorIndex <=500) {
    colorIndex = 100;
  }
  else {
    colorIndex = 900;
  }

  if (gain < 0) {
    result = Colors.red[colorIndex]!;
  }
  else {
    result = Colors.green[colorIndex]!;
  }

  return result;
}