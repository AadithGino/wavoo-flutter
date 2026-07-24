import 'package:flutter/material.dart';
import 'package:get/get.dart';

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
  final monthlyAmount = 5000.obs;
  final paidInstallments = 4.obs;
  final totalInstallments = 11;
  final hasJoined = true.obs;
  final isRedeemed = false.obs;
  final redemptionMethod = ''.obs;
  final redemptionReference = ''.obs;
  final selectedPlanMonths = 11.obs;

  final planName = 'Wavoo Gold Savings Plan';
  final startDate = DateTime(2026, 4, 13);
  final maturityDate = DateTime(2027, 3, 13);

  final payments = <SchemePayment>[
    SchemePayment(
      installment: 4,
      date: DateTime(2026, 7, 13),
      amount: 5000,
      receipt: 'WAV-1044',
    ),
    SchemePayment(
      installment: 3,
      date: DateTime(2026, 6, 13),
      amount: 5000,
      receipt: 'WAV-0931',
    ),
    SchemePayment(
      installment: 2,
      date: DateTime(2026, 5, 13),
      amount: 5000,
      receipt: 'WAV-0816',
    ),
    SchemePayment(
      installment: 1,
      date: DateTime(2026, 4, 13),
      amount: 5000,
      receipt: 'WAV-0702',
    ),
  ].obs;

  int get savedAmount => monthlyAmount.value * paidInstallments.value;
  int get goalAmount => monthlyAmount.value * totalInstallments;
  int get remainingInstallments =>
      (totalInstallments - paidInstallments.value)
          .clamp(0, totalInstallments)
          .toInt();
  double get progress =>
      (paidInstallments.value / totalInstallments).clamp(0, 1).toDouble();
  int get progressPercent => (progress * 100).round();
  bool get matured => paidInstallments.value >= totalInstallments;

  DateTime get nextDueDate =>
      DateTime(2026, 8 + (paidInstallments.value - 4), 13);

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

  String money(int amount) {
    final digits = amount.toString();
    if (digits.length <= 3) return '₹$digits';
    final lastThree = digits.substring(digits.length - 3);
    var prefix = digits.substring(0, digits.length - 3);
    final groups = <String>[];
    while (prefix.length > 2) {
      groups.insert(0, prefix.substring(prefix.length - 2));
      prefix = prefix.substring(0, prefix.length - 2);
    }
    if (prefix.isNotEmpty) groups.insert(0, prefix);
    return '₹${groups.join(',')},$lastThree';
  }

  String dateLabel(DateTime date) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  void choosePlan(int months) => selectedPlanMonths.value = months;

  void chooseAmount(int amount) => monthlyAmount.value = amount;

  void joinScheme() {
    hasJoined.value = true;
    paidInstallments.value = 1;
    Get.back<void>();
    _notify('Gold savings plan activated');
  }

  void payInstallment() {
    if (!matured) {
      final installment = paidInstallments.value + 1;
      payments.insert(
        0,
        SchemePayment(
          installment: installment,
          date: DateTime.now(),
          amount: monthlyAmount.value,
          receipt: 'WAV-${DateTime.now().millisecondsSinceEpoch.toString().substring(9)}',
        ),
      );
      paidInstallments.value = installment;
    }
    Get.back<void>();
    _notify('Monthly instalment paid successfully');
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
