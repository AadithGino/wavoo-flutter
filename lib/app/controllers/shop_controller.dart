import 'dart:async';

import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:uuid/uuid.dart';

import '../core/network/api_exception.dart';
import '../data/local/local_shop_store.dart';
import '../data/models/address.dart';
import '../data/models/category.dart';
import '../data/models/order.dart';
import '../data/models/product.dart';
import '../data/models/user.dart';
import '../data/repositories/catalog_repository.dart';

class ShopController extends GetxController {
  ShopController({
    required CatalogRepository repository,
    required LocalShopStore store,
  })  : _repository = repository,
        _store = store;

  final CatalogRepository _repository;
  final LocalShopStore _store;
  final _snapshots = <String, Product>{};
  bool _bagReady = false;
  final _uuid = const Uuid();

  final products = <Product>[].obs;
  final catalogCategories = <ShopCategory>[].obs;
  final newArrivalProducts = <Product>[].obs;
  final bestSellerProducts = <Product>[].obs;
  final isLoading = true.obs;
  final loadError = RxnString();
  final selectedCategoryId = 'All'.obs;
  final selectedCategory = 'All'.obs;
  final searchQuery = ''.obs;
  final wishlist = <String>{}.obs;
  final cart = <String, int>{}.obs;
  final addresses = <Address>[].obs;
  final selectedAddressId = ''.obs;
  final orders = <JewelleryOrder>[].obs;
  final placingOrder = false.obs;
  final checkingPayment = false.obs;
  final paymentStatus = RxnString();
  final paymentMethod = 'PHONEPE'.obs;
  final addressBusy = false.obs;
  final ordersLoading = false.obs;
  final addressesLoading = false.obs;
  final detailLoading = false.obs;
  final orderDetailLoading = false.obs;

  List<({String id, String name, String image})> get categoryTiles {
    if (catalogCategories.isNotEmpty) {
      return catalogCategories
          .map(
            (item) => (
              id: item.id,
              name: item.name,
              image: item.imageUrl ?? '',
            ),
          )
          .toList();
    }
    final seen = <String>{};
    final tiles = <({String id, String name, String image})>[];
    for (final product in products) {
      final key =
          product.categoryId.isNotEmpty ? product.categoryId : product.category;
      if (key.isEmpty || seen.contains(key)) continue;
      seen.add(key);
      tiles.add((
        id: key,
        name: product.category,
        image: product.categoryImage ?? product.image,
      ));
    }
    return tiles;
  }

  List<({String id, String name, String image})> get categoryFilterChips => [
        (id: 'All', name: 'All', image: ''),
        ...categoryTiles,
      ];

  List<String> get categories =>
      categoryFilterChips.map((item) => item.name).toList();

  String get selectedCategoryName {
    if (selectedCategoryId.value == 'All') return 'All';
    for (final item in categoryTiles) {
      if (item.id == selectedCategoryId.value) return item.name;
    }
    return selectedCategory.value;
  }

  List<Product> get filteredProducts {
    if (selectedCategoryId.value == 'All' || selectedCategory.value == 'All') {
      return products.toList();
    }
    final id = selectedCategoryId.value;
    final name = selectedCategoryName;
    return products.where((product) {
      if (product.categoryId.isNotEmpty && product.categoryId == id) {
        return true;
      }
      return product.category == name || product.category == selectedCategory.value;
    }).toList();
  }

  List<Product> get newArrivals {
    if (newArrivalProducts.isNotEmpty) {
      return newArrivalProducts.take(8).toList();
    }
    final flagged = products.where((item) => item.isNewArrival).take(8).toList();
    if (flagged.isNotEmpty) return flagged;
    return products.take(4).toList();
  }

  List<Product> get bestSellers {
    if (bestSellerProducts.isNotEmpty) {
      return bestSellerProducts.take(8).toList();
    }
    final flagged = products.where((item) => item.isBestSeller).take(8).toList();
    if (flagged.isNotEmpty) return flagged;
    if (products.length <= 4) return products.toList();
    return products.skip(4).take(4).toList();
  }

