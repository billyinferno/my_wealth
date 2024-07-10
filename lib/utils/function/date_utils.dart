import 'package:intl/intl.dart';
import 'package:my_wealth/utils/globals.dart';

/// Calculates number of weeks for a given year as per https://en.wikipedia.org/wiki/ISO_week_date#Weeks_per_year
int numOfWeeks(int year) {
  DateTime dec28 = DateTime(year, 12, 28);
  int dayOfDec28 = int.parse(DateFormat("D").format(dec28));
  return ((dayOfDec28 - dec28.weekday + 10) / 7).floor();
}

/// Calculates week number from a date as per https://en.wikipedia.org/wiki/ISO_week_date#Calculation
int weekNumber(DateTime date) {
  int dayOfYear = int.parse(DateFormat("D").format(date));
  int woy =  ((dayOfYear - date.weekday + 10) / 7).floor();
  if (woy < 1) {
    woy = numOfWeeks(date.year - 1);
  } else if (woy > numOfWeeks(date.year)) {
    woy = 1;
  }
  return woy;
}

String formatDate({required DateTime date, required String format}) {
  final DateFormat df = DateFormat(format);
  return df.format(date);
}

String formatDateWithNulll({required DateTime? date, DateFormat? format}) {
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

bool isSameDate({required DateTime date1, required DateTime date2}) {
  if (date1.year == date2.year) {
    if (date1.month == date2.month) {
      if (date1.day == date2.day) {
        return true;
      }
    }
  }

  return false;
}

bool isBeforeDate({required DateTime date1, required DateTime date2}) {
  final DateTime dt1 = DateTime(date1.year, date1.month, date1.day);
  final DateTime dt2 = DateTime(date2.year, date2.month, date2.day);

  if (dt1.isBefore(dt2)) {
    return true;
  }
  return false;
}

bool isSameOrBefore({required DateTime date, required DateTime checkDate}) {
  if (isSameDate(date1: date, date2: checkDate) || isBeforeDate(date1: date, date2: checkDate)) {
    return true;
  }
  return false;
}