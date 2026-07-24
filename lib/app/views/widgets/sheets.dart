import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';

import '../../controllers/scheme_controller.dart';
import '../../controllers/shop_controller.dart';
import '../../core/constants/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../data/models/product.dart';
import 'primary_button.dart';

abstract final class AppSheets {
  static Future<T?> _open<T>(Widget child, {bool scrollControlled = true}) {
    return Get.bottomSheet<T>(
      SafeArea(
        top: false,
        child: Container(
          constraints: BoxConstraints(maxHeight: Get.height * 0.88),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
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
        padding: const EdgeInsets.fromLTRB(17, 8, 9, 8),
        child: Row(
          children: [
            Expanded(
              child: Text(
                title,
                style: AppTypography.serif(size: 22),
              ),
            ),
            IconButton(
              onPressed: Get.back,
              icon: SvgPicture.asset(
                'assets/svg/close.svg',
                width: 20,
                height: 20,
              ),
            ),
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
                    style: TextStyle(
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
                    style: TextStyle(
                      color: AppColors.goldDark,
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    product.description,
                    style: TextStyle(color: AppColors.muted, height: 1.5),
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
                                style: TextStyle(fontWeight: FontWeight.w700),
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
                                    style: TextStyle(
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
                          style: TextStyle(fontWeight: FontWeight.w700),
                        ),
                        Text(
                          '₹${shop.subtotal}',
                          style: TextStyle(
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
                  : GridView.builder(
                      padding: const EdgeInsets.fromLTRB(17, 16, 17, 30),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 10,
                            mainAxisSpacing: 12,
                            childAspectRatio: .72,
                          ),
                      itemCount: items.length,
                      itemBuilder: (_, index) {
                        final product = items[index];
                        return _savedProductCard(product, shop);
                      },
                    ),
            ),
          ],
        );
      }),
    );
  }

  static Widget _savedProductCard(Product product, ShopController shop) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () {
          Get.back<void>();
          showProduct(product);
        },
        child: Container(
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.line),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.asset(product.image, fit: BoxFit.cover),
                    Positioned(
                      top: 7,
                      right: 7,
                      child: Material(
                        color: Colors.white.withOpacity(.92),
                        shape: const CircleBorder(),
                        child: InkWell(
                          customBorder: const CircleBorder(),
                          onTap: () => shop.toggleWishlist(product.id),
                          child: const Padding(
                            padding: EdgeInsets.all(7),
                            child: Icon(
                              Icons.favorite,
                              size: 16,
                              color: AppColors.goldDark,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(10, 9, 10, 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.category.toUpperCase(),
                      style: AppTypography.sans(
                        size: 7,
                        weight: FontWeight.w700,
                        color: AppColors.gold,
                        letterSpacing: .7,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      product.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTypography.serif(size: 14),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      '₹${product.price}',
                      style: AppTypography.sans(
                        size: 10,
                        weight: FontWeight.w800,
                        color: AppColors.goldDark,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
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
                  style: TextStyle(
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
                      style: TextStyle(
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
                      padding: const EdgeInsets.fromLTRB(17, 16, 17, 30),
                      itemCount: shop.orders.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 10),
                      itemBuilder: (_, index) {
                        final order = shop.orders[index];
                        return Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            border: Border.all(color: AppColors.line),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      'Order ${order.id}',
                                      style: AppTypography.sans(
                                        size: 10,
                                        weight: FontWeight.w800,
                                      ),
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: AppColors.successSoft,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      order.status.toUpperCase(),
                                      style: AppTypography.sans(
                                        size: 7,
                                        weight: FontWeight.w800,
                                        color: AppColors.successDark,
                                        letterSpacing: .42,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 9),
                              Text(
                                '${order.itemCount} ${order.itemCount == 1 ? 'item' : 'items'} · ₹${order.total}',
                                style: AppTypography.sans(
                                  size: 8,
                                  color: AppColors.muted,
                                  height: 1.45,
                                ),
                              ),
                            ],
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

  static void showAddresses() {
    final shop = Get.find<ShopController>();
    _open(
      Obx(
        () => Column(
          children: [
            _header('Saved Addresses'),
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.fromLTRB(17, 16, 17, 30),
                itemCount: shop.addresses.length,
                separatorBuilder: (_, __) => const SizedBox(height: 10),
                itemBuilder: (_, index) {
                  final address = shop.addresses[index];
                  return Material(
                    color: address.isDefault ? AppColors.cream : Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(12),
                      onTap: address.isDefault
                          ? null
                          : () => shop.setDefaultAddress(address.id),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 13,
                        ),
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: address.isDefault
                                ? AppColors.gold
                                : AppColors.line,
                          ),
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: address.isDefault
                              ? const [
                                  BoxShadow(
                                    color: Color(0x2EB97911),
                                    blurRadius: 0,
                                    spreadRadius: 1,
                                  ),
                                ]
                              : null,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  address.label,
                                  style: AppTypography.sans(
                                    size: 10,
                                    weight: FontWeight.w800,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                if (address.isDefault)
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 7,
                                      vertical: 3,
                                    ),
                                    decoration: BoxDecoration(
                                      color: AppColors.gold.withOpacity(.1),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Text(
                                      'DEFAULT',
                                      style: AppTypography.sans(
                                        size: 6,
                                        weight: FontWeight.w800,
                                        color: AppColors.goldDark,
                                        letterSpacing: .48,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Text(
                              address.user,
                              style: AppTypography.sans(
                                size: 9,
                                weight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              address.lines,
                              style: AppTypography.sans(
                                size: 8,
                                color: AppColors.muted,
                                height: 1.45,
                              ),
                            ),
                            if (!address.isDefault) ...[
                              const SizedBox(height: 8),
                              Text(
                                'SET AS DEFAULT',
                                style: AppTypography.sans(
                                  size: 7,
                                  weight: FontWeight.w800,
                                  color: AppColors.goldDark,
                                  letterSpacing: .56,
                                ),
                              ),
                            ],
                          ],
                        ),
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

  static void showSchemeDetails() {
    final scheme = Get.find<SchemeController>();
    _open(
      Obx(
        () => Column(
          children: [
            _header('My Gold Scheme'),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(17, 16, 17, 30),
                children: [
                  Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [Color(0xFFBD7E18), Color(0xFF835004)],
                      ),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x3B8A5404),
                          blurRadius: 35,
                          offset: Offset(0, 16),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'ACTIVE GOLD PLAN',
                                    style: AppTypography.sans(
                                      size: 8,
                                      color: Colors.white70,
                                      letterSpacing: .88,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    scheme.planName,
                                    style: AppTypography.serif(
                                      size: 21,
                                      color: Colors.white,
                                      height: 1.08,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 9,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(.13),
                                borderRadius: BorderRadius.circular(15),
                                border: Border.all(color: Colors.white30),
                              ),
                              child: Text(
                                'ACTIVE',
                                style: AppTypography.sans(
                                  size: 7,
                                  weight: FontWeight.w800,
                                  color: Colors.white,
                                  letterSpacing: .56,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        Text(
                          'Saved so far',
                          style: AppTypography.sans(
                            size: 9,
                            color: Colors.white70,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          scheme.money(scheme.savedAmount),
                          style: AppTypography.serif(
                            size: 32,
                            color: Colors.white,
                            height: 1,
                          ),
                        ),
                        const SizedBox(height: 17),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '${scheme.paidInstallments.value} of ${scheme.totalInstallments} instalments',
                              style: AppTypography.sans(
                                size: 8,
                                color: Colors.white,
                              ),
                            ),
                            Text(
                              '${scheme.progressPercent}%',
                              style: AppTypography.sans(
                                size: 8,
                                weight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 7),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: LinearProgressIndicator(
                            value: scheme.progress,
                            minHeight: 7,
                            color: const Color(0xFFFFF2CF),
                            backgroundColor: Colors.white24,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _schemeStat(
                          'Monthly amount',
                          scheme.money(scheme.monthlyAmount.value),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _schemeStat(
                          'Next due',
                          scheme.dateLabel(scheme.nextDueDate),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _schemeStat(
                          'Maturity',
                          scheme.dateLabel(scheme.maturityDate),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 19),
                  Text(
                    'Payment history',
                    style: AppTypography.serif(size: 18),
                  ),
                  const SizedBox(height: 9),
                  Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: AppColors.line),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: Column(
                      children: [
                        for (var index = 0;
                            index < scheme.payments.length;
                            index++)
                          _schemeScheduleRow(
                            scheme,
                            scheme.payments[index],
                            paid: true,
                            showDivider: index != scheme.payments.length - 1,
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 19),
                  Text(
                    'Upcoming payments',
                    style: AppTypography.serif(size: 18),
                  ),
                  const SizedBox(height: 9),
                  Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: AppColors.line),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: Column(
                      children: [
                        for (var index = 0;
                            index < scheme.upcomingPayments.length;
                            index++)
                          _schemeScheduleRow(
                            scheme,
                            scheme.upcomingPayments[index],
                            paid: false,
                            showDivider:
                                index != scheme.upcomingPayments.length - 1,
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  static Widget _schemeStat(String label, String value) {
    return Container(
      constraints: const BoxConstraints(minHeight: 60),
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: AppColors.line),
        borderRadius: BorderRadius.circular(11),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: AppTypography.sans(size: 7, color: AppColors.muted),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTypography.sans(size: 10, weight: FontWeight.w700),
          ),
        ],
      ),
    );
  }

  static Widget _schemeScheduleRow(
    SchemeController scheme,
    SchemePayment payment, {
    required bool paid,
    required bool showDivider,
  }) {
    return Container(
      constraints: const BoxConstraints(minHeight: 52),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: payment.isNext ? AppColors.cream : Colors.white,
        border: showDivider
            ? const Border(bottom: BorderSide(color: AppColors.line))
            : null,
      ),
      child: Row(
        children: [
          Container(
            width: 28,
            height: 28,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: paid
                  ? AppColors.successSoft
                  : payment.isNext
                      ? AppColors.gold
                      : const Color(0xFFFFF7E8),
              shape: BoxShape.circle,
            ),
            child: Text(
              paid ? '✓' : payment.isNext ? '●' : '${payment.installment}',
              style: AppTypography.sans(
                size: paid ? 12 : 8,
                weight: FontWeight.w800,
                color: paid
                    ? AppColors.successDark
                    : payment.isNext
                        ? Colors.white
                        : AppColors.goldDark,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Instalment ${payment.installment}${payment.isNext ? ' · Due next' : ''}',
                  style: AppTypography.sans(
                    size: 9,
                    weight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  paid
                      ? '${scheme.dateLabel(payment.date)} · ${payment.receipt}'
                      : '${scheme.dateLabel(payment.date)} · ${scheme.money(payment.amount)}',
                  style: AppTypography.sans(
                    size: 7,
                    color: AppColors.muted,
                  ),
                ),
              ],
            ),
          ),
          Text(
            scheme.money(payment.amount),
            style: AppTypography.sans(
              size: 10,
              weight: FontWeight.w700,
              color: AppColors.goldDark,
            ),
          ),
        ],
      ),
    );
  }

  static void showSchemeEnrollment() {
    final scheme = Get.find<SchemeController>();
    _open(
      Obx(
        () => Column(
          children: [
            _header('Wavoo Gold Scheme'),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(17, 16, 17, 30),
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(13),
                    child: Image.asset(
                      'assets/images/design_01.webp',
                      width: double.infinity,
                      height: 150,
                      fit: BoxFit.cover,
                    ),
                  ),
                  const SizedBox(height: 17),
                  Text(
                    'Save today. Shine tomorrow.',
                    style: AppTypography.serif(size: 25, height: 1),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Choose a comfortable monthly plan and build your jewellery savings with Wavoo.',
                    style: AppTypography.sans(
                      size: 10,
                      color: AppColors.muted,
                      height: 1.6,
                    ),
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      for (final months in [11, 6, 12]) ...[
                        Expanded(
                          child: InkWell(
                            onTap: () => scheme.choosePlan(months),
                            borderRadius: BorderRadius.circular(10),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 5,
                                vertical: 12,
                              ),
                              decoration: BoxDecoration(
                                color:
                                    scheme.selectedPlanMonths.value == months
                                        ? AppColors.cream
                                        : Colors.white,
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color:
                                      scheme.selectedPlanMonths.value == months
                                          ? AppColors.gold
                                          : AppColors.line,
                                  width:
                                      scheme.selectedPlanMonths.value == months
                                          ? 2
                                          : 1,
                                ),
                              ),
                              child: Column(
                                children: [
                                  Text(
                                    '$months Months',
                                    style: AppTypography.serif(
                                      size: 15,
                                      color: AppColors.goldDark,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    months == 11
                                        ? 'Most popular'
                                        : months == 6
                                            ? 'Flexible plan'
                                            : 'Maximum value',
                                    style: AppTypography.sans(
                                      size: 7,
                                      color: AppColors.muted,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        if (months != 12) const SizedBox(width: 8),
                      ],
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Monthly contribution',
                    style: AppTypography.sans(
                      size: 9,
                      weight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 7),
                  Container(
                    height: 46,
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(color: AppColors.line),
                      borderRadius: BorderRadius.circular(9),
                    ),
                    child: Row(
                      children: [
                        Text(
                          '₹',
                          style: AppTypography.sans(
                            size: 12,
                            weight: FontWeight.w700,
                            color: AppColors.goldDark,
                          ),
                        ),
                        const SizedBox(width: 7),
                        Expanded(
                          child: Text(
                            '${scheme.monthlyAmount.value}',
                            style: AppTypography.sans(size: 12),
                          ),
                        ),
                        PopupMenuButton<int>(
                          icon: const Icon(
                            Icons.expand_more,
                            color: AppColors.goldDark,
                          ),
                          onSelected: scheme.chooseAmount,
                          itemBuilder: (_) => [5000, 10000, 15000, 25000]
                              .map(
                                (amount) => PopupMenuItem(
                                  value: amount,
                                  child: Text(scheme.money(amount)),
                                ),
                              )
                              .toList(),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 13),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF7F2E9),
                      borderRadius: BorderRadius.circular(9),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.auto_awesome,
                          color: AppColors.gold,
                          size: 18,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'Save ${scheme.money(scheme.monthlyAmount.value * scheme.selectedPlanMonths.value)} over ${scheme.selectedPlanMonths.value} months and unlock exclusive Wavoo scheme benefits.',
                            style: AppTypography.sans(
                              size: 9,
                              color: const Color(0xFF5E574E),
                              height: 1.45,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 13),
                  SizedBox(
                    height: 47,
                    child: FilledButton(
                      onPressed: scheme.joinScheme,
                      child: Text(
                        'START MY GOLD SAVINGS',
                        style: AppTypography.sans(
                          size: 11,
                          weight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
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
                  style: AppTypography.serif(size: 32),
                ),
                Text(
                  'Secure payment for your Wavoo Gold Scheme',
                  style: TextStyle(color: AppColors.muted),
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
