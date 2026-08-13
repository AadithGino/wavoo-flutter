import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:wavoo_app/app/core/utils/money.dart';
import 'package:wavoo_app/app/core/utils/phone.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  tearDown(Get.reset);

  test('Money.fromPaise formats Indian rupees', () {
    expect(Money.fromPaise(500000), '₹5,000');
    expect(Money.fromPaise(null), '—');
    expect(Money.fromPaise(-1), '—');
  });

  test('PhoneUtils normalizes Indian mobiles', () {
    expect(PhoneUtils.normalizeIndian('9876543210'), '+919876543210');
    expect(PhoneUtils.normalizeIndian('+91 98765 43210'), '+919876543210');
    expect(PhoneUtils.normalizeIndian('12345'), isNull);
  });
}
