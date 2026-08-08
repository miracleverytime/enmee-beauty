/// Formatter terpusat untuk currency, angka, dan tanggal.
///
/// - [currency]   : format dengan pemisah titik, mis. "1.250.000".
/// - [currencyRp] : tambahkan prefix "Rp ".
/// - [number]     : format integer dengan pemisah titik, mis. "1.234".
/// - [compact]    : ringkasan (rb / jt / M) untuk tampilan summary stat.
/// - [dateShort]  : format tanggal ringkas, mis. "Hari ini · 14.30"
///                  atau "12 Mar · 09.05".
class Formatters {
  Formatters._();

  static final _thousandSep = RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))');

  /// Format angka dengan pemisah titik: 1250000 -> "1.250.000".
  static String number(num value) {
    final s = value.toString();
    if (s.contains('.')) {
      final parts = s.split('.');
      parts[0] = parts[0].replaceAllMapped(_thousandSep, (m) => '${m[1]}.');
      return parts.join('.');
    }
    return s.replaceAllMapped(_thousandSep, (m) => '${m[1]}.');
  }

  /// Format currency tanpa prefix: 1500000 -> "1.500.000".
  static String currency(double amount) => number(amount.truncate());

  /// Format currency dengan prefix "Rp ": 1500000 -> "Rp 1.500.000".
  static String currencyRp(double amount) => 'Rp ${currency(amount)}';

  /// Format ringkas untuk stat card: rb / jt / M (uppercase).
  ///
  /// Mengembalikan [value] string numerik dan opsional [unit] yang bisa
  /// ditampilkan terpisah oleh caller.
  static CompactNumber compact(double amount) {
    if (amount.abs() >= 1000000000) {
      return CompactNumber(
        value: (amount / 1000000000).toStringAsFixed(1),
        unit: 'M',
      );
    }
    if (amount.abs() >= 1000000) {
      return CompactNumber(
        value: (amount / 1000000).toStringAsFixed(1),
        unit: 'JT',
      );
    }
    if (amount.abs() >= 1000) {
      return CompactNumber(
        value: (amount / 1000).toStringAsFixed(0),
        unit: 'RB',
      );
    }
    return CompactNumber(
      value: amount.toStringAsFixed(0),
      unit: null,
    );
  }

  /// Format tanggal ISO8601 string ke bentuk ringkas Indonesia.
  ///
  /// - Hari yang sama -> "Hari ini · HH.mm"
  /// - Lainnya        -> "DD MMM · HH.mm"  (mis. "12 Mar · 09.05")
  /// - Parse error    -> kembalikan string asli.
  static String dateShort(String isoDate) {
    try {
      final date = DateTime.parse(isoDate);
      final now = DateTime.now();

      final hour = date.hour.toString().padLeft(2, '0');
      final minute = date.minute.toString().padLeft(2, '0');

      if (date.year == now.year &&
          date.month == now.month &&
          date.day == now.day) {
        return 'Hari ini · $hour.$minute';
      }

      const months = [
        'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
        'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des',
      ];
      final day = date.day.toString().padLeft(2, '0');
      return '$day ${months[date.month - 1]} · $hour.$minute';
    } catch (_) {
      return isoDate;
    }
  }
}

/// Hasil [Formatters.compact] — value numerik + unit opsional.
class CompactNumber {
  final String value;
  final String? unit;

  const CompactNumber({required this.value, required this.unit});
}
