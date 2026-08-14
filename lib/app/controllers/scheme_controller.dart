import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';

import '../core/network/api_exception.dart';
import '../core/utils/money.dart';
import '../data/models/scheme.dart';
import '../data/repositories/scheme_repository.dart';

class SchemePayment {
  const SchemePayment({
    required this.installment,
    required this.date,
    required this.amount,
    this.receipt,
    this.isNext = false,
  });

  final int installment;
  final DateTime date;
  final int amount;
  final String? receipt;
  final bool isNext;
}

class SchemeController extends GetxController {
  SchemeController({required SchemeRepository repository}) : _repository = repository;

  final SchemeRepository _repository;

  final isLoading = true.obs;
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
  final redemptionBusy = false.obs;
  final eligibility = Rxn<RedemptionEligibility>();
  final lastRedemption = Rxn<SchemeRedemption>();

  /// f2501df sheet / screen contract — kept in sync from API enrollments.
  final monthlyAmount = 5000.obs;
  final paidInstallments = 0.obs;
  final hasJoined = false.obs;
  final selectedPlanMonths = 11.obs;
  final payments = <SchemePayment>[].obs;

  SchemeEnrollment? get activeEnrollment {
    for (final item in enrollments) {
      if (item.isActive) return item;
    }
    return enrollments.isEmpty ? null : enrollments.first;
  }

  String get planName =>
      activeEnrollment?.planName ??
      selectedCatalogueItem.value?.name ??
      'Wavoo Gold Savings Plan';

  int get totalInstallments {
    final enrolled = activeEnrollment?.totalInstallments ?? 0;
    if (enrolled > 0) return enrolled;
    return selectedPlanMonths.value;
  }

  DateTime get startDate =>
      activeEnrollment?.joinedAt ?? DateTime.now();

  DateTime get maturityDate =>
      activeEnrollment?.maturityDate ??
      DateTime(startDate.year, startDate.month + totalInstallments, startDate.day);

  DateTime get nextDueDate =>
      activeEnrollment?.nextDueDate ??
      DateTime(startDate.year, startDate.month + paidInstallments.value + 1, startDate.day);

  int get savedAmount => monthlyAmount.value * paidInstallments.value;
  int get goalAmount => monthlyAmount.value * totalInstallments;
  int get remainingInstallments =>
      (totalInstallments - paidInstallments.value).clamp(0, totalInstallments).toInt();
  double get progress => totalInstallments <= 0
      ? 0
      : (paidInstallments.value / totalInstallments).clamp(0, 1).toDouble();
  int get progressPercent => (progress * 100).round();
  bool get matured =>
      paidInstallments.value >= totalInstallments ||
      (activeEnrollment?.isMatured ?? false);

  List<SchemePayment> get upcomingPayments => List.generate(
        remainingInstallments,
        (index) => SchemePayment(
          installment: paidInstallments.value + index + 1,
          date: DateTime(
            nextDueDate.year,
            nextDueDate.month + index,
            nextDueDate.day,
          ),
          amount: monthlyAmount.value,
          isNext: index == 0,
        ),
      );

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

  void choosePlan(int months) {
    selectedPlanMonths.value = months;
    _matchCatalogueSelection();
  }

  void chooseAmount(int amount) {
    monthlyAmount.value = amount;
    _matchCatalogueSelection();
  }

  void joinScheme() {
    unawaited(_joinScheme());
  }

