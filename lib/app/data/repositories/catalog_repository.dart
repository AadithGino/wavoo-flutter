import '../../core/network/api_client.dart';
import '../../core/network/api_exception.dart';
import '../models/address.dart';
import '../models/category.dart';
import '../models/order.dart';
import '../models/product.dart';
import '../models/user.dart';

class CatalogRepository {
  CatalogRepository(this._client);

  final ApiClient _client;
  bool? _legacyProductQuery;

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

  Future<List<ShopCategory>> fetchCategories() async {
    try {
      final data = await _client.get<dynamic>('/customer/ecommerce/categories');
      final items = _parseList(data, ShopCategory.fromJson)
          .where(
            (item) =>
                item.isActive && item.id.isNotEmpty && item.name.isNotEmpty,
          )
          .toList()
        ..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
      return items;
    } on ApiException catch (e) {
      if (e.statusCode == 404) return const [];
      rethrow;
    }
  }

  Future<List<Product>> fetchProducts({
    String? categoryId,
    String? category,
    bool? newArrival,
    bool? bestSeller,
  }) async {
    final useLegacy = _legacyProductQuery == true;
    try {
      return await _fetchProductsOnce(
        categoryId: useLegacy ? null : categoryId,
        category: useLegacy ? category : null,
        newArrival: useLegacy ? null : newArrival,
        bestSeller: useLegacy ? null : bestSeller,
      );
    } on ApiException catch (e) {
      if (!useLegacy && e.statusCode == 422) {
        _legacyProductQuery = true;
        return _fetchProductsOnce(
          category: category ?? categoryId,
          newArrival: null,
          bestSeller: null,
        );
      }
      rethrow;
    }
  }

  Future<List<Product>> _fetchProductsOnce({
    String? categoryId,
    String? category,
    bool? newArrival,
    bool? bestSeller,
  }) async {
    final query = <String, dynamic>{};
    if (categoryId != null && categoryId.isNotEmpty && categoryId != 'All') {
      query['categoryId'] = categoryId;
    }
    if (category != null && category.isNotEmpty && category != 'All') {
      query['category'] = category;
    }
    if (newArrival == true) query['newArrival'] = true;
    if (bestSeller == true) query['bestSeller'] = true;
    final data = await _client.get<dynamic>(
      '/customer/ecommerce/products',
      query: query.isEmpty ? null : query,
    );
    if (_legacyProductQuery == null && query.isNotEmpty) {
      _legacyProductQuery = false;
    }
    return _parseList(data, Product.fromApi)
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
    return _parseList(data, JewelleryOrder.fromJson);
  }

  Future<JewelleryOrder> fetchOrder(String orderId) async {
    final data = await _client.get<Map<String, dynamic>>(
      '/customer/ecommerce/orders/$orderId',
      parser: (raw) => Map<String, dynamic>.from(raw as Map),
    );
    return JewelleryOrder.fromJson(data);
  }