  List<Product> get searchedProducts {
    final query = searchQuery.value.trim().toLowerCase();
    if (query.isEmpty) return products.take(6).toList();
    return products
        .where(
          (product) =>
              product.name.toLowerCase().contains(query) ||
              product.category.toLowerCase().contains(query) ||
              (product.productCode ?? '').toLowerCase().contains(query),
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

  /// Rupees, matching the f2501df cart / checkout contract.
  int get subtotal => subtotalRupees;

  Address? get defaultAddress {
    if (addresses.isEmpty) return null;
    final selected = selectedAddressId.value;
    if (selected.isNotEmpty) {
      for (final item in addresses) {
        if (item.id == selected) return item;
      }
    }
    return addresses.firstWhere(
      (item) => item.isDefault,
      orElse: () => addresses.first,
    );
  }

  Product? productById(String id) {
    for (final item in products) {
      if (item.id == id) return item;
    }
    return _snapshots[id];
  }

  List<Product> get wishlistItems {
    return wishlist
        .map(productById)
        .whereType<Product>()
        .toList();
  }

  JewelleryOrder? orderById(String id) {
    for (final item in orders) {
      if (item.id == id || item.orderNumber == id) return item;
    }
    return null;
  }

  Future<void> loadCatalog() async {
    isLoading.value = true;
    loadError.value = null;
    try {
      final results = await Future.wait([
        _repository.fetchProducts(),
        _repository.fetchCategories(),
      ]);
      products.assignAll(results[0] as List<Product>);
      final fetchedCategories = List<ShopCategory>.from(
        results[1] as List<ShopCategory>,
      )..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
      catalogCategories.assignAll(fetchedCategories);
      if (catalogCategories.isEmpty) {
        final derived = <ShopCategory>[];
        final seen = <String>{};
        for (final product in products) {
          final id = product.categoryId.isNotEmpty
              ? product.categoryId
              : product.category;
          if (id.isEmpty || seen.contains(id)) continue;
          seen.add(id);
          derived.add(
            ShopCategory(
              id: id,
              name: product.category,
              imageUrl: product.categoryImage ?? product.image,
            ),
          );
        }
        catalogCategories.assignAll(derived);
      }
      _refreshBagSnapshots();
      unawaited(_persistBag());
      await _loadMerchandising();
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

  Future<void> _loadMerchandising() async {
    try {
      final arrivals = await _repository.fetchProducts(newArrival: true);
      newArrivalProducts.assignAll(
        _merchandisingResult(arrivals, (item) => item.isNewArrival),
      );
    } catch (_) {
      newArrivalProducts.assignAll(
        products.where((item) => item.isNewArrival),
      );
    }
    try {
      final sellers = await _repository.fetchProducts(bestSeller: true);
      bestSellerProducts.assignAll(
        _merchandisingResult(sellers, (item) => item.isBestSeller),
      );
    } catch (_) {
      bestSellerProducts.assignAll(
        products.where((item) => item.isBestSeller),
      );
    }
  }

  List<Product> _merchandisingResult(
    List<Product> fetched,
    bool Function(Product) flagged,
  ) {
    final marked = fetched.where(flagged).toList();
    if (marked.isNotEmpty) return marked;
    if (fetched.isNotEmpty) return fetched;
    return products.where(flagged).toList();
  }

  Future<void> loadProducts() => loadCatalog();

  Future<void> loadOrders() async {
    ordersLoading.value = true;
    try {
      final remote = await _repository.fetchOrders();
      orders.assignAll(remote);
    } catch (_) {
    } finally {
      ordersLoading.value = false;
    }
  }

  Future<JewelleryOrder?> loadOrderDetail(String id) async {
    orderDetailLoading.value = true;
    try {
      final detail = await _repository.fetchOrder(id);
      _upsertOrder(detail);
      return detail;
    } on ApiException catch (e) {
      final existing = orderById(id);
      if (existing == null) _notify(e.message);
      return existing;
    } catch (_) {
      return orderById(id);
    } finally {
      orderDetailLoading.value = false;
    }
  }

  Future<void> loadAddresses() async {
    addressesLoading.value = true;
    try {
      final remote = await _repository.fetchAddresses();
      if (remote != null) {
        addresses.assignAll(remote);
        _syncSelectedAddress();
      }
    } catch (_) {
    } finally {
      addressesLoading.value = false;
    }
  }

  void applyProfileAddress(CustomerProfile profile) {
    if (addresses.isNotEmpty) return;
    final saved = profile.savedAddresses;
    addresses.assignAll(saved);
    _syncSelectedAddress();
  }

  void _syncSelectedAddress() {
    if (addresses.isEmpty) {
      selectedAddressId.value = '';
      return;
    }
    final current = selectedAddressId.value;
    final stillThere = addresses.any((item) => item.id == current);
    if (stillThere) return;
    selectedAddressId.value = (defaultAddress ?? addresses.first).id;
  }

  void selectAddress(String id) => selectedAddressId.value = id;

  Future<Product?> loadProductDetail(String id) async {
    detailLoading.value = true;
    try {
      final detail = await _repository.fetchProduct(id);
      final index = products.indexWhere((item) => item.id == id);
      if (index >= 0) {
        products[index] = detail;
      } else {
        products.add(detail);
      }
      return detail;
    } catch (_) {
      return productById(id);
    } finally {
      detailLoading.value = false;
    }
  }

  void chooseCategory(String category) {
    if (category == 'All') {
      selectedCategory.value = 'All';
      selectedCategoryId.value = 'All';
      return;
    }
    for (final item in categoryTiles) {
      if (item.id == category || item.name == category) {
        selectedCategoryId.value = item.id;
        selectedCategory.value = item.name;
        return;
      }
    }
    selectedCategory.value = category;
    selectedCategoryId.value = category;
  }

  void updateSearch(String value) => searchQuery.value = value;

  void clearSearch() => searchQuery.value = '';

  void toggleWishlist(String id) {
    if (wishlist.contains(id)) {
      wishlist.remove(id);
      _notify('Removed from saved jewellery');
    } else {
      wishlist.add(id);
      _rememberProduct(id);
      _notify('Saved to your jewellery list');
    }
    unawaited(_persistBag());
  }

  void addToCart(String id) {
    cart[id] = (cart[id] ?? 0) + 1;
    _rememberProduct(id);
    unawaited(_persistBag());
    _notify('Added to your shopping bag');
  }

  void changeQuantity(String id, int delta) {
    final next = (cart[id] ?? 0) + delta;
    if (next <= 0) {
      cart.remove(id);
    } else {
      cart[id] = next;
      _rememberProduct(id);
    }
    unawaited(_persistBag());
  }

  void removeFromCart(String id) {
    cart.remove(id);
    unawaited(_persistBag());
  }

  Future<void> setDefaultAddress(String id) async {
    selectAddress(id);
    try {
      final updated = await _repository.updateAddress(id, {'isDefault': true});
      addresses.assignAll(
        addresses.map((item) {
          if (item.id == updated.id) return updated.copyWith(isDefault: true);
          return item.copyWith(isDefault: false);
        }),
      );
    } on ApiException catch (e) {
      if (e.statusCode == 404) {
        addresses.assignAll(
          addresses.map((address) => address.copyWith(isDefault: address.id == id)),
        );
      } else {
        _notify(e.message);
        return;
      }
    } catch (_) {
      addresses.assignAll(
        addresses.map((address) => address.copyWith(isDefault: address.id == id)),
      );
    }
    _notify('Default delivery address updated');
  }

  Future<bool> saveAddress(Address draft, {String? existingId}) async {
    addressBusy.value = true;
    try {
      if (existingId != null && existingId.isNotEmpty) {
        await _repository.updateAddress(existingId, draft.toApiJson());
        _notify('Address updated');
      } else {
        await _repository.createAddress(draft);
        _notify('Address saved');
      }
      await loadAddresses();
      return true;
    } on ApiException catch (e) {
      _notify(e.message);
      return false;
    } catch (e) {
      _notify(e.toString());
      return false;
    } finally {
      addressBusy.value = false;
    }
  }

  Future<void> removeAddress(String id) async {
    try {
      await _repository.deleteAddress(id);
    } on ApiException catch (e) {
      if (e.statusCode != 404) {
        _notify(e.message);
        return;
      }
    } catch (e) {
      _notify(e.toString());
      return;
    }
    addresses.removeWhere((item) => item.id == id);
    _syncSelectedAddress();
    _notify('Address removed');
  }

  void placeOrder() {
    unawaited(_placeOrder());
  }

  Future<bool> _placeOrder() async {
    if (cart.isEmpty) return false;
    final address = defaultAddress;
    if (address == null || !address.isComplete) {
      _notify('A complete delivery address is required to place an order');
      return false;
    }

    placingOrder.value = true;
    paymentStatus.value = 'Placing your order…';
    try {
      final lines = cart.entries
          .map((e) => {'productId': e.key, 'quantity': e.value})
          .toList();

      final created = await _repository.createOrder(
        idempotencyKey: _uuid.v4(),
        lines: lines,
        address: address.toCheckoutJson(),
        paymentMethod: paymentMethod.value,
      );
      _upsertOrder(created.order);

      if (created.order.isConfirmed || paymentMethod.value == 'COD') {
        await clearBag();
        paymentStatus.value = 'Order confirmed';
        Get.back<void>();
        _notify('Order ${created.order.orderNumber} placed successfully');
        return true;
      }

      final url = created.redirectUrl;
      if (url != null && url.isNotEmpty) {
        paymentStatus.value = 'Opening PhonePe…';
        final uri = Uri.parse(url);
        if (await canLaunchUrl(uri)) {
          await launchUrl(uri, mode: LaunchMode.externalApplication);
        }
      }

      paymentStatus.value = 'Waiting for payment confirmation…';
      final confirmed = await _pollOrderPayment(created.order.id);
      _upsertOrder(confirmed);

      if (confirmed.isConfirmed) {
        await clearBag();
        paymentStatus.value = 'Payment successful';
        Get.back<void>();
        _notify('Order ${confirmed.orderNumber} paid successfully');
        return true;
      }

      if (confirmed.isFailed) {
        paymentStatus.value = 'Payment failed';
        _notify('Payment failed. You can try again from My Orders.');
        return false;
      }

      await clearBag();
      paymentStatus.value = 'Payment still pending';
      _notify('Payment is still pending. We will update once confirmed.');
      return false;
    } on ApiException catch (e) {
      paymentStatus.value = e.message;
      _notify(e.message);
      return false;
    } catch (e) {
      paymentStatus.value = e.toString();
      _notify(e.toString());
      return false;
    } finally {
      placingOrder.value = false;
    }
  }

  Future<JewelleryOrder> resumeOrderPayment(JewelleryOrder order) async {
    checkingPayment.value = true;
    paymentStatus.value = 'Checking payment…';
    try {
      final latest = await _repository.fetchOrderPaymentStatus(order.id);
      _upsertOrder(latest);
      if (latest.isConfirmed) {
        paymentStatus.value = 'Payment successful';
        _notify('Order ${latest.displayNumber} is confirmed');
      } else if (latest.isFailed) {
        paymentStatus.value = 'Payment failed';
        _notify('Payment failed for ${latest.displayNumber}');
      } else {
        paymentStatus.value = 'Payment still pending';
        _notify('Payment is still pending');
      }
      return latest;
    } on ApiException catch (e) {
      paymentStatus.value = e.message;
      _notify(e.message);
      return orderById(order.id) ?? order;
    } catch (e) {
      paymentStatus.value = e.toString();
      _notify(e.toString());
      return orderById(order.id) ?? order;
    } finally {
      checkingPayment.value = false;
    }
  }

  Future<bool> cancelOrder(JewelleryOrder order, {String? reason}) async {
    try {
      final updated = await _repository.cancelOrder(order.id, reason: reason);
      _upsertOrder(updated);
      _notify('Order ${updated.orderNumber} cancelled');
      return true;
    } on ApiException catch (e) {
      _notify(e.message);
      return false;
    } catch (e) {
      _notify(e.toString());
      return false;
    }
  }

  Future<JewelleryOrder> _pollOrderPayment(String orderId) async {
    const delays = [
      Duration(seconds: 2),
      Duration(seconds: 3),
      Duration(seconds: 4),
      Duration(seconds: 5),
      Duration(seconds: 6),
      Duration(seconds: 8),
    ];
    var latest = await _repository.fetchOrderPaymentStatus(orderId);
    for (final delay in delays) {
      if (!latest.isPendingPayment) return latest;
      await Future<void>.delayed(delay);
      latest = await _repository.fetchOrderPaymentStatus(orderId);
      paymentStatus.value = latest.statusLabel;
    }
    return latest;
  }

  void _upsertOrder(JewelleryOrder order) {
    final index = orders.indexWhere(
      (item) => item.id == order.id || item.orderNumber == order.orderNumber,
    );
    if (index >= 0) {
      orders[index] = order;
    } else {
      orders.insert(0, order);
    }
  }

  Future<void> restoreBag() async {
    await _store.init();
    final bag = _store.read();
    cart.assignAll(bag.cart);
    wishlist.clear();
    wishlist.addAll(bag.wishlist);
    _snapshots
      ..clear()
      ..addAll(bag.snapshots);
    _bagReady = true;
  }

  Future<void> clearBag() async {
    cart.clear();
    wishlist.clear();
    _snapshots.clear();
    _bagReady = true;
    await _store.clear();
  }

  Future<void> reset() async {
    products.clear();
    catalogCategories.clear();
    newArrivalProducts.clear();
    bestSellerProducts.clear();
    addresses.clear();
    orders.clear();
    selectedCategoryId.value = 'All';
    selectedCategory.value = 'All';
    selectedAddressId.value = '';
    searchQuery.value = '';
    placingOrder.value = false;
    checkingPayment.value = false;
    paymentStatus.value = null;
    paymentMethod.value = 'PHONEPE';
    loadError.value = null;
    isLoading.value = true;
    ordersLoading.value = false;
    addressesLoading.value = false;
    detailLoading.value = false;
    orderDetailLoading.value = false;
    await clearBag();
  }

  void _rememberProduct(String id) {
    final product = productById(id);
    if (product != null) _snapshots[id] = product;
  }

  void _refreshBagSnapshots() {
    for (final item in products) {
      if (cart.containsKey(item.id) || wishlist.contains(item.id)) {
        _snapshots[item.id] = item;
      }
    }
  }

  Future<void> _persistBag() async {
    if (!_bagReady) return;
    final liveIds = {...cart.keys, ...wishlist};
    _snapshots.removeWhere((id, _) => !liveIds.contains(id));
    await _store.save(
      cart: Map<String, int>.from(cart),
      wishlist: Set<String>.from(wishlist),
      snapshots: Map<String, Product>.from(_snapshots),
    );
  }

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
