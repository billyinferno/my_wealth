import 'package:intl/intl.dart';

String formatCurrency(double amount, [bool? checkThousand, bool? showDecimal, bool? shorten, int? decimalNum]) {
  NumberFormat ccy = NumberFormat("#,##0.00", "en_US");
  bool isCheckThousand = checkThousand ?? false;
  bool isShowDecimal = showDecimal ?? true;
  bool isShorten = shorten ?? true;
  int currentDecimalNum = (isShowDecimal ? (decimalNum ?? 2) : 0);

  if (!isShowDecimal) {
    ccy = NumberFormat("#,##0", "en_US");
  }
  else {
    // if current decimal num more than 0, then set the correct decimal num
    if (currentDecimalNum > 0) {
      String dec = "0" * currentDecimalNum;
      ccy = NumberFormat("#,##0.$dec", "en_US");
    }
    else {
      // decimal set as 0
      ccy = NumberFormat("#,##0", "en_US");
    }
  }

  String prefix = "";
  String posfix = "";
  String result = "";
  double currentAmount = amount;
  if(currentAmount < 0) {
    // make it a positive
    currentAmount = currentAmount * (-1);
    prefix = "-";
  }

  // check if this is more than trillion?
  if(currentAmount >= 1000000000000 && isShorten) {
    posfix = "T";
    currentAmount = currentAmount / 1000000000000;
  }
  else if(currentAmount >= 1000000000 && isShorten) {
    posfix = "B";
    currentAmount = currentAmount / 1000000000;
  }
  else if(currentAmount >= 1000000 && isShorten) {
    posfix = "M";
    currentAmount = currentAmount / 1000000;
  }
  else if(currentAmount >= 1000 && isCheckThousand && isShorten) {
    posfix = "K";
    currentAmount = currentAmount / 1000;
  }

  // format the amount
  result = prefix + ccy.format(currentAmount) + posfix;
  return result;
}

String formatCurrencyWithNull(double? amount, [bool? checkThousand, bool? showDecimal, bool? shorten, int? decimalNum]) {
  bool isCheckThousand = checkThousand ?? false;
  bool isShowDecimal = showDecimal ?? true;
  bool isShorten = shorten ?? true;

  if (amount == null) {
    return "-";
  }
  else {
    return formatCurrency(amount, isCheckThousand, isShowDecimal, isShorten, decimalNum);
  }
}

String formatDecimal(double value, [int? decimal]) {
  int dec = (decimal ?? 6);
  String decimalFormat = "0" * dec;
  NumberFormat decFormat = NumberFormat("##0.$decimalFormat");
  if (dec > 0) {
    decFormat = NumberFormat("##0.$decimalFormat");
  }
  else {
    decFormat = NumberFormat("##0");
  }
  return decFormat.format(value);
}

String formatDecimalWithNull(double? value, [double? times, int? decimal]) {
  double timesMult = (times ?? 1);
  int decimalNum = (decimal ?? 6);
  String decimalFormat = "0" * decimalNum;

  NumberFormat dec;
  if (decimalNum > 0) {
    dec = NumberFormat("##0.$decimalFormat");
  }
  else {
    dec = NumberFormat("##0");
  }
  if (value == null) {
    return "-";
  }
  return dec.format(value * timesMult);
}

String formatIntWithNull(int? value, [bool? checkThousand, bool? showDecimal, int? decimalNum]) {
  bool isCheckThousand = checkThousand ?? false;
  bool isShowDecimal = showDecimal ?? true;
  if (value == null) {
    return "-";
  }
  return formatCurrency(value.toDouble(), isCheckThousand, isShowDecimal, true, decimalNum);
}

double makePositive(double value) {
  if (value < 0) {
    return value * -1;
  }
  return value;
}