import 'package:intl/intl.dart';

class DateFormatter {
  /// "Sunday 13th May 2:02PM" — always in device local time.
  static String full(DateTime dt) {
    final local = dt.toLocal();
    final day   = DateFormat('EEEE').format(local);
    final month = DateFormat('MMMM').format(local);
    final time  = DateFormat('h:mma').format(local);
    return '$day ${_ordinal(local.day)} $month $time';
  }

  /// "13th May, 2:02PM"
  static String compact(DateTime dt) {
    final local = dt.toLocal();
    final month = DateFormat('MMM').format(local);
    final time  = DateFormat('h:mma').format(local);
    return '${_ordinal(local.day)} $month, $time';
  }

  /// "13th May 2026"
  static String dateOnly(DateTime dt) {
    final local = dt.toLocal();
    final month = DateFormat('MMMM').format(local);
    return '${_ordinal(local.day)} $month ${local.year}';
  }

  /// "Today 2:02PM", "Yesterday 9:15AM", "13th May 2:02PM"
  static String smart(DateTime dt) {
    final local = dt.toLocal();
    final now   = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final day   = DateTime(local.year, local.month, local.day);
    final time  = DateFormat('h:mma').format(local);

    if (day == today) return 'Today $time';
    if (day == today.subtract(const Duration(days: 1))) return 'Yesterday $time';
    return '${_ordinal(local.day)} ${DateFormat('MMM').format(local)} $time';
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
