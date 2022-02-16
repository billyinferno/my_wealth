import 'package:flutter/material.dart';
import 'package:my_wealth/utils/function/color_utils.dart';

Color riskColor(double value, double cost, int riskFactor, [Color? positiveColor, Color? negativeColor]) {
  // assuming that the colors is green
  Color _result = (positiveColor ?? Colors.green);
  // calculate the gain
  double _gain = value - cost;

  // if gain is 0, then just return white
  if (_gain == 0) {
    _result = Colors.white;
    return _result;
  }

  // check if gain is less than 0, it means that
  if (_gain < 0) {
    _gain = _gain * (-1);
    _result = (negativeColor ?? Colors.red);
  }

  // now calculate the gain percentage from cost
  double _gainPercentage = (_gain / cost) * 100;
  double _riskDouble = riskFactor.toDouble();

  // if gain is more (either positif or negatif), we need to darken the colors
  // else, we can just lighten the color.
  if (_gainPercentage > _riskDouble) {
    // darken the color
    double _darken = ((_gainPercentage - _riskDouble) / 100);

    // clamp the value to max at 0.3
    if (_darken > 0.3) {
      _darken = 0.3;
    }

    // print("Darken : " + _darken.toString());
    return darken(_result, _darken);
  }
  else {
    // lighten the color
    double _lighten = (_riskDouble - _gainPercentage) / 100;

    // clamp the value to max at 0.3
    if (_lighten > 0.3) {
      _lighten = 0.3;
    }

    // print("Lighten : " + _lighten.toString());
    return lighten(_result, _lighten);
  }
}