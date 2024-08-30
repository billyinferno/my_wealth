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
