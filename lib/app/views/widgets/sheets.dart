import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../controllers/scheme_controller.dart';
import '../../controllers/shop_controller.dart';
import '../../core/constants/app_colors.dart';
import '../../data/models/product.dart';
import 'primary_button.dart';

abstract final class AppSheets {
  static Future<T?> _open<T>(Widget child, {bool scrollControlled = true}) {
    return Get.bottomSheet<T>(
      SafeArea(
        top: false,
        child: Container(
          constraints: BoxConstraints(maxHeight: Get.height * 0.9),
          decoration: const BoxDecoration(
            color: AppColors.ivory,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: child,
        ),
      ),
      isScrollControlled: scrollControlled,
      backgroundColor: Colors.transparent,
    );
  }

  static Widget _header(String title) => Column(
    mainAxisSize: MainAxisSize.min,
    children: [
      const SizedBox(height: 9),
      Container(
        width: 42,
        height: 4,
        decoration: BoxDecoration(
          color: AppColors.line,
          borderRadius: BorderRadius.circular(4),
        ),
      ),
      Padding(
        padding: const EdgeInsets.fromLTRB(18, 8, 8, 8),
        child: Row(
          children: [
            Expanded(
              child: Text(
                title,
                style: GoogleFonts.notoSerif(
                  fontSize: 21,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            IconButton(onPressed: Get.back, icon: const Icon(Icons.close)),
          ],
        ),
      ),
      const Divider(height: 1),
    ],
  );

  static void showSearch() {
    final shop = Get.find<ShopController>()..clearSearch();
    _open(
      Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _header('Search Jewellery'),
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              autofocus: true,
              onChanged: shop.updateSearch,
              decoration: const InputDecoration(
                prefixIcon: Icon(Icons.search),
                hintText: 'Search necklaces, rings, earrings…',
              ),
            ),
          ),
          Flexible(
            child: Obx(
              () => ListView.separated(
                shrinkWrap: true,
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
                itemCount: shop.searchedProducts.length,
                separatorBuilder: (_, __) => const Divider(),
                itemBuilder: (_, index) {
                  final product = shop.searchedProducts[index];
                  return ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: ClipRRect(
                      borderRadius: BorderRadius.circular(9),
                      child: Image.asset(
                        product.image,
                        width: 56,
                        height: 56,
                        fit: BoxFit.cover,
                      ),
                    ),
                    title: Text(product.name),
                    subtitle: Text(product.category),
                    trailing: Text('₹${product.price}'),
                    onTap: () {
                      Get.back<void>();
                      showProduct(product);
                    },
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  static void showProduct(Product product) {
    final shop = Get.find<ShopController>();
    _open(
      Column(
        children: [
          _header('Jewellery Details'),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(18),
                    child: AspectRatio(
                      aspectRatio: 1.16,
                      child: Image.asset(product.image, fit: BoxFit.cover),
                    ),
                  ),
                  const SizedBox(height: 18),
                  Text(
                    product.category.toUpperCase(),
                    style: GoogleFonts.notoSerif(
                      color: AppColors.gold,
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(product.name, style: Get.textTheme.headlineSmall),
                  const SizedBox(height: 8),
                  Text(
                    '₹${product.price}',
                    style: GoogleFonts.notoSerif(
                      color: AppColors.goldDark,
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    product.description,
                    style: GoogleFonts.notoSerif(
                      color: AppColors.muted,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 18),
                  const Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      Chip(label: Text('BIS Hallmarked')),
                      Chip(label: Text('Insured Delivery')),
                      Chip(label: Text('Easy Exchange')),
                    ],
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
            child: Row(
              children: [
                Obx(
                  () => IconButton.outlined(
                    onPressed: () => shop.toggleWishlist(product.id),
                    icon: Icon(
                      shop.wishlist.contains(product.id)
                          ? Icons.favorite
                          : Icons.favorite_border,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: PrimaryButton(
                    label: 'ADD TO BAG',
                    icon: Icons.shopping_bag_outlined,
                    onPressed: () {
                      shop.addToCart(product.id);
                      Get.back<void>();
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static void showCart() {
    final shop = Get.find<ShopController>();
    _open(
      Obx(
        () => Column(
          children: [
            _header('Your Shopping Bag'),
            if (shop.cart.isEmpty)
              const Expanded(
                child: Center(child: Text('Your shopping bag is empty.')),
              )
            else
              Expanded(
                child: ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: shop.cart.length,
                  separatorBuilder: (_, __) => const Divider(height: 24),
                  itemBuilder: (_, index) {
                    final entry = shop.cart.entries.elementAt(index);
                    final product = shop.productById(entry.key);
                    return Row(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Image.asset(
                            product.image,
                            width: 76,
                            height: 76,
                            fit: BoxFit.cover,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                product.name,
                                style: GoogleFonts.notoSerif(
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              Text('₹${product.price}'),
                              Row(
                                children: [
                                  IconButton(
                                    onPressed: () =>
                                        shop.changeQuantity(product.id, -1),
                                    icon: const Icon(
                                      Icons.remove_circle_outline,
                                    ),
                                  ),
                                  Text(
                                    '${entry.value}',
                                    style: GoogleFonts.notoSerif(
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                  IconButton(
                                    onPressed: () =>
                                        shop.changeQuantity(product.id, 1),
                                    icon: const Icon(Icons.add_circle_outline),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          onPressed: () => shop.removeFromCart(product.id),
                          icon: const Icon(Icons.delete_outline),
                        ),
                      ],
                    );
                  },
                ),
              ),
            if (shop.cart.isNotEmpty)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Subtotal',
                          style: GoogleFonts.notoSerif(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Text(
                          '₹${shop.subtotal}',
                          style: GoogleFonts.notoSerif(
                            fontSize: 19,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    PrimaryButton(
                      label: 'PROCEED TO CHECKOUT',
                      onPressed: () {
                        Get.back<void>();
                        showCheckout();
                      },
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  static void showWishlist() {
    final shop = Get.find<ShopController>();
    _open(
      Obx(() {
        final items = shop.products
            .where((p) => shop.wishlist.contains(p.id))
            .toList();
        return Column(
          children: [
            _header('Saved Jewellery'),
            Expanded(
              child: items.isEmpty
                  ? const Center(
                      child: Text('Your saved jewellery will appear here.'),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: items.length,
                      itemBuilder: (_, index) {
                        final product = items[index];
                        return ListTile(
                          leading: Image.asset(
                            product.image,
                            width: 58,
                            fit: BoxFit.cover,
                          ),
                          title: Text(product.name),
                          subtitle: Text('₹${product.price}'),
                          trailing: IconButton(
                            onPressed: () => shop.toggleWishlist(product.id),
                            icon: const Icon(Icons.favorite),
                          ),
                          onTap: () {
                            Get.back<void>();
                            showProduct(product);
                          },
                        );
                      },
                    ),
            ),
          ],
        );
      }),
    );
  }

  static void showCheckout() {
    final shop = Get.find<ShopController>();
    _open(
      Column(
        children: [
          _header('Checkout'),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Text(
                  'DELIVER TO',
                  style: GoogleFonts.notoSerif(
                    color: AppColors.goldDark,
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1,
                  ),
                ),
                const SizedBox(height: 8),
                ...shop.addresses.map(
                  (address) => Obx(
                    () => RadioListTile<String>(
                      value: address.id,
                      groupValue: shop.addresses
                          .firstWhere((item) => item.isDefault)
                          .id,
                      onChanged: (value) {
                        if (value != null) shop.setDefaultAddress(value);
                      },
                      title: Text(address.label),
                      subtitle: Text(address.lines),
                    ),
                  ),
                ),
                const Divider(height: 30),
                const ListTile(
                  leading: Icon(Icons.credit_card),
                  title: Text('Secure online payment'),
                  subtitle: Text('UPI, cards and net banking'),
                ),
                const ListTile(
                  leading: Icon(Icons.local_shipping_outlined),
                  title: Text('Insured delivery'),
                  subtitle: Text('Complimentary for this order'),
                ),
                const Divider(height: 30),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Order total'),
                    Text(
                      '₹${shop.subtotal}',
                      style: GoogleFonts.notoSerif(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: PrimaryButton(
              label: 'PLACE ORDER',
              onPressed: shop.placeOrder,
            ),
          ),
        ],
      ),
    );
  }

  static void showOrders() {
    final shop = Get.find<ShopController>();
    _open(
      Obx(
        () => Column(
          children: [
            _header('My Orders'),
            Expanded(
              child: shop.orders.isEmpty
                  ? const Center(
                      child: Text(
                        'No orders yet. Your purchases will appear here.',
                      ),
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.all(16),
                      itemCount: shop.orders.length,
                      separatorBuilder: (_, __) => const Divider(),
                      itemBuilder: (_, index) {
                        final order = shop.orders[index];
                        return ListTile(
                          leading: const CircleAvatar(
                            child: Icon(Icons.shopping_bag_outlined),
                          ),
                          title: Text('Order ${order.id}'),
                          subtitle: Text(
                            '${order.itemCount} items • ${order.status}',
                          ),
                          trailing: Text('₹${order.total}'),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  static void showAddresses() {
    final shop = Get.find<ShopController>();
    _open(
      Obx(
        () => Column(
          children: [
            _header('Saved Addresses'),
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: shop.addresses.length,
                separatorBuilder: (_, __) => const SizedBox(height: 10),
                itemBuilder: (_, index) {
                  final address = shop.addresses[index];
                  return Card(
                    child: ListTile(
                      leading: Icon(
                        address.label == 'Home'
                            ? Icons.home_outlined
                            : Icons.work_outline,
                      ),
                      title: Text(address.label),
                      subtitle: Text(address.lines),
                      trailing: address.isDefault
                          ? const Chip(label: Text('Default'))
                          : TextButton(
                              onPressed: () =>
                                  shop.setDefaultAddress(address.id),
                              child: const Text('Set default'),
                            ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  static void showSchemePayment() {
    final scheme = Get.find<SchemeController>();
    _open(
      Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _header('Pay Monthly Instalment'),
          Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              children: [
                const Icon(
                  Icons.verified_user_outlined,
                  size: 44,
                  color: AppColors.gold,
                ),
                const SizedBox(height: 12),
                Text(
                  '₹${scheme.monthlyAmount.value}',
                  style: GoogleFonts.notoSerif(
                    fontSize: 30,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                Text(
                  'Secure payment for your Wavoo Gold Scheme',
                  style: GoogleFonts.notoSerif(color: AppColors.muted),
                ),
                const SizedBox(height: 20),
                PrimaryButton(
                  label: 'PAY SECURELY',
                  onPressed: scheme.payInstallment,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static void showRedemption() {
    final scheme = Get.find<SchemeController>();
    _open(
      Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _header('Redeem Maturity'),
          Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              children: [
                const Text(
                  'Choose how you would like to redeem your matured savings.',
                ),
                const SizedBox(height: 14),
                const ListTile(
                  leading: Icon(Icons.diamond_outlined),
                  title: Text('Shop jewellery in store'),
                  subtitle: Text('Book a private redemption appointment'),
                ),
                const ListTile(
                  leading: Icon(Icons.account_balance_wallet_outlined),
                  title: Text('Wavoo purchase credit'),
                  subtitle: Text('Apply your value to a future purchase'),
                ),
                const SizedBox(height: 12),
                PrimaryButton(
                  label: 'SUBMIT REQUEST',
                  onPressed: scheme.redeem,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
