abstract final class Money {
  /// Formats paise as Indian rupees (e.g. 500000 -> ₹5,000).
  static String fromPaise(int? paise) {
    if (paise == null || paise < 0) return '—';
    return formatRupees(paise ~/ 100);
  }

  static String formatRupees(int amount) {
    if (amount < 0) return '—';
    final digits = amount.toString();
    if (digits.length <= 3) return '₹$digits';
    final lastThree = digits.substring(digits.length - 3);
    var prefix = digits.substring(0, digits.length - 3);
    final groups = <String>[];
    while (prefix.length > 2) {
      groups.insert(0, prefix.substring(prefix.length - 2));
      prefix = prefix.substring(0, prefix.length - 2);
    }
    if (prefix.isNotEmpty) groups.insert(0, prefix);
    return '₹${groups.join(',')},$lastThree';
  }

  static int? parsePaise(dynamic value) {
    if (value == null) return null;
    if (value is int) return value >= 0 ? value : null;
    if (value is num) {
      final asInt = value.round();
      return asInt >= 0 ? asInt : null;
    }
    if (value is String) {
      final parsed = int.tryParse(value.trim());
      if (parsed == null || parsed < 0) return null;
      return parsed;
    }
    return null;
  }
}
