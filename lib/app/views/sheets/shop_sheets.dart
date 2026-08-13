import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controllers/shop_controller.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/money.dart';
import '../../data/models/product.dart';
import '../widgets/product_image.dart';
import 'sheet_scaffold.dart';

Future<void> showSearchSheet() async {
  final shop = Get.find<ShopController>()..clearSearch();
  await openAppSheet(
    Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        sheetHeader('Search Jewellery'),
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
                    borderRadius: BorderRadius.circular(8),
                    child: SizedBox(
                      width: 48,
                      height: 48,
                      child: ProductImage(url: product.image),
                    ),
                  ),
                  title: Text(product.name),
                  subtitle: Text(Money.fromPaise(product.pricePaise)),
                  onTap: () {
                    Get.back<void>();
                    showProductSheet(product);
                  },
                );
              },
            ),
          ),
        ),
      ],
    ),
  );
  shop.clearSearch();
}

Future<void> showProductSheet(Product product) async {
  final shop = Get.find<ShopController>();
  unawaited(shop.loadProductDetail(product.id));
  await openAppSheet(
    Column(
      children: [
        sheetHeader(product.name),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: AspectRatio(
                  aspectRatio: 1.1,
                  child: Obx(() {
                    final latest = shop.productById(product.id) ?? product;
                    return ProductImage(url: latest.image);
                  }),
                ),
              ),
              const SizedBox(height: 16),
              Obx(() {
                final latest = shop.productById(product.id) ?? product;
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      Money.fromPaise(latest.pricePaise),
                      style: const TextStyle(
                        color: AppColors.goldDark,
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      latest.description.isEmpty
                          ? 'Fine jewellery from Wavoo Jewellers.'
                          : latest.description,
                      style: const TextStyle(color: AppColors.muted, height: 1.45),
                    ),
                  ],
                );
              }),
              const SizedBox(height: 20),
              Obx(() {
                final latest = shop.productById(product.id) ?? product;
                return Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => shop.toggleWishlist(product.id),
                        child: const Text('SAVE'),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: FilledButton(
                        onPressed: latest.inStock
                            ? () {
                                shop.addToCart(product.id);
                                Get.back<void>();
                              }
                            : null,
                        child: Text(latest.inStock ? 'ADD TO BAG' : 'SOLD OUT'),
                      ),
                    ),
                  ],
                );
              }),
            ],
          ),
        ),
      ],
    ),
  );
}

Future<void> showCartSheet() async {
  final shop = Get.find<ShopController>();
  await openAppSheet(
    Obx(() {
      final entries = shop.cart.entries.toList();
      return Column(
        children: [
          sheetHeader('Shopping Bag'),
          Expanded(
            child: entries.isEmpty
                ? const Center(child: Text('Your bag is empty'))
                : ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: entries.length,
                    separatorBuilder: (_, __) => const Divider(),
                    itemBuilder: (_, index) {
                      final entry = entries[index];
                      final product = shop.productById(entry.key);
                      if (product == null) {
                        return ListTile(
                          title: Text('Unavailable item'),
                          trailing: IconButton(
                            onPressed: () => shop.removeFromCart(entry.key),
                            icon: const Icon(Icons.delete_outline),
                          ),
                        );
                      }
                      return ListTile(
                        contentPadding: EdgeInsets.zero,
                        title: Text(product.name),
                        subtitle: Text(Money.fromPaise(product.pricePaise)),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              onPressed: () =>
                                  shop.changeQuantity(product.id, -1),
                              icon: const Icon(Icons.remove_circle_outline),
                            ),
                            Text('${entry.value}'),
                            IconButton(
                              onPressed: () =>
                                  shop.changeQuantity(product.id, 1),
                              icon: const Icon(Icons.add_circle_outline),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),
          if (entries.isNotEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Subtotal'),
                      Text(
                        Money.fromPaise(shop.subtotalPaise),
                        style: const TextStyle(fontWeight: FontWeight.w700),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: FilledButton(
                      onPressed: showCheckoutSheet,
                      child: const Text('CHECKOUT'),
                    ),
                  ),
                ],
              ),
            ),
        ],
      );
    }),
  );
}

Future<void> showWishlistSheet() async {
  final shop = Get.find<ShopController>();
  await openAppSheet(
    Obx(() {
      final items = shop.products
          .where((p) => shop.wishlist.contains(p.id))
          .toList();
      return Column(
        children: [
          sheetHeader('Saved Jewellery'),
          Expanded(
            child: items.isEmpty
                ? const Center(child: Text('No saved pieces yet'))
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: items.length,
                    itemBuilder: (_, index) {
                      final product = items[index];
                      return ListTile(
                        title: Text(product.name),
                        subtitle: Text(Money.fromPaise(product.pricePaise)),
                        onTap: () {
                          Get.back<void>();
                          showProductSheet(product);
                        },
                        trailing: IconButton(
                          onPressed: () => shop.toggleWishlist(product.id),
                          icon: const Icon(Icons.favorite, color: AppColors.gold),
                        ),
                      );
                    },
                  ),
          ),
        ],
      );
    }),
  );
}

Future<void> showCheckoutSheet() async {
  final shop = Get.find<ShopController>();
  final address = shop.defaultAddress;
  await openAppSheet(
    Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        sheetHeader('Checkout'),
        Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                address == null
                    ? 'No delivery address on your profile yet.'
                    : !address.isComplete
                        ? '${address.lines}\n\nThis address is incomplete for checkout.'
                        : '${address.label}\n${address.lines}',
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Total'),
                  Obx(
                    () => Text(
                      Money.fromPaise(shop.subtotalPaise),
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 18,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: Obx(
                  () => FilledButton(
                    onPressed: shop.placingOrder.value ||
                            address == null ||
                            !address.isComplete
                        ? null
                        : shop.placeOrder,
                    child: shop.placingOrder.value
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Text('PLACE ORDER'),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

Future<void> showOrdersSheet() async {
  final shop = Get.find<ShopController>();
  await shop.loadOrders();
  await openAppSheet(
    Obx(() {
      final orders = shop.orders;
      return Column(
        children: [
          sheetHeader('My Orders'),
          Expanded(
            child: orders.isEmpty
                ? const Center(child: Text('No orders yet'))
                : ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: orders.length,
                    separatorBuilder: (_, __) => const Divider(),
                    itemBuilder: (_, index) {
                      final order = orders[index];
                      return ListTile(
                        contentPadding: EdgeInsets.zero,
                        title: Text(order.id),
                        subtitle: Text(
                          '${order.itemCount} items · ${order.status}',
                        ),
                        trailing: Text(Money.fromPaise(order.totalPaise)),
                      );
                    },
                  ),
          ),
        ],
      );
    }),
  );
}

Future<void> showAddressesSheet() async {
  final shop = Get.find<ShopController>();
  await openAppSheet(
    Obx(
      () => Column(
        children: [
          sheetHeader('Saved Addresses'),
          Expanded(
            child: shop.addresses.isEmpty
                ? const Center(child: Text('No addresses saved'))
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: shop.addresses.length,
                    itemBuilder: (_, index) {
                      final address = shop.addresses[index];
                      return ListTile(
                        title: Text(address.label),
                        subtitle: Text(address.lines),
                        trailing: address.isDefault
                            ? const Text('Default')
                            : TextButton(
                                onPressed: () =>
                                    shop.setDefaultAddress(address.id),
                                child: const Text('Set default'),
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
