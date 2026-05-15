import 'package:intl/intl.dart';

/// Formats integer paisa into Bangladeshi Taka string.
/// Rule: 14250000 (paisa) -> "৳ 1,42,500" (Taka)
class MoneyFormatter {
  static String format(int paisa) {
    final taka = paisa / 100;
    final isNegative = taka < 0;
    final absoluteTaka = taka.abs();
    
    // Split into integer and fractional parts (though we expect round Taka usually)
    final parts = absoluteTaka.toStringAsFixed(2).split('.');
    String integerPart = parts[0];
    final decimalPart = parts[1] == '00' ? '' : '.${parts[1]}';

    // Lakh-style grouping logic (3, 2, 2...)
    String result = '';
    if (integerPart.length <= 3) {
      result = integerPart;
    } else {
      // Last 3 digits
      result = integerPart.substring(integerPart.length - 3);
      String remaining = integerPart.substring(0, integerPart.length - 3);
      
      // Group the rest in 2s
      while (remaining.length > 2) {
        result = '${remaining.substring(remaining.length - 2)},$result';
        remaining = remaining.substring(0, remaining.length - 2);
      }
      if (remaining.isNotEmpty) {
        result = '$remaining,$result';
      }
    }

    final sign = isNegative ? '−' : '';
    return '$sign৳ $result$decimalPart';
  }
}
