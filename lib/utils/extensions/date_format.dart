import 'package:intl/intl.dart';

extension CustomDateFormat on DateFormat {
  String formatDateWithNull(DateTime? date, {String nullText = '-'}) {
    if (date == null) {
      return nullText;
    }
    return format(date.toLocal());
  }
}