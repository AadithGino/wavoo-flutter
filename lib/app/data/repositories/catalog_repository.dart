import '../../core/network/api_client.dart';
import '../models/product.dart';
import '../models/order.dart';

class CatalogRepository {
  CatalogRepository(this._client);

  final ApiClient _client;

  Future<List<Product>> fetchProducts({String? category}) async {
    final query = <String, dynamic>{};
    if (category != null && category != 'All') {
      query['category'] = category;
    }
    final data = await _client.get<dynamic>(
      '/customer/ecommerce/products',
      query: query.isEmpty ? null : query,
    );
    final list = data is List
        ? data
        : (data is Map && data['items'] is List)
            ? data['items'] as List
            : const [];
    return list
        .whereType<Map>()
        .map((item) => Product.fromApi(Map<String, dynamic>.from(item)))
        .where((p) => p.id.isNotEmpty)
        .toList();
  }

  Future<Product> fetchProduct(String id, {int quantity = 1}) async {
    final data = await _client.get<Map<String, dynamic>>(
      '/customer/ecommerce/products/$id',
      query: {'quantity': quantity},
      parser: (raw) => Map<String, dynamic>.from(raw as Map),
    );
    return Product.fromApi(data);
  }

  Future<List<JewelleryOrder>> fetchOrders() async {
    final data = await _client.get<dynamic>('/customer/ecommerce/orders');
    final list = data is List
        ? data
        : (data is Map && data['items'] is List)
            ? data['items'] as List
            : const [];
    return list
        .whereType<Map>()
        .map((item) => JewelleryOrder.fromJson(Map<String, dynamic>.from(item)))
        .toList();
  }

  Future<JewelleryOrder> createOrder({
    required String idempotencyKey,
    required List<Map<String, dynamic>> lines,
    required Map<String, dynamic> address,
    String paymentMethod = 'PHONEPE',
  }) async {
    final data = await _client.post<Map<String, dynamic>>(
      '/customer/ecommerce/orders',
      body: {
        'idempotencyKey': idempotencyKey,
        'lines': lines,
        'address': address,
        'paymentMethod': paymentMethod,
      },
      parser: (raw) => Map<String, dynamic>.from(raw as Map),
    );
    final order = data['order'];
    if (order is Map) {
      return JewelleryOrder.fromJson(Map<String, dynamic>.from(order));
    }
    return JewelleryOrder.fromJson(data);
  }
}
