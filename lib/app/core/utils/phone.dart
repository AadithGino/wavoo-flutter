abstract final class PhoneUtils {
  /// Normalizes Indian mobiles to E.164 `+91XXXXXXXXXX`.
  static String? normalizeIndian(String raw) {
    final digits = raw.replaceAll(RegExp(r'\D'), '');
    if (digits.length == 10 && RegExp(r'^[6-9]').hasMatch(digits)) {
      return '+91$digits';
    }
    if (digits.length == 12 && digits.startsWith('91')) {
      final local = digits.substring(2);
      if (RegExp(r'^[6-9]\d{9}$').hasMatch(local)) return '+91$local';
    }
    if (digits.length == 11 && digits.startsWith('0')) {
      final local = digits.substring(1);
      if (RegExp(r'^[6-9]\d{9}$').hasMatch(local)) return '+91$local';
    }
    return null;
  }

  static String display(String? e164) {
    if (e164 == null || e164.isEmpty) return '';
    if (e164.startsWith('+91') && e164.length == 13) {
      return '+91 ${e164.substring(3)}';
    }
    return e164;
  }
}
