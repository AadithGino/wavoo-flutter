class ApiException implements Exception {
  ApiException({
    required this.message,
    this.code,
    this.statusCode,
    this.retryable = false,
    this.details = const [],
  });

  final String message;
  final String? code;
  final int? statusCode;
  final bool retryable;
  final List<dynamic> details;

  bool get isUnauthorized =>
      statusCode == 401 ||
      code == 'SESSION_EXPIRED' ||
      code == 'AUTHENTICATION_REQUIRED';

  @override
  String toString() => message;
}
