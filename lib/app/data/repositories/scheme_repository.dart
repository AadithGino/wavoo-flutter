import 'package:uuid/uuid.dart';

import '../../core/network/api_client.dart';
import '../models/scheme.dart';

class SchemeRepository {
  SchemeRepository(this._client);

  final ApiClient _client;
  final _uuid = const Uuid();

  Future<List<SchemeCatalogueItem>> fetchCatalogue() async {
    final data = await _client.get<dynamic>('/customer/scheme-catalogue');
    final list = _asList(data);
    final items = list
        .whereType<Map>()
        .map((item) => SchemeCatalogueItem.fromJson(Map<String, dynamic>.from(item)))
        .where((item) => item.templateId.isNotEmpty)
        .toList()
      ..sort((a, b) {
        if (a.isFeatured != b.isFeatured) return a.isFeatured ? -1 : 1;
        return a.displayOrder.compareTo(b.displayOrder);
      });
    return items;
  }

  Future<List<SchemeEnrollment>> fetchEnrollments({
    String? lifecycle,
    String? status,
    int page = 1,
    int limit = 20,
    bool allPages = false,
  }) async {
    final first = await _fetchEnrollmentPage(
      lifecycle: lifecycle,
      status: status,
      page: page,
      limit: limit,
    );
    final items = [...first.items];
    if (!allPages || first.totalPages <= 1) return items;
    for (var next = page + 1; next <= first.totalPages; next++) {
      final extra = await _fetchEnrollmentPage(
        lifecycle: lifecycle,
        status: status,
        page: next,
        limit: limit,
      );
      items.addAll(extra.items);
    }
    return items;
  }

  Future<List<SchemeEnrollment>> fetchCustomerSchemes() async {
    final chunks = await Future.wait([
      _fetchLifecycle('all'),
      _fetchLifecycle('past'),
      _fetchLifecycle('redeemable'),
    ]);
    return _mergeEnrollments([
      ...chunks[0],
      ...chunks[1],
      ...chunks[2],
    ]);
  }

  Future<List<SchemeEnrollment>> _fetchLifecycle(String lifecycle) async {
    try {
      return await fetchEnrollments(lifecycle: lifecycle, allPages: true);
    } catch (_) {
      if (lifecycle == 'all') {
        try {
          return await fetchEnrollments(allPages: true);
        } catch (_) {
          return const [];
        }
      }
      return const [];
    }
  }

  Future<_EnrollmentPage> _fetchEnrollmentPage({
    String? lifecycle,
    String? status,
    required int page,
    required int limit,
  }) async {
    final data = await _client.get<dynamic>(
      '/customer/scheme-enrollments',
      query: {
        if (lifecycle != null && lifecycle.isNotEmpty) 'lifecycle': lifecycle,
        if (status != null && status.isNotEmpty) 'status': status,
        'page': page,
        'limit': limit,
      },
    );
    final list = _asList(data);
    final enrollments = <SchemeEnrollment>[];
    for (final item in list.whereType<Map>()) {
      final enrollment =
          SchemeEnrollment.fromJson(Map<String, dynamic>.from(item));
      if (enrollment.enrollmentId.isNotEmpty) {
        enrollments.add(enrollment);
      }
    }
    var totalPages = 1;
    if (data is Map) {
      totalPages = (data['totalPages'] as num?)?.toInt() ?? 1;
      final total = (data['total'] as num?)?.toInt();
      if (total != null && total > enrollments.length && totalPages <= 1) {
        totalPages = (total / limit).ceil();
      }
    }
    return _EnrollmentPage(items: enrollments, totalPages: totalPages);
  }

  List<SchemeEnrollment> _mergeEnrollments(List<SchemeEnrollment> items) {
    final byId = <String, SchemeEnrollment>{};
    for (final item in items) {
      if (item.enrollmentId.isEmpty) continue;
      final existing = byId[item.enrollmentId];
      if (existing == null || item.isPast) {
        byId[item.enrollmentId] = item;
      }
    }
    return byId.values.toList();
  }

  Future<List<SchemeInstallment>> fetchInstallments(String enrollmentId) async {
    final data = await _client.get<dynamic>(
      '/customer/scheme-enrollments/$enrollmentId/installments',
    );
    final list = data is List
        ? data
        : (data is Map && data['items'] is List)
            ? data['items'] as List
            : const [];
    return list
        .whereType<Map>()
        .map((item) => SchemeInstallment.fromJson(Map<String, dynamic>.from(item)))
        .toList();
  }

