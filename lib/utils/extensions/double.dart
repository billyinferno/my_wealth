extension CustomComparisonExtension on double {
  double noMinCompare(double compare, String operator) {
    // check whether the operator is "<" or ">"
    if (this > 0 && compare > 0) {
      switch(operator.toLowerCase()) {
        case '<':
          return compare - this;
        case '>':
          return this - compare;
        default:
          return 0;
      }
    }
    else {
      if (this < 0) {
        return -1;
      } else {
        return 0;
      }
    }
  }
}