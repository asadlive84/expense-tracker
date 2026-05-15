import 'package:intl/intl.dart';

class DateFormatter {
  /// Returns e.g. "Sunday 13th May 2:02PM"
  static String full(DateTime dt) {
    final day     = DateFormat('EEEE').format(dt);   // Sunday
    final date    = _ordinal(dt.day);                 // 13th
    final month   = DateFormat('MMMM').format(dt);   // May
    final time    = DateFormat('h:mma').format(dt)   // 2:02PM
                      .replaceAll('AM', 'AM')
                      .replaceAll('PM', 'PM');
    return '$day $date $month $time';
  }

  /// Compact: "13th May, 2:02PM"
  static String compact(DateTime dt) {
    final date  = _ordinal(dt.day);
    final month = DateFormat('MMM').format(dt);
    final time  = DateFormat('h:mma').format(dt);
    return '$date $month, $time';
  }

  /// Date only: "13th May 2026"
  static String dateOnly(DateTime dt) {
    final date  = _ordinal(dt.day);
    final month = DateFormat('MMMM').format(dt);
    return '$date $month ${dt.year}';
  }

  /// Smart: "Today 2:02PM", "Yesterday 2:02PM", or "13th May 2:02PM"
  static String smart(DateTime dt) {
    final now   = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final day   = DateTime(dt.year, dt.month, dt.day);

    final time  = DateFormat('h:mma').format(dt);

    if (day == today) return 'Today $time';
    if (day == today.subtract(const Duration(days: 1))) return 'Yesterday $time';
    return '${_ordinal(dt.day)} ${DateFormat('MMM').format(dt)} $time';
  }

  static String _ordinal(int n) {
    if (n >= 11 && n <= 13) return '${n}th';
    switch (n % 10) {
      case 1: return '${n}st';
      case 2: return '${n}nd';
      case 3: return '${n}rd';
      default: return '${n}th';
    }
  }
}
