import 'package:intl/intl.dart';

String formatCurrency(
  double amount, {
  bool checkThousand = false,
  bool showDecimal = true,
  bool shorten = true,
  int decimalNum = 2
}) {
  NumberFormat ccy = NumberFormat("#,##0.00", "en_US");
  int currentDecimalNum = (showDecimal ? decimalNum : 0);

  if (!showDecimal) {
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
  if(currentAmount >= 1000000000000 && shorten) {
    posfix = "T";
    currentAmount = currentAmount / 1000000000000;
  }
  else if(currentAmount >= 1000000000 && shorten) {
    posfix = "B";
    currentAmount = currentAmount / 1000000000;
  }
  else if(currentAmount >= 1000000 && shorten) {
    posfix = "M";
    currentAmount = currentAmount / 1000000;
  }
  else if(currentAmount >= 1000 && checkThousand && shorten) {
    posfix = "K";
    currentAmount = currentAmount / 1000;
  }

  // format the amount
  result = prefix + ccy.format(currentAmount) + posfix;
  return result;
}

String formatCurrencyWithNull(
  double? amount, {
  bool checkThousand = false,
  bool showDecimal = true,
  bool shorten = true,
  int decimalNum = 2,
}) {
  if (amount == null) {
    return "-";
  }
  else {
    return formatCurrency(
      amount,
      checkThousand: checkThousand,
      showDecimal: showDecimal,
      shorten: shorten,
      decimalNum: decimalNum
    );
  }
}

String formatDecimal(
  double value, {
  double times = 1,
  int decimal = 6
}) {
  String decimalFormat = "0" * decimal;
  NumberFormat decFormat = NumberFormat("##0.$decimalFormat");
  if (decimal > 0) {
    decFormat = NumberFormat("##0.$decimalFormat");
  }
  else {
    decFormat = NumberFormat("##0");
  }
  return decFormat.format(value * times);
}

String formatDecimalWithNull(
  double? value, {
  double times = 1,
  int decimal = 6,
}) {
  if (value == null) {
    return "-";
  }
  return formatDecimal(
    value,
    times: times,
    decimal: decimal,
  );
}

String formatIntWithNull(
  int? value, {
  bool checkThousand = false,
  bool showDecimal = true,
  int decimalNum = 2,
  bool shorten = true
}) {
  if (value == null) {
    return "-";
  }
  return formatCurrency(
    value.toDouble(),
    checkThousand: checkThousand,
    showDecimal: showDecimal,
    shorten: shorten,
    decimalNum: decimalNum
  );
}

double makePositive(double value) {
  if (value < 0) {
    return value * -1;
  }
  return value;
}