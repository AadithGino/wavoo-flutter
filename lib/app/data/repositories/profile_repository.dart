import '../../core/network/api_client.dart';
import '../models/user.dart';

class ProfileRepository {
  ProfileRepository(this._client);

  final ApiClient _client;

  Future<CustomerProfile> fetchProfile() async {
    final data = await _client.get<Map<String, dynamic>>(
      '/customer/profile',
      parser: (raw) => Map<String, dynamic>.from(raw as Map),
    );
    return CustomerProfile.fromJson(data);
  }

  Future<Map<String, dynamic>?> fetchHome() async {
    final data = await _client.get<dynamic>('/customer/home');
    if (data is Map) return Map<String, dynamic>.from(data);
    return null;
  }

  Future<Map<String, dynamic>?> fetchLatestGoldRate() async {
    final data = await _client.get<dynamic>('/customer/gold-rates');
    if (data is List && data.isNotEmpty && data.first is Map) {
      return Map<String, dynamic>.from(data.first as Map);
    }
    if (data is Map) {
      final items = data['items'];
      if (items is List && items.isNotEmpty && items.first is Map) {
        return Map<String, dynamic>.from(items.first as Map);
      }
      return Map<String, dynamic>.from(data);
    }
    return null;
  }
}
