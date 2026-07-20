import 'package:intl/intl.dart';

class DateFormatter {
  const DateFormatter._();

  static String readableDate(DateTime value) =>
      DateFormat.yMMMd().format(value);

  static String readableDateTime(DateTime value) =>
      DateFormat.yMMMd().add_Hm().format(value);
}