  void redeem([String method = 'Showroom redemption']) {
    redemptionMethod.value = method;
    unawaited(requestRedemption());
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
      final enrollment = activeEnrollment;
      if (enrollment != null) {
        await _refreshRedemption(enrollment.enrollmentId);
      }
      _syncUiFromApi();
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

  Future<void> _joinScheme() async {
    _matchCatalogueSelection();
    await joinSelectedScheme();
  }

  void _matchCatalogueSelection() {
    for (final item in catalogue) {
      if (item.totalInstallments == selectedPlanMonths.value &&
          item.amountRupees == monthlyAmount.value) {
        selectedCatalogueItem.value = item;
        return;
      }
    }
    for (final item in catalogue) {
      if (item.totalInstallments == selectedPlanMonths.value) {
        selectedCatalogueItem.value = item;
        return;
      }
    }
    if (selectedCatalogueItem.value == null && catalogue.isNotEmpty) {
      selectedCatalogueItem.value = catalogue.first;
    }
  }

  void _syncUiFromApi() {
    hasJoined.value = enrollments.isNotEmpty;
    final enrollment = activeEnrollment;
    if (enrollment == null) {
      paidInstallments.value = 0;
      payments.clear();
      final item = selectedCatalogueItem.value;
      if (item != null && item.amountPaise > 0) {
        monthlyAmount.value = item.amountRupees;
        if (item.totalInstallments > 0) {
          selectedPlanMonths.value = item.totalInstallments;
        }
      }
      return;
    }
    monthlyAmount.value = enrollment.amountPaise > 0
        ? enrollment.amountPaise ~/ 100
        : monthlyAmount.value;
    paidInstallments.value = enrollment.paidInstallments;
    if (enrollment.totalInstallments > 0) {
      selectedPlanMonths.value = enrollment.totalInstallments;
    }
    isRedeemed.value = enrollment.isRedeemed || isRedeemed.value;
    final paid = enrollment.installments.where((item) => item.isPaid).toList()
      ..sort((a, b) => b.sequenceNumber.compareTo(a.sequenceNumber));
    payments.assignAll(
      paid.map(
        (item) => SchemePayment(
          installment: item.sequenceNumber,
          date: item.paidAt ?? item.dueDate ?? DateTime.now(),
          amount: item.amountPaise > 0
              ? item.amountPaise ~/ 100
              : monthlyAmount.value,
          receipt: item.receiptNumber,
        ),
      ),
    );
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
  /// Signature matches the f2501df sheet (`void` tear-off is not required;
  /// the sheet invokes this inside a closure).
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

      if (Get.isBottomSheetOpen == true) {
        Get.back<void>();
      }

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

  Future<void> _refreshRedemption(String enrollmentId) async {
    try {
      eligibility.value = await _repository.redemptionEligibility(enrollmentId);
      final rows = await _repository.fetchRedemptions(enrollmentId);
      lastRedemption.value = rows.isEmpty ? null : rows.first;
      final open = lastRedemption.value;
      isRedeemed.value = open != null &&
          (open.status.toUpperCase() == 'COMPLETED' ||
              enrollmentById(enrollmentId)?.isRedeemed == true);
      if (open != null) {
        redemptionReference.value = open.redemptionNumber;
        redemptionMethod.value = open.mode;
      }
    } catch (_) {}
  }

  SchemeEnrollment? enrollmentById(String id) {
    for (final item in enrollments) {
      if (item.enrollmentId == id) return item;
    }
    return null;
  }

  Future<RedemptionEligibility?> loadRedemptionEligibility() async {
    final enrollment = activeEnrollment;
    if (enrollment == null) return null;
    try {
      eligibility.value =
          await _repository.redemptionEligibility(enrollment.enrollmentId);
      return eligibility.value;
    } on ApiException catch (e) {
      _notify(e.message);
      return null;
    }
  }

  Future<SchemeRedemption?> requestRedemption({String mode = 'FULL'}) async {
    final enrollment = activeEnrollment;
    if (enrollment == null) {
      _notify('No scheme to redeem');
      return null;
    }
    redemptionBusy.value = true;
    try {
      final created = await _repository.requestRedemption(
        enrollmentId: enrollment.enrollmentId,
        mode: mode,
      );
      lastRedemption.value = created;
      redemptionMethod.value = created.mode;
      redemptionReference.value = created.redemptionNumber;
      isRedeemed.value = created.status.toUpperCase() == 'COMPLETED';
      await load();
      _notify('Redemption ${created.redemptionNumber} submitted');
      return created;
    } on ApiException catch (e) {
      _notify(e.message);
      return null;
    } catch (e) {
      _notify(e.toString());
      return null;
    } finally {
      redemptionBusy.value = false;
    }
  }

  void reset() {
    catalogue.clear();
    enrollments.clear();
    selectedCatalogueItem.value = null;
    paymentBusy.value = false;
    paymentStatus.value = null;
    lastIntent.value = null;
    isRedeemed.value = false;
    redemptionMethod.value = '';
    redemptionReference.value = '';
    redemptionBusy.value = false;
    eligibility.value = null;
    lastRedemption.value = null;
    loadError.value = null;
    isLoading.value = true;
    monthlyAmount.value = 5000;
    paidInstallments.value = 0;
    hasJoined.value = false;
    selectedPlanMonths.value = 11;
    payments.clear();
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