  Future<CheckoutResult> createOrder({
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
    final orderRaw = data['order'];
    final order = JewelleryOrder.fromJson(
      orderRaw is Map
          ? Map<String, dynamic>.from(orderRaw)
          : data,
    );
    return CheckoutResult(
      order: order,
      redirectUrl: data['redirectUrl'] as String?,
    );
  }

  Future<JewelleryOrder> fetchOrderPaymentStatus(String orderId) async {
    final data = await _client.get<Map<String, dynamic>>(
      '/customer/ecommerce/orders/$orderId/payment-status',
      parser: (raw) => Map<String, dynamic>.from(raw as Map),
    );
    return JewelleryOrder.fromJson(data);
  }

  Future<JewelleryOrder> cancelOrder(String orderId, {String? reason}) async {
    final data = await _client.post<Map<String, dynamic>>(
      '/customer/ecommerce/orders/$orderId/cancel',
      body: {if (reason != null && reason.trim().isNotEmpty) 'reason': reason.trim()},
      parser: (raw) => Map<String, dynamic>.from(raw as Map),
    );
    return JewelleryOrder.fromJson(data);
  }

  Future<List<Address>?> fetchAddresses() async {
    for (final path in const [
      '/customer/addresses',
      '/customer/ecommerce/addresses',
    ]) {
      try {
        final data = await _client.get<dynamic>(path);
        return _parseList(data, Address.fromJson)
            .where((item) => item.line1.isNotEmpty || item.city.isNotEmpty)
            .toList();
      } on ApiException catch (e) {
        if (!_isMissingRoute(e)) rethrow;
      }
    }
    try {
      final data = await _client.get<dynamic>('/customer/profile');
      if (data is Map) {
        return CustomerProfile.fromJson(Map<String, dynamic>.from(data))
            .savedAddresses;
      }
    } on ApiException catch (e) {
      if (!_isMissingRoute(e)) rethrow;
    }
    return null;
  }

  Future<Address> createAddress(Address address) async {
    final body = address.toApiJson();
    ApiException? missing;
    for (final path in const [
      '/customer/addresses',
      '/customer/ecommerce/addresses',
    ]) {
      try {
        final data = await _client.post<dynamic>(path, body: body);
        return _parseAddressPayload(data, address);
      } on ApiException catch (e) {
        if (!_isMissingRoute(e)) rethrow;
        missing = e;
      }
    }
    try {
      return await _saveLegacyProfileAddress(address);
    } on ApiException catch (e) {
      if (!_isMissingRoute(e) && e.statusCode != 405) rethrow;
      throw missing ?? e;
    }
  }

  Future<Address> updateAddress(String addressId, Map<String, dynamic> body) async {
    ApiException? missing;
    for (final path in [
      '/customer/addresses/$addressId',
      '/customer/ecommerce/addresses/$addressId',
    ]) {
      try {
        final data = await _client.patch<dynamic>(path, body: body);
        return _parseAddressPayload(data, Address.fromJson(body));
      } on ApiException catch (e) {
        if (!_isMissingRoute(e)) rethrow;
        missing = e;
      }
    }
    final draft = Address.fromJson({
      'id': addressId,
      ...body,
    });
    try {
      return await _saveLegacyProfileAddress(draft);
    } on ApiException catch (e) {
      if (!_isMissingRoute(e) && e.statusCode != 405) rethrow;
      throw missing ?? e;
    }
  }

  Future<void> deleteAddress(String addressId) async {
    ApiException? missing;
    for (final path in [
      '/customer/addresses/$addressId',
      '/customer/ecommerce/addresses/$addressId',
    ]) {
      try {
        await _client.delete(path, parser: (_) => null);
        return;
      } on ApiException catch (e) {
        if (!_isMissingRoute(e)) rethrow;
        missing = e;
      }
    }
    if (missing != null) throw missing;
  }

  Future<Address> _saveLegacyProfileAddress(Address address) async {
    final snapshot = {
      'line1': address.line1.trim(),
      if (address.line2 != null && address.line2!.trim().isNotEmpty)
        'line2': address.line2!.trim(),
      'city': address.city.trim(),
      'state': address.stateName.trim(),
      'postalCode': address.pincode.trim(),
    };
    final body = {'address': snapshot};
    try {
      final data = await _client.patch<dynamic>('/customer/profile', body: body);
      return _addressFromProfile(data, address);
    } on ApiException catch (e) {
      if (!_isMissingRoute(e) && e.statusCode != 405) rethrow;
    }
    final data = await _client.put<dynamic>('/customer/profile', body: body);
    return _addressFromProfile(data, address);
  }

  Address _addressFromProfile(dynamic data, Address fallback) {
    if (data is Map) {
      final saved = CustomerProfile.fromJson(Map<String, dynamic>.from(data))
          .savedAddresses;
      if (saved.isNotEmpty) return saved.first;
      final parsed = _parseAddressPayload(data, fallback);
      if (parsed.line1.isNotEmpty) return parsed;
    }
    return fallback.copyWith(id: fallback.id.isEmpty ? 'profile' : fallback.id);
  }

  Address _parseAddressPayload(dynamic data, Address fallback) {
    if (data is Map) {
      final map = Map<String, dynamic>.from(data);
      final nested = map['address'];
      if (nested is Map) {
        return Address.fromJson(Map<String, dynamic>.from(nested));
      }
      if (map['id'] != null || map['line1'] != null || map['pincode'] != null) {
        return Address.fromJson(map);
      }
    }
    return fallback;
  }

  bool _isMissingRoute(ApiException e) {
    if (e.statusCode == 404) return true;
    if (e.code == 'ROUTE_NOT_FOUND') return true;
    final message = e.message.toLowerCase();
    return message.contains('not found') && message.contains('route');
  }
}