  Future<SchemeEnrollment> enroll({
    required String templateId,
    required String versionId,
    String? idempotencyKey,
  }) async {
    final data = await _client.post<Map<String, dynamic>>(
      '/customer/scheme-enrollments',
      body: {
        'templateId': templateId,
        'versionId': versionId,
        'idempotencyKey': idempotencyKey ?? _uuid.v4(),
      },
      parser: (raw) => Map<String, dynamic>.from(raw as Map),
    );
    return SchemeEnrollment.fromJson(data);
  }

  Future<PaymentPreview> paymentPreview(String enrollmentId) async {
    final data = await _client.get<Map<String, dynamic>>(
      '/customer/scheme-enrollments/$enrollmentId/payment-preview',
      parser: (raw) => Map<String, dynamic>.from(raw as Map),
    );
    return PaymentPreview.fromJson(data);
  }

  Future<PaymentIntent> initiatePhonePeWeb(
    String enrollmentId, {
    String? idempotencyKey,
  }) async {
    final data = await _client.post<Map<String, dynamic>>(
      '/customer/scheme-enrollments/$enrollmentId/payments/phonepe',
      body: {'idempotencyKey': idempotencyKey ?? _uuid.v4()},
      parser: (raw) => Map<String, dynamic>.from(raw as Map),
    );
    return PaymentIntent.fromJson(data);
  }

  Future<PaymentIntent> paymentIntentStatus(String merchantOrderId) async {
    final data = await _client.get<Map<String, dynamic>>(
      '/customer/scheme-payment-intents/$merchantOrderId',
      parser: (raw) => Map<String, dynamic>.from(raw as Map),
    );
    return PaymentIntent.fromJson(data);
  }

  Future<Map<String, dynamic>?> fetchPassbook(String enrollmentId) async {
    final data = await _client.get<dynamic>(
      '/customer/scheme-enrollments/$enrollmentId/passbook',
    );
    if (data is Map) return Map<String, dynamic>.from(data);
    return null;
  }

  Future<RedemptionEligibility> redemptionEligibility(String enrollmentId) async {
    final data = await _client.get<Map<String, dynamic>>(
      '/customer/scheme-enrollments/$enrollmentId/redemption-eligibility',
      parser: (raw) => Map<String, dynamic>.from(raw as Map),
    );
    return RedemptionEligibility.fromJson(data);
  }

  Future<SchemeRedemption> requestRedemption({
    required String enrollmentId,
    String mode = 'FULL',
    int? amountPaise,
    String? idempotencyKey,
  }) async {
    final data = await _client.post<Map<String, dynamic>>(
      '/customer/scheme-redemptions',
      body: {
        'enrollmentId': enrollmentId,
        'mode': mode,
        if (mode == 'PARTIAL' && amountPaise != null) 'amountPaise': amountPaise,
        'idempotencyKey': idempotencyKey ?? _uuid.v4(),
      },
      parser: (raw) => Map<String, dynamic>.from(raw as Map),
    );
    return SchemeRedemption.fromJson(data);
  }

  Future<List<SchemeRedemption>> fetchRedemptions({String? enrollmentId}) async {
    final data = await _client.get<dynamic>(
      '/customer/scheme-redemptions',
      query: {
        if (enrollmentId != null && enrollmentId.isNotEmpty)
          'enrollmentId': enrollmentId,
        'page': 1,
        'limit': 50,
      },
    );
    return _asList(data)
        .whereType<Map>()
        .map((item) => SchemeRedemption.fromJson(Map<String, dynamic>.from(item)))
        .toList();
  }

  List<dynamic> _asList(dynamic data) {
    if (data is List) return data;
    if (data is Map) {
      for (final key in const [
        'items',
        'catalogue',
        'enrollments',
        'schemes',
        'templates',
        'published',
        'redemptions',
        'results',
      ]) {
        final nested = data[key];
        if (nested is List) return nested;
      }
      if (data['templateId'] != null ||
          data['id'] != null ||
          data['content'] is Map) {
        return [data];
      }
    }
    return const [];
  }
}

class _EnrollmentPage {
  const _EnrollmentPage({required this.items, required this.totalPages});

  final List<SchemeEnrollment> items;
  final int totalPages;
}
