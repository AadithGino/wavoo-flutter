import 'package:get/get.dart';
import 'package:uuid/uuid.dart';

import '../core/network/api_exception.dart';
import '../core/utils/money.dart';
import '../core/utils/phone.dart';
import '../data/models/address.dart';
import '../data/models/order.dart';
import '../data/models/product.dart';
import '../data/models/user.dart';
import '../data/repositories/catalog_repository.dart';

class ShopController extends GetxController {
  ShopController({required CatalogRepository repository}) : _repository = repository;

  final CatalogRepository _repository;
  final _uuid = const Uuid();

  final products = <Product>[].obs;
  final isLoading = false.obs;
  final loadError = RxnString();
  final selectedCategory = 'All'.obs;
  final searchQuery = ''.obs;
  final wishlist = <String>{}.obs;
  final cart = <String, int>{}.obs;
  final addresses = <Address>[].obs;
  final orders = <JewelleryOrder>[].obs;
  final placingOrder = false.obs;

  List<String> get categories {
    final names = <String>{};
    for (final product in products) {
      if (product.category.isNotEmpty) names.add(product.category);
    }
    return ['All', ...names];
  }

  List<({String name, String image})> get categoryTiles {
    final seen = <String>{};
    final tiles = <({String name, String image})>[];
    for (final product in products) {
      if (product.category.isEmpty || seen.contains(product.category)) continue;
      seen.add(product.category);
      tiles.add((name: product.category, image: product.image));
    }
    return tiles;
  }

  /// Catalog grid uses category only (search does not silently filter it).
  List<Product> get filteredProducts {
    return products.where((product) {
      return selectedCategory.value == 'All' ||
          product.category == selectedCategory.value;
    }).toList();
  }

  List<Product> get searchedProducts {
    final query = searchQuery.value.trim().toLowerCase();
    if (query.isEmpty) return products.take(6).toList();
    return products
        .where(
          (product) =>
              product.name.toLowerCase().contains(query) ||
              product.category.toLowerCase().contains(query),
        )
        .toList();
  }

  int get cartCount => cart.values.fold(0, (sum, quantity) => sum + quantity);

  int get subtotalPaise => cart.entries.fold(0, (sum, entry) {
        final product = productById(entry.key);
        if (product == null) return sum;
        return sum + product.pricePaise * entry.value;
      });

  int get subtotalRupees => subtotalPaise ~/ 100;

  Address? get defaultAddress {
    if (addresses.isEmpty) return null;
    return addresses.firstWhere(
      (item) => item.isDefault,
      orElse: () => addresses.first,
    );
  }

  Product? productById(String id) {
    for (final item in products) {
      if (item.id == id) return item;
    }
    return null;
  }

  Future<void> loadProducts() async {
    isLoading.value = true;
    loadError.value = null;
    try {
      final remote = await _repository.fetchProducts();
      products.assignAll(remote);
    } on ApiException catch (e) {
      loadError.value = e.message;
      products.clear();
    } catch (e) {
      loadError.value = e.toString();
      products.clear();
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loadOrders() async {
    try {
      final remote = await _repository.fetchOrders();
      orders.assignAll(remote);
    } catch (_) {}
  }

  void applyProfileAddress(CustomerProfile profile) {
    final address = Address.fromProfile(profile);
    if (address.line1.isEmpty && address.city.isEmpty && address.pincode.isEmpty) {
      addresses.clear();
      return;
    }
    addresses.assignAll([address]);
  }

  Future<Product?> loadProductDetail(String id) async {
    try {
      final detail = await _repository.fetchProduct(id);
      final index = products.indexWhere((item) => item.id == id);
      if (index >= 0) products[index] = detail;
      return detail;
    } catch (_) {
      return productById(id);
    }
  }

  void chooseCategory(String category) => selectedCategory.value = category;

  void updateSearch(String value) => searchQuery.value = value;

  void clearSearch() => searchQuery.value = '';

  void toggleWishlist(String id) {
    if (wishlist.contains(id)) {
      wishlist.remove(id);
      _notify('Removed from saved jewellery');
    } else {
      wishlist.add(id);
      _notify('Saved to your jewellery list');
    }
  }

  void addToCart(String id) {
    cart[id] = (cart[id] ?? 0) + 1;
    _notify('Added to your shopping bag');
  }

  void changeQuantity(String id, int delta) {
    final next = (cart[id] ?? 0) + delta;
    if (next <= 0) {
      cart.remove(id);
    } else {
      cart[id] = next;
    }
  }

  void removeFromCart(String id) => cart.remove(id);

  void setDefaultAddress(String id) {
    addresses.assignAll(
      addresses.map((address) => address.copyWith(isDefault: address.id == id)),
    );
    _notify('Default delivery address updated');
  }

  Future<bool> placeOrder() async {
    if (cart.isEmpty) return false;
    final address = defaultAddress;
    if (address == null || !address.isComplete) {
      _notify('A complete delivery address is required to place an order');
      return false;
    }

    placingOrder.value = true;
    try {
      final lines = cart.entries
          .map((e) => {'productId': e.key, 'quantity': e.value})
          .toList();

      final payload = address.toCheckoutJson();
      final phone = PhoneUtils.normalizeIndian(address.phone);
      if (phone != null) payload['phone'] = phone;
      final created = await _repository.createOrder(
        idempotencyKey: _uuid.v4(),
        lines: lines,
        address: payload,
      );
      orders.insert(0, created);
      cart.clear();
      Get.back<void>();
      _notify('Order placed successfully');
      return true;
    } on ApiException catch (e) {
      _notify(e.message);
      return false;
    } catch (e) {
      _notify(e.toString());
      return false;
    } finally {
      placingOrder.value = false;
    }
  }

  String moneyFromPaise(int paise) => Money.fromPaise(paise);

  void _notify(String message) {
    Get.showSnackbar(
      GetSnackBar(
        message: message,
        duration: const Duration(seconds: 2),
        borderRadius: 12,
      ),
    );
  }
}
