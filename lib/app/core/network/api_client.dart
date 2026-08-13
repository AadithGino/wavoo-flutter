import 'dart:async';

import 'package:dio/dio.dart';

import 'api_config.dart';
import 'api_exception.dart';
import 'session_store.dart';

typedef SessionExpiredCallback = void Function();

class ApiClient {
  ApiClient({
    SessionExpiredCallback? onSessionExpired,
    SessionStore? sessionStore,
  })  : _onSessionExpired = onSessionExpired,
        _session = sessionStore ?? SessionStore();

  final SessionExpiredCallback? _onSessionExpired;
  final SessionStore _session;
  late final Dio _dio;
  Completer<bool>? _refreshing;
  bool _initialized = false;

  Dio get dio => _dio;
  SessionStore get session => _session;

  Future<bool> get hasSession => _session.hasSession;

  Future<void> init() async {
    if (_initialized) return;
    await _session.init();
    _dio = Dio(
      BaseOptions(
        baseUrl: ApiConfig.baseUrl,
        connectTimeout: ApiConfig.connectTimeout,
        receiveTimeout: ApiConfig.receiveTimeout,
        headers: const {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
      ),
    );
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          await _attachSessionCookies(options);
          handler.next(options);
        },
        onResponse: (response, handler) async {
          await _captureSessionCookies(response.headers);
          handler.next(response);
        },
        onError: (error, handler) async {
          final headers = error.response?.headers;
          if (headers != null) await _captureSessionCookies(headers);
          handler.next(error);
        },
      ),
    );
    _initialized = true;
  }

  Future<void> _attachSessionCookies(RequestOptions options) async {
    final access = await _session.accessToken;
    final refresh = await _session.refreshToken;
    if (access == null && refresh == null) return;
    final parts = <String>[
      if (access != null && access.isNotEmpty) 'access_token=$access',
      if (refresh != null && refresh.isNotEmpty) 'refresh_token=$refresh',
    ];
    if (parts.isEmpty) return;
    options.headers['Cookie'] = parts.join('; ');
  }

  Future<void> _captureSessionCookies(Headers headers) async {
    final raw = headers.map['set-cookie'] ?? headers.map['Set-Cookie'] ?? const [];
    for (final header in raw) {
      final first = header.split(';').first;
      final eq = first.indexOf('=');
      if (eq <= 0) continue;
      final name = first.substring(0, eq).trim();
      final value = first.substring(eq + 1).trim();
      if (value.isEmpty) continue;
      if (name == 'access_token') {
        await _session.saveAccessToken(value);
      } else if (name == 'refresh_token') {
        await _session.saveRefreshToken(value);
      }
    }
  }

  Future<T> get<T>(
    String path, {
    Map<String, dynamic>? query,
    T Function(dynamic data)? parser,
  }) =>
      _request('GET', path, query: query, parser: parser);

  Future<T> post<T>(
    String path, {
    Object? body,
    Map<String, dynamic>? query,
    T Function(dynamic data)? parser,
  }) =>
      _request('POST', path, body: body, query: query, parser: parser);

  Future<T> _request<T>(
    String method,
    String path, {
    Object? body,
    Map<String, dynamic>? query,
    T Function(dynamic data)? parser,
    bool retried = false,
  }) async {
    await init();
    try {
      final response = await _dio.request<dynamic>(
        path,
        data: body,
        queryParameters: query,
        options: Options(
          method: method,
          validateStatus: (status) => status != null && status < 600,
        ),
      );

      final status = response.statusCode ?? 0;
      final code = _errorCode(response.data);
      final isAuthFailure = status == 401 ||
          code == 'SESSION_EXPIRED' ||
          code == 'AUTHENTICATION_REQUIRED';
      final skipRefresh = path.contains('/auth/refresh') ||
          path.contains('/auth/customer/otp') ||
          path.contains('/auth/customer/register') ||
          path.contains('/auth/login') ||
          path.contains('/auth/logout');

      if (isAuthFailure && !skipRefresh && !retried) {
        final refreshed = await refreshSession();
        if (refreshed) {
          return _request(
            method,
            path,
            body: body,
            query: query,
            parser: parser,
            retried: true,
          );
        }
        await clearSession();
        _onSessionExpired?.call();
        throw ApiException(
          message: 'Session expired. Please sign in again.',
          code: code ?? 'SESSION_EXPIRED',
          statusCode: 401,
        );
      }

      return _parseResponse(response, parser);
    } on ApiException {
      rethrow;
    } on DioException catch (e) {
      throw _mapDioError(e);
    }
  }

  T _parseResponse<T>(Response<dynamic> response, T Function(dynamic data)? parser) {
    final status = response.statusCode ?? 0;
    final raw = response.data;

    if (raw is! Map) {
      if (status >= 200 && status < 300) {
        if (parser != null) return parser(raw);
        return raw as T;
      }
      throw ApiException(
        message: 'Unexpected response from server',
        statusCode: status,
      );
    }

    final map = Map<String, dynamic>.from(raw);
    final success = map['success'] == true;
    if (success && status >= 200 && status < 300) {
      final data = map['data'];
      if (parser != null) return parser(data);
      return data as T;
    }

    final error = map['error'];
    if (error is Map) {
      throw ApiException(
        message: (error['message'] as String?)?.trim().isNotEmpty == true
            ? error['message'] as String
            : 'Request failed',
        code: error['code'] as String?,
        statusCode: status,
        retryable: error['retryable'] == true,
        details: error['details'] is List ? error['details'] as List : const [],
      );
    }

    throw ApiException(
      message: 'Request failed',
      statusCode: status,
    );
  }

  ApiException _mapDioError(DioException e) {
    final response = e.response;
    if (response != null) {
      try {
        return _parseResponse(response, null) as Never;
      } on ApiException catch (api) {
        return api;
      } catch (_) {}
    }
    if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.receiveTimeout ||
        e.type == DioExceptionType.sendTimeout) {
      return ApiException(
        message: 'Connection timed out. Please try again.',
        retryable: true,
      );
    }
    if (e.type == DioExceptionType.connectionError) {
      return ApiException(
        message: 'Unable to reach Wavoo servers. Check your connection.',
        retryable: true,
      );
    }
    return ApiException(message: e.message ?? 'Network error', retryable: true);
  }

  String? _errorCode(dynamic data) {
    if (data is Map && data['error'] is Map) {
      return data['error']['code'] as String?;
    }
    return null;
  }

  Future<bool> refreshSession() async {
    if (_refreshing != null) return _refreshing!.future;
    final completer = Completer<bool>();
    _refreshing = completer;
    try {
      await init();
      final refresh = await _session.refreshToken;
      if (refresh == null || refresh.isEmpty) {
        completer.complete(false);
        return false;
      }
      final response = await _dio.post<dynamic>(
        '/auth/refresh',
        options: Options(validateStatus: (status) => status != null && status < 600),
      );
      await _captureSessionCookies(response.headers);
      final ok = response.statusCode != null &&
          response.statusCode! >= 200 &&
          response.statusCode! < 300 &&
          response.data is Map &&
          (response.data as Map)['success'] == true;
      completer.complete(ok);
      return ok;
    } catch (_) {
      completer.complete(false);
      return false;
    } finally {
      _refreshing = null;
    }
  }

  Future<void> clearSession() async {
    await init();
    await _session.clear();
  }
}
