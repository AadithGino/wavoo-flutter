import '../../core/network/api_client.dart';
import '../../core/utils/phone.dart';
import '../models/user.dart';

class AuthRepository {
  AuthRepository(this._client);

  final ApiClient _client;

  Future<OtpChallenge> requestOtp(String mobileRaw) async {
    final mobile = PhoneUtils.normalizeIndian(mobileRaw);
    if (mobile == null) {
      throw Exception('Enter a valid 10-digit Indian mobile number');
    }
    final data = await _client.post<Map<String, dynamic>>(
      '/auth/customer/otp/request',
      body: {'mobile': mobile},
      parser: (raw) => Map<String, dynamic>.from(raw as Map),
    );
    return OtpChallenge.fromJson(data);
  }

  Future<OtpVerifyResult> verifyOtp({
    required String mobileRaw,
    required String challengeId,
    required String otp,
  }) async {
    final mobile = PhoneUtils.normalizeIndian(mobileRaw);
    if (mobile == null) {
      throw Exception('Enter a valid 10-digit Indian mobile number');
    }
    final data = await _client.post<Map<String, dynamic>>(
      '/auth/customer/otp/verify',
      body: {
        'mobile': mobile,
        'challengeId': challengeId,
        'otp': otp.trim(),
      },
      parser: (raw) => Map<String, dynamic>.from(raw as Map),
    );
    return OtpVerifyResult.fromJson(data);
  }

  Future<AppUser> register({
    required String registrationToken,
    required String name,
  }) async {
    final data = await _client.post<Map<String, dynamic>>(
      '/auth/customer/register',
      body: {
        'registrationToken': registrationToken,
        'name': name.trim(),
      },
      parser: (raw) => Map<String, dynamic>.from(raw as Map),
    );
    final user = data['user'];
    if (user is Map) {
      return AppUser.fromJson(Map<String, dynamic>.from(user));
    }
    return AppUser.fromJson(data);
  }

  Future<AppUser?> currentSession() async {
    if (!await _client.hasSession) return null;
    final refreshed = await _client.refreshSession();
    if (!refreshed) return null;
    try {
      final data = await _client.get<Map<String, dynamic>>(
        '/auth/me',
        parser: (raw) => Map<String, dynamic>.from(raw as Map),
      );
      final userId = data['userId']?.toString() ?? data['sub']?.toString();
      if (userId == null || userId.isEmpty) return null;
      if (data['role'] != null && data['role'] != 'CUSTOMER') return null;
      return AppUser(
        id: userId,
        name: (data['name'] as String?) ?? '',
        phone: (data['phone'] as String?) ?? '',
        role: (data['role'] as String?) ?? 'CUSTOMER',
      );
    } catch (_) {
      return null;
    }
  }

  Future<void> logout() async {
    try {
      await _client.post('/auth/logout', parser: (_) => null);
    } catch (_) {
      // Ignore network errors on logout; still clear local cookies.
    }
    await _client.clearSession();
  }
}
