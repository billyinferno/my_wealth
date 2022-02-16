extension DynamicConversionExtension on dynamic {
  double? toDoubleWithNull() {
    if(this == null) {
      return null;
    }
    else {
      return this.toDouble();
    }
  }
}