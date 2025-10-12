import 'package:flutter/material.dart';
import 'package:my_wealth/_index.g.dart';

int? diffIntWithNull(int? a, int? b) {
  if (a == null || b == null) {
    return null;
  }
  else {
    return (a - b);
  }
}

double? diffDoubleWithNull(double? a, double? b) {
  if (a == null || b == null) {
    return null;
  }
  else {
    return (a - b);
  }
}

Color colorDiffIntWithNull(int? a, int? b) {
  if (a == null || b == null) {
    return primaryLight;
  }
  else {
    if (a > b) {
      return Colors.green;
    }
    else if (a < b) {
      return Colors.red;
    }
    else {
      return primaryLight;
    }
  }
}

Color colorDiffDoubleWithNull(double? a, double? b) {
  if (a == null || b == null) {
    return primaryLight;
  }
  else {
    if (a > b) {
      return Colors.green;
    }
    else if (a < b) {
      return Colors.red;
    }
    else {
      return primaryLight;
    }
  }
}