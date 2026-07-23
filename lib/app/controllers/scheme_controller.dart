import 'package:get/get.dart';

class SchemeController extends GetxController {
  final monthlyAmount = 5000.obs;
  final paidInstallments = 7.obs;
  final totalInstallments = 11;
  final hasJoined = true.obs;

  int get savedAmount => monthlyAmount.value * paidInstallments.value;
  double get progress => paidInstallments.value / totalInstallments;
  bool get matured => paidInstallments.value >= totalInstallments;

  void choosePlan(int amount) => monthlyAmount.value = amount;

  void joinScheme() {
    hasJoined.value = true;
    paidInstallments.value = 1;
    Get.back<void>();
    _notify('Welcome to the Wavoo Gold Scheme');
  }

  void payInstallment() {
    if (!matured) paidInstallments.value += 1;
    Get.back<void>();
    _notify('Monthly instalment paid successfully');
  }

  void redeem() {
    Get.back<void>();
    _notify('Redemption request submitted');
  }

  void _notify(String message) {
    Get.showSnackbar(
      GetSnackBar(
        message: message,
        duration: const Duration(seconds: 2),
        // margin: ,
        borderRadius: 12,
      ),
    );
  }
}
