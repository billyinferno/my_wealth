import 'package:flutter/material.dart';
import 'package:my_wealth/themes/colors.dart';
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

Color riskColor2({
  required double percentage,
  required double diff,
  bool? reverse,
  List<int>? colorNumber,
}) {
  double absPercentage = (percentage < 0 ? percentage * (-1) : percentage);
  int value = (((absPercentage * 100).toInt()) % 100) ~/ 10;
  List<int> colorValue = [];

  // assign default color to color value
  colorValue.add(700);
  colorValue.add(800);
  colorValue.add(900);

  // check if color number being passed is not null
  if (colorNumber != null) {
    // ensure the length is 3
    if (colorNumber.length == 3) {
      // we can just assign color value to color number
      colorValue = colorNumber;
    }
  }

  if (reverse ?? false) {
    value = 1000 - (value * 100);
  }

  if (value >= 0 && value <= 300) {
    value = colorValue[0];
  }
  else if(value >= 400 && value <= 700) {
    value = colorValue[1];
  }
  else {
    value = colorValue[2];
  }
  
  if (diff < 0) {
    return Colors.red[value]!;
  }
  else {
    return Colors.green[value]!;
  }
}

Color riskColorReverse(double value, double cost) {
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