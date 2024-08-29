import 'package:intl/intl.dart';
import 'package:my_wealth/_index.g.dart';

String formatDate(
  DateTime date, {
  required String format
}) {
  final DateFormat df = DateFormat(format);
  return df.format(date);
}

String formatDateWithNulll(
  DateTime? date, {
  DateFormat? format
}) {
  if (date == null) {
    return '-';
  }
  else {
    if (format != null) {
      return format.format(date.toLocal());
    }
    else {
      return Globals.dfDDMMMyyyy.format(date.toLocal());
    }
  }
}

bool isSameDate({
  required DateTime date1,
  required DateTime date2
}) {
  if (date1.year == date2.year) {
    if (date1.month == date2.month) {
      if (date1.day == date2.day) {
        return true;
      }
    }
  }

  return false;
}

bool isBeforeDate({
  required DateTime date1,
  required DateTime date2
}) {
  final DateTime dt1 = DateTime(date1.year, date1.month, date1.day);
  final DateTime dt2 = DateTime(date2.year, date2.month, date2.day);

  if (dt1.isBefore(dt2)) {
    return true;
  }
  return false;
}

bool isAfterDate({
  required DateTime date1,
  required DateTime date2
}) {
  final DateTime dt1 = DateTime(date1.year, date1.month, date1.day);
  final DateTime dt2 = DateTime(date2.year, date2.month, date2.day);

  if (dt1.isAfter(dt2)) {
    return true;
  }
  return false;
}

bool isSameOrBefore({
  required DateTime date,
  required DateTime checkDate
}) {
  if (isSameDate(date1: date, date2: checkDate) || isBeforeDate(date1: date, date2: checkDate)) {
    return true;
  }
  return false;
}

bool isSameOrAfter({
  required DateTime date,
  required DateTime checkDate
}) {
  if (isSameDate(date1: date, date2: checkDate) || isAfterDate(date1: date, date2: checkDate)) {
    return true;
  }
  return false;
}