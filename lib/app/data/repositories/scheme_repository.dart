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

  Future<List<SchemeEnrollment>> fetchEnrollments() async {
    final data = await _client.get<dynamic>('/customer/scheme-enrollments');
    final list = _asList(data);
    final enrollments = <SchemeEnrollment>[];
    for (final item in list.whereType<Map>()) {
      var enrollment =
          SchemeEnrollment.fromJson(Map<String, dynamic>.from(item));
      if (enrollment.installments.isEmpty && enrollment.enrollmentId.isNotEmpty) {
        try {
          final cycles = await fetchInstallments(enrollment.enrollmentId);
          enrollment = SchemeEnrollment(
            enrollmentId: enrollment.enrollmentId,
            enrollmentNumber: enrollment.enrollmentNumber,
            passbookNumber: enrollment.passbookNumber,
            status: enrollment.status,
            joinedAt: enrollment.joinedAt,
            planName: enrollment.planName,
            amountPaise: enrollment.amountPaise,
            totalInstallments: enrollment.totalInstallments > 0
                ? enrollment.totalInstallments
                : cycles.length,
            paidInstallments: cycles.where((c) => c.isPaid).length,
            templateId: enrollment.templateId,
            versionId: enrollment.versionId,
            slug: enrollment.slug,
            nextDueDate: cycles
                .where((c) => !c.isPaid)
                .map((c) => c.dueDate)
                .whereType<DateTime>()
                .cast<DateTime?>()
                .followedBy([null])
                .first,
            maturityDate: enrollment.maturityDate,
            installments: cycles,
          );
        } catch (_) {}
      }
      enrollments.add(enrollment);
    }
    return enrollments;
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

  Future<List<SchemeRedemption>> fetchRedemptions(String enrollmentId) async {
    final data = await _client.get<dynamic>(
      '/customer/scheme-redemptions',
      query: {'enrollmentId': enrollmentId},
    );
    final list = data is List
        ? data
        : (data is Map && data['items'] is List)
            ? data['items'] as List
            : const [];
    return list
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
