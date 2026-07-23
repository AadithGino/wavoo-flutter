import 'package:get/get.dart';

import '../data/models/address.dart';
import '../data/models/order.dart';
import '../data/models/product.dart';
import '../data/repositories/catalog_repository.dart';

class ShopController extends GetxController {
  ShopController({CatalogRepository? repository})
    : _repository = repository ?? CatalogRepository();

  final CatalogRepository _repository;
  late final List<Product> products;
  final selectedCategory = 'All'.obs;
  final searchQuery = ''.obs;
  final wishlist = <int>{}.obs;
  final cart = <int, int>{1: 1, 2: 1}.obs;
  final addresses = <Address>[
    const Address(
      user: "Aadith Gino · +91 9876543210",
      id: 'home',
      label: 'Home',
      lines: '42, Lattice Bridge Road, Adyar \nChennai, Tamil Nadu — 600020',
      isDefault: true,
    ),
    const Address(
      user: "Aadith Gino · +91 9876543210",
      id: 'work',
      label: 'Work',
      lines: 'Wavoo Towers, 3rd Floor, T. Nagar\nChennai, Tamil Nadu — 600017',
    ),
  ].obs;
  final orders = <JewelleryOrder>[].obs;

  @override
  void onInit() {
    products = _repository.fetchProducts();
    super.onInit();
  }

  List<String> get categories => const [
    'All',
    'Necklaces',
    'Earrings',
    'Rings',
    'Bangles',
    'Pendants',
  ];

  List<Product> get filteredProducts {
    final query = searchQuery.value.trim().toLowerCase();
    return products.where((product) {
      final categoryMatches =
          selectedCategory.value == 'All' ||
          product.category == selectedCategory.value;
      final queryMatches =
          query.isEmpty ||
          product.name.toLowerCase().contains(query) ||
          product.category.toLowerCase().contains(query);
      return categoryMatches && queryMatches;
    }).toList();
  }

  List<Product> get searchedProducts {
    final query = searchQuery.value.trim().toLowerCase();
    if (query.isEmpty) return products.take(4).toList();
    return products
        .where(
          (product) =>
              product.name.toLowerCase().contains(query) ||
              product.category.toLowerCase().contains(query),
        )
        .toList();
  }

  int get cartCount => cart.values.fold(0, (sum, quantity) => sum + quantity);

  int get subtotal => cart.entries.fold(0, (sum, entry) {
    final product = productById(entry.key);
    return sum + product.price * entry.value;
  });

  Product productById(int id) => products.firstWhere((item) => item.id == id);

  void chooseCategory(String category) => selectedCategory.value = category;

  void updateSearch(String value) => searchQuery.value = value;

  void clearSearch() => searchQuery.value = '';

  void toggleWishlist(int id) {
    if (wishlist.contains(id)) {
      wishlist.remove(id);
      _notify('Removed from saved jewellery');
    } else {
      wishlist.add(id);
      _notify('Saved to your jewellery list');
    }
  }

  void addToCart(int id) {
    cart[id] = (cart[id] ?? 0) + 1;
    _notify('Added to your shopping bag');
  }

  void changeQuantity(int id, int delta) {
    final next = (cart[id] ?? 0) + delta;
    if (next <= 0) {
      cart.remove(id);
    } else {
      cart[id] = next;
    }
  }

  void removeFromCart(int id) => cart.remove(id);

  void setDefaultAddress(String id) {
    addresses.assignAll(
      addresses.map((address) => address.copyWith(isDefault: address.id == id)),
    );
    _notify('Default delivery address updated');
  }

  void placeOrder() {
    if (cart.isEmpty) return;
    orders.insert(
      0,
      JewelleryOrder(
        id: 'WV${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}',
        total: subtotal,
        itemCount: cartCount,
        status: 'Confirmed',
      ),
    );
    cart.clear();
    Get.back<void>();
    _notify('Order placed successfully');
  }

  void _notify(String message) {
    Get.showSnackbar(
      GetSnackBar(
        message: message,
        duration: const Duration(seconds: 2),
        // margin: const EdgeInsets.all(16),
        borderRadius: 12,
      ),
    );
  }
}
