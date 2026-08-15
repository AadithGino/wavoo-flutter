import '../../core/network/api_client.dart';
import '../models/activity.dart';

class ActivityRepository {
  ActivityRepository(this._client);

  final ApiClient _client;

  Future<List<CustomerTransaction>> fetchTransactions({
    String type = 'all',
    int page = 1,
    int limit = 50,
  }) async {
    final data = await _client.get<dynamic>(
      '/customer/transactions',
      query: {
        'type': type,
        'page': page,
        'limit': limit,
      },
    );
    return _parseList(data, CustomerTransaction.fromJson);
  }

  Future<List<CustomerActivity>> fetchActivity({
    String source = 'ALL',
    int page = 1,
    int limit = 20,
  }) async {
    final data = await _client.get<dynamic>(
      '/customer/activity',
      query: {
        'source': source,
        'page': page,
        'limit': limit,
      },
    );
    return _parseList(data, CustomerActivity.fromJson);
  }

  List<T> _parseList<T>(
    dynamic data,
    T Function(Map<String, dynamic> json) parser,
  ) {
    final list = data is List
        ? data
        : (data is Map && data['items'] is List)
            ? data['items'] as List
            : const [];
    return list
        .whereType<Map>()
        .map((item) => parser(Map<String, dynamic>.from(item)))
        .toList();
  }
}
