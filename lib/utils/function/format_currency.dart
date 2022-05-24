import 'package:intl/intl.dart';

String formatCurrency(double amount, [bool? checkThousand]) {
  final _ccy = NumberFormat("#,##0.00", "en_US");
  bool _checkThousand = checkThousand ?? false;

  String _prefix = "";
  String _posfix = "";
  String _result = "";
  double _amount = amount;
  if(_amount < 0) {
    // make it a positive
    _amount = _amount * (-1);
    _prefix = "-";
  }

  // check if this is more than trillion?
  if(_amount >= 1000000000000) {
    _posfix = "T";
    _amount = _amount / 1000000000000;
  }
  else if(_amount >= 1000000000) {
    _posfix = "B";
    _amount = _amount / 1000000000;
  }
  else if(_amount >= 1000000) {
    _posfix = "M";
    _amount = _amount / 1000000;
  }
  else if(_amount >= 1000 && _checkThousand) {
    _posfix = "K";
    _amount = _amount / 1000;
  }

  // format the amount
  _result = _prefix + _ccy.format(_amount) + _posfix;
  return _result;
}

String formatCurrencyWithNull(double? amount) {
  if (amount == null) {
    return "-";
  }
  else {
    return formatCurrency(amount);
  }
}

String formatDecimal(double value, [int? decimal]) {
  int _decimal = (decimal ?? 6);
  String _decimalFormat = "0" * _decimal;
  NumberFormat _dec = NumberFormat("##0." + _decimalFormat);
  return _dec.format(value);
}

String formatDecimalWithNull(double? value, [double? times, int? decimal]) {
  double _times = (times ?? 1);
  int _decimal = (decimal ?? 6);
  String _decimalFormat = "0" * _decimal;

  NumberFormat _dec = NumberFormat("##0." + _decimalFormat);
  if (value == null) {
    return "-";
  }
  return _dec.format(value * _times);
}

String formatIntWithNull(int? value) {
  if (value == null) {
    return "-";
  }
  return formatCurrency(value.toDouble());
}