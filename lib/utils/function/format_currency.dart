import 'package:intl/intl.dart';

String formatCurrency(double amount, [bool? checkThousand, bool? showDecimal, bool? shorten]) {
  NumberFormat ccy = NumberFormat("#,##0.00", "en_US");
  bool isCheckThousand = checkThousand ?? false;
  bool isShowDecimal = showDecimal ?? true;
  bool isShorten = shorten ?? true;

  if (!isShowDecimal) {
    ccy = NumberFormat("#,##0", "en_US");
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

String formatCurrencyWithNull(double? amount, [bool? checkThousand, bool? showDecimal, bool? shorten]) {
  bool isCheckThousand = checkThousand ?? false;
  bool isShowDecimal = showDecimal ?? true;
  bool isShorten = shorten ?? true;

  if (amount == null) {
    return "-";
  }
  else {
    return formatCurrency(amount, isCheckThousand, isShowDecimal, isShorten);
  }
}

String formatDecimal(double value, [int? decimal]) {
  int dec = (decimal ?? 6);
  String decimalFormat = "0" * dec;
  NumberFormat decFormat = NumberFormat("##0.$decimalFormat");
  return decFormat.format(value);
}

String formatDecimalWithNull(double? value, [double? times, int? decimal]) {
  double timesMult = (times ?? 1);
  int decimalNum = (decimal ?? 6);
  String decimalFormat = "0" * decimalNum;

  NumberFormat dec = NumberFormat("##0.$decimalFormat");
  if (value == null) {
    return "-";
  }
  return dec.format(value * timesMult);
}

String formatIntWithNull(int? value, [bool? checkThousand, bool? showDecimal]) {
  bool isCheckThousand = checkThousand ?? false;
  bool isShowDecimal = showDecimal ?? true;
  if (value == null) {
    return "-";
  }
  return formatCurrency(value.toDouble(), isCheckThousand, isShowDecimal);
}