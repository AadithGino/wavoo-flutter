import '../network/api_config.dart';

abstract final class Media {
  static String? resolve(String? value) {
    if (value == null) return null;
    final trimmed = value.trim();
    if (trimmed.isEmpty) return null;
    if (trimmed.startsWith('http://') || trimmed.startsWith('https://')) {
      return trimmed;
    }
    if (trimmed.startsWith('//')) return 'https:$trimmed';
    final origin = _apiOrigin();
    if (trimmed.startsWith('/')) return '$origin$trimmed';
    return '$origin/$trimmed';
  }

  static String _apiOrigin() {
    final base = ApiConfig.baseUrl;
    final uri = Uri.tryParse(base);
    if (uri == null || uri.host.isEmpty) return base;
    return uri.origin;
  }
}
