import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:wavoo_app/app/core/utils/money.dart';
import 'package:wavoo_app/app/core/utils/phone.dart';
import 'package:wavoo_app/app/data/models/address.dart';
import 'package:wavoo_app/app/data/models/category.dart';
import 'package:wavoo_app/app/data/models/product.dart';

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

  test('Product.fromApi reads category object and arrival flags', () {
    final product = Product.fromApi({
      'id': 'p1',
      'name': 'Temple Ring',
      'categoryId': 'c1',
      'category': {
        'id': 'c1',
        'name': 'Rings',
        'imageUrl': 'https://cdn.example.com/rings.jpg',
      },
      'images': ['https://cdn.example.com/ring.jpg'],
      'isNewArrival': true,
      'isBestSeller': false,
      'inStock': true,
      'price': {'unitTotalPaise': 2436568, 'gstPaise': 70968},
    });
    expect(product.category, 'Rings');
    expect(product.categoryId, 'c1');
    expect(product.isNewArrival, isTrue);
    expect(product.pricePaise, 2436568);
    expect(product.image, 'https://cdn.example.com/ring.jpg');
  });

  test('Address.fromJson uses stateName and pincode', () {
    final address = Address.fromJson({
      'id': 'a1',
      'label': 'Home',
      'name': 'Ravi Kumar',
      'phone': '+919876543210',
      'line1': '12 MG Road',
      'city': 'Kochi',
      'stateName': 'Kerala',
      'pincode': '682001',
      'isDefault': true,
    });
    expect(address.isComplete, isTrue);
    expect(address.toCheckoutJson()['stateName'], 'Kerala');
    expect(address.toCheckoutJson()['pincode'], '682001');
  });

  test('ShopCategory.fromJson reads imageUrl and sortOrder', () {
    final category = ShopCategory.fromJson({
      'id': 'c1',
      'name': 'Rings',
      'slug': 'rings',
      'imageUrl': 'https://cdn.example.com/categories/rings.jpg',
      'sortOrder': 2,
      'isActive': true,
    });
    expect(category.id, 'c1');
    expect(category.name, 'Rings');
    expect(category.imageUrl, 'https://cdn.example.com/categories/rings.jpg');
    expect(category.sortOrder, 2);
    expect(category.isActive, isTrue);
  });

  test('Product bag snapshot round-trips for Hive cart/wishlist', () {
    const product = Product(
      id: 'p1',
      name: 'Temple Ring',
      pricePaise: 2436568,
      oldPricePaise: 2700000,
      category: 'Rings',
      categoryId: 'c1',
      image: 'https://cdn.example.com/ring.jpg',
      images: ['https://cdn.example.com/ring.jpg'],
      tag: 'New',
    );
    final restored = Product.fromBagJson(product.toBagJson());
    expect(restored.id, 'p1');
    expect(restored.name, 'Temple Ring');
    expect(restored.pricePaise, 2436568);
    expect(restored.category, 'Rings');
    expect(restored.image, 'https://cdn.example.com/ring.jpg');
  });
}
