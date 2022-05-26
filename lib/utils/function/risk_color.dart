import 'package:flutter/material.dart';
import 'package:my_wealth/utils/function/color_utils.dart';

Color riskColor(double value, double cost, int riskFactor, [Color? positiveColor, Color? negativeColor]) {
  // assuming that the colors is green
  Color result = (positiveColor ?? Colors.green);
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
    result = (negativeColor ?? Colors.red);
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
    return darken(result, darkenValue);
  }
  else {
    // lighten the color
    double lightenValue = (riskDouble - gainPercentage) / 100;

    // clamp the value to max at 0.3
    if (lightenValue > 0.3) {
      lightenValue = 0.3;
    }

    // print("Lighten : " + _lighten.toString());
    return lighten(result, lightenValue);
  }
}