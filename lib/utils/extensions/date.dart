import 'package:intl/intl.dart';

extension CustomDateFunction on DateTime {
  /// Calculates number of weeks for a given year as per https://en.wikipedia.org/wiki/ISO_week_date#Weeks_per_year
  int numOfWeeks(int year) {
    DateTime dec28 = DateTime(year , 12, 28);
    int dayOfDec28 = int.parse(DateFormat("D").format(dec28));
    return ((dayOfDec28 - dec28.weekday + 10) / 7).floor();
  }

  /// Calculates week number from a date as per https://en.wikipedia.org/wiki/ISO_week_date#Calculation
  int weekNumber() {
    int dayOfYear = int.parse(DateFormat("D").format(this));
    int woy =  ((dayOfYear - weekday + 10) / 7).floor();
    if (woy < 1) {
      woy = numOfWeeks(year - 1);
    } else if (woy > numOfWeeks(year)) {
      woy = 1;
    }
    return woy;
  }

  bool isSameDate({required DateTime date}) {
    if (year == date.year) {
      if (month == date.month) {
        if (day == date.day) {
          return true;
        }
      }
    }

    return false;
  }

  bool isBeforeDate({required DateTime date}) {
    final DateTime dt1 = DateTime(year, month, day);
    final DateTime dt2 = DateTime(date.year, date.month, date.day);

    if (dt1.isBefore(dt2)) {
      return true;
    }
    return false;
  }

  bool isAfterDate({required DateTime date}) {
    final DateTime dt1 = DateTime(year, month, day);
    final DateTime dt2 = DateTime(date.year, date.month, date.day);

    if (dt1.isAfter(dt2)) {
      return true;
    }
    return false;
  }

  bool isSameOrBefore({required DateTime date}) {
    if (isSameDate(date: date) || isBeforeDate(date: date)) {
      return true;
    }
    return false;
  }

  bool isSameOrAfter({
    required DateTime date
  }) {
    if (isSameDate(date: date) || isAfterDate(date: date)) {
      return true;
    }
    return false;
  }
}