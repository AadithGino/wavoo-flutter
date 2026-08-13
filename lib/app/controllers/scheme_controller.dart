import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';

import '../core/network/api_exception.dart';
import '../core/utils/money.dart';
import '../data/models/scheme.dart';
import '../data/repositories/scheme_repository.dart';

class SchemeController extends GetxController {
  SchemeController({required SchemeRepository repository}) : _repository = repository;

  final SchemeRepository _repository;

  final isLoading = false.obs;
  final loadError = RxnString();
  final catalogue = <SchemeCatalogueItem>[].obs;
  final enrollments = <SchemeEnrollment>[].obs;
  final selectedCatalogueItem = Rxn<SchemeCatalogueItem>();
  final paymentBusy = false.obs;
  final paymentStatus = RxnString();
  final lastIntent = Rxn<PaymentIntent>();
  final isRedeemed = false.obs;
  final redemptionMethod = ''.obs;
  final redemptionReference = ''.obs;

  SchemeEnrollment? get activeEnrollment {
    for (final item in enrollments) {
      if (item.isActive) return item;
    }
    return enrollments.isEmpty ? null : enrollments.first;
  }

  bool get hasJoined => enrollments.isNotEmpty;

  String money(int rupees) => Money.formatRupees(rupees);
  String moneyPaise(int paise) => Money.fromPaise(paise);

  String dateLabel(DateTime? date) {
    if (date == null) return '—';
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  Future<void> load() async {
    isLoading.value = true;
    loadError.value = null;
    try {
      final results = await Future.wait([
        _repository.fetchCatalogue(),
        _repository.fetchEnrollments(),
      ]);
      catalogue.assignAll(results[0] as List<SchemeCatalogueItem>);
      enrollments.assignAll(results[1] as List<SchemeEnrollment>);
      if (selectedCatalogueItem.value == null && catalogue.isNotEmpty) {
        selectedCatalogueItem.value = catalogue.first;
      }
    } on ApiException catch (e) {
      loadError.value = e.message;
    } catch (e) {
      loadError.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  void selectCatalogueItem(SchemeCatalogueItem item) {
    selectedCatalogueItem.value = item;
  }

  Future<bool> joinSelectedScheme() async {
    final item = selectedCatalogueItem.value;
    if (item == null) {
      _notify('Select a scheme to continue');
      return false;
    }
    if (item.amountPaise <= 0 || item.totalInstallments <= 0) {
      _notify('This scheme has invalid installment rules');
      return false;
    }
    paymentBusy.value = true;
    try {
      final enrollment = await _repository.enroll(
        templateId: item.templateId,
        versionId: item.versionId,
      );
      await load();
      Get.back<void>();
      _notify('${enrollment.planName} activated');
      return true;
    } on ApiException catch (e) {
      _notify(e.message);
      return false;
    } catch (e) {
      _notify(e.toString());
      return false;
    } finally {
      paymentBusy.value = false;
    }
  }

  Future<PaymentPreview?> loadPaymentPreview() async {
    final enrollment = activeEnrollment;
    if (enrollment == null) return null;
    return _repository.paymentPreview(enrollment.enrollmentId);
  }

  /// Starts PhonePe web checkout and polls until terminal status.
  /// Never reports success until backend status is SUCCESS.
  Future<PaymentIntent?> payInstallment() async {
    final enrollment = activeEnrollment;
    if (enrollment == null) {
      _notify('No active scheme to pay');
      return null;
    }

    paymentBusy.value = true;
    paymentStatus.value = 'Preparing payment…';
    lastIntent.value = null;

    try {
      final preview = await _repository.paymentPreview(enrollment.enrollmentId);
      if (!preview.paymentAllowed) {
        _notify(preview.validationMessage ?? 'Payment is not allowed right now');
        paymentStatus.value = preview.validationMessage;
        return null;
      }
      if (preview.amountPaise <= 0) {
        _notify('Invalid payment amount from server');
        paymentStatus.value = 'Invalid amount';
        return null;
      }

      paymentStatus.value = 'Opening PhonePe…';
      final intent = await _repository.initiatePhonePeWeb(enrollment.enrollmentId);
      lastIntent.value = intent;

      if (intent.isSuccess) {
        paymentStatus.value = 'Payment successful';
        await load();
        _notify('Monthly instalment paid successfully');
        return intent;
      }

      final url = intent.checkoutUrl;
      if (url != null && url.isNotEmpty) {
        final uri = Uri.parse(url);
        if (await canLaunchUrl(uri)) {
          await launchUrl(uri, mode: LaunchMode.externalApplication);
        }
      }

      paymentStatus.value = 'Waiting for payment confirmation…';
      final confirmed = await _pollIntent(intent.merchantOrderId);
      lastIntent.value = confirmed;

      if (confirmed.isSuccess) {
        paymentStatus.value = 'Payment successful';
        await load();
        _notify('Monthly instalment paid successfully');
        return confirmed;
      }

      if (confirmed.isFailed) {
        paymentStatus.value = 'Payment ${confirmed.status.toLowerCase()}';
        _notify('Payment ${confirmed.status.toLowerCase()}. Please try again.');
        return confirmed;
      }

      paymentStatus.value = 'Payment still pending';
      _notify('Payment is still pending. We will update once confirmed.');
      return confirmed;
    } on ApiException catch (e) {
      paymentStatus.value = e.message;
      _notify(e.message);
      return null;
    } catch (e) {
      paymentStatus.value = e.toString();
      _notify(e.toString());
      return null;
    } finally {
      paymentBusy.value = false;
    }
  }

  Future<PaymentIntent> _pollIntent(String merchantOrderId) async {
    const delays = [
      Duration(seconds: 2),
      Duration(seconds: 3),
      Duration(seconds: 4),
      Duration(seconds: 5),
      Duration(seconds: 6),
      Duration(seconds: 8),
    ];
    var latest = await _repository.paymentIntentStatus(merchantOrderId);
    for (final delay in delays) {
      if (latest.isSuccess || latest.isFailed) return latest;
      await Future<void>.delayed(delay);
      latest = await _repository.paymentIntentStatus(merchantOrderId);
      lastIntent.value = latest;
      paymentStatus.value = 'Status: ${latest.status}';
    }
    return latest;
  }

  void redeem([String method = 'Showroom redemption']) {
    redemptionMethod.value = method;
    redemptionReference.value =
        'WAV-RD-${DateTime.now().millisecondsSinceEpoch.toString().substring(8)}';
    isRedeemed.value = true;
    _notify('Redemption request confirmed');
  }

  void _notify(String message) {
    Get.showSnackbar(
      GetSnackBar(
        message: message,
        duration: const Duration(seconds: 2),
        margin: const EdgeInsets.all(16),
        borderRadius: 12,
      ),
    );
  }
}
