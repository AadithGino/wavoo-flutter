import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';

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
    final specs = _ProductSpecs.forProduct(product);
    _open(
      Column(
        children: [
          _header('Jewellery Details'),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(17, 16, 17, 30),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(13),
                    child: Image.asset(
                      product.image,
                      width: double.infinity,
                      height: 275,
                      fit: BoxFit.cover,
                    ),
                  ),
                  const SizedBox(height: 17),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              product.name,
                              style: AppTypography.serif(size: 24, height: 1),
                            ),
                            const SizedBox(height: 7),
                            Row(
                              children: [
                                Text(
                                  _money(product.price),
                                  style: AppTypography.sans(
                                    size: 15,
                                    color: AppColors.goldDark,
                                  ),
                                ),
                                if (product.oldPrice > product.price) ...[
                                  const SizedBox(width: 8),
                                  Text(
                                    _money(product.oldPrice),
                                    style: AppTypography.sans(
                                      size: 9,
                                      color: AppColors.muted,
                                    ).copyWith(
                                      decoration: TextDecoration.lineThrough,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ],
                        ),
                      ),
                      Obx(
                        () => IconButton(
                          onPressed: () => shop.toggleWishlist(product.id),
                          icon: SvgPicture.asset(
                            'assets/svg/wishlist.svg',
                            width: 20,
                            height: 20,
                            colorFilter: ColorFilter.mode(
                              shop.wishlist.contains(product.id)
                                  ? AppColors.gold
                                  : AppColors.goldDark,
                              BlendMode.srcIn,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 15),
                  Text(
                    product.description,
                    style: AppTypography.sans(
                      size: 10,
                      color: AppColors.muted,
                      height: 1.6,
                    ),
                  ),
                  const SizedBox(height: 17),
                  Text(
                    'Gold & weight details',
                    style: AppTypography.serif(size: 18),
                  ),
                  const SizedBox(height: 10),
                  GridView.count(
                    crossAxisCount: 2,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisSpacing: 8,
                    mainAxisSpacing: 8,
                    childAspectRatio: 2.28,
                    children: [
                      _productSpec('Gold purity', specs.purity),
                      _productSpec('Hallmark', specs.hallmark),
                      _productSpec('Gross weight', specs.grossWeight),
                      _productSpec('Net gold weight', specs.netWeight),
                      _productSpec('Product code', specs.productCode),
                      _productSpec('Size', specs.size),
                    ],
                  ),
                  const SizedBox(height: 17),
                  Text(
                    'Stone details',
                    style: AppTypography.serif(size: 18),
                  ),
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.cream,
                      border: Border.all(color: const Color(0xFFEADBC4)),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 35,
                          height: 35,
                          alignment: Alignment.center,
                          decoration: const BoxDecoration(
                            color: AppColors.gold,
                            shape: BoxShape.circle,
                          ),
                          child: SvgPicture.asset(
                            'assets/svg/diamond.svg',
                            width: 18,
                            height: 18,
                          ),
                        ),
                        const SizedBox(width: 11),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Stone type, count and weight',
                                style: AppTypography.sans(
                                  size: 9,
                                  color: AppColors.muted,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${specs.stoneDetails} · ${specs.stoneWeight}',
                                style: AppTypography.sans(
                                  size: 10,
                                  weight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 17),
                  Text(
                    'Price breakup',
                    style: AppTypography.serif(size: 18),
                  ),
                  const SizedBox(height: 10),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(color: AppColors.line),
                      borderRadius: BorderRadius.circular(11),
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: Column(
                      children: [
                        _priceRow('Gold value', specs.goldValue),
                        _priceRow(
                          'Making charge (12%)',
                          specs.makingCharge,
                        ),
                        _priceRow(
                          'Wastage charge (3%)',
                          specs.wastageCharge,
                        ),
                        _priceRow('Stone charge', specs.stoneCharge),
                        _priceRow('GST (3%)', specs.gst),
                        _priceRow(
                          'Total price',
                          product.price,
                          total: true,
                          showDivider: false,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Final invoice value may change slightly based on the live gold rate and verified product weight at billing.',
                    style: AppTypography.sans(
                      size: 9,
                      color: AppColors.muted,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.fromLTRB(17, 12, 17, 14),
            decoration: const BoxDecoration(
              color: Color(0xFFFFFDF9),
              border: Border(top: BorderSide(color: AppColors.line)),
              boxShadow: [
                BoxShadow(
                  color: Color(0x1455370F),
                  blurRadius: 30,
                  offset: Offset(0, -10),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => _toast(
                      'Enquiry sent for ${product.name} — our team will contact you shortly',
                    ),
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size(0, 47),
                      side: const BorderSide(color: Color(0xFFE6DAC9)),
                      foregroundColor: AppColors.goldDark,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      textStyle: AppTypography.sans(
                        size: 10,
                        weight: FontWeight.w700,
                        letterSpacing: .2,
                      ),
                    ),
                    child: const Text('ENQUIRE NOW'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Container(
                    height: 47,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [Color(0xFFC48A27), Color(0xFF9E6106)],
                      ),
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x2E9E6206),
                          blurRadius: 18,
                          offset: Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Material(
                      color: Colors.transparent,
                      borderRadius: BorderRadius.circular(8),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(8),
                        onTap: () => shop.addToCart(product.id),
                        child: Center(
                          child: Text(
                            'ADD TO BAG',
                            style: AppTypography.sans(
                              size: 10,
                              weight: FontWeight.w700,
                              color: Colors.white,
                              letterSpacing: .2,
                            ),
                          ),
                        ),
                      ),
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

  static Widget _productSpec(String label, String value) {
    return Container(
      padding: const EdgeInsets.all(11),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: AppColors.line),
        borderRadius: BorderRadius.circular(9),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            label,
            style: AppTypography.sans(size: 9, color: AppColors.muted),
          ),
          const SizedBox(height: 5),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTypography.sans(
              size: 10,
              weight: FontWeight.w700,
              height: 1.35,
            ),
          ),
        ],
      ),
    );
  }

  static Widget _priceRow(
    String label,
    int amount, {
    bool total = false,
    bool showDivider = true,
  }) {
    return Container(
      constraints: BoxConstraints(minHeight: total ? 47 : 38),
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: total ? AppColors.cream : Colors.white,
        border: showDivider
            ? const Border(bottom: BorderSide(color: AppColors.line))
            : null,
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: AppTypography.sans(
                size: total ? 9 : 9,
                weight: total ? FontWeight.w800 : FontWeight.w400,
                color: total ? AppColors.ink : const Color(0xFF5E574E),
              ),
            ),
          ),
          Text(
            _money(amount),
            style: AppTypography.sans(
              size: total ? 13 : 10,
              weight: FontWeight.w800,
              color: total ? AppColors.goldDark : AppColors.ink,
            ),
          ),
        ],
      ),
    );
  }

  static void _toast(String message) {
    Get.showSnackbar(
      GetSnackBar(
        message: message,
        duration: const Duration(seconds: 2),
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.fromLTRB(20, 0, 20, 88),
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 11),
        borderRadius: 20,
        backgroundColor: const Color(0xFF211D18),
      ),
    );
  }

  static String _money(int amount) {
    final digits = amount.toString();
    if (digits.length <= 3) return '₹$digits';
    final tail = digits.substring(digits.length - 3);
    var head = digits.substring(0, digits.length - 3);
    final groups = <String>[];
    while (head.length > 2) {
      groups.insert(0, head.substring(head.length - 2));
      head = head.substring(0, head.length - 2);
    }
    if (head.isNotEmpty) groups.insert(0, head);
    return '₹${groups.join(',')},$tail';
  }

  static void showContactWavoo() {
    _open(
      Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _header('Contact Wavoo'),
          Padding(
            padding: const EdgeInsets.fromLTRB(17, 16, 17, 30),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'We are here to help',
                  style: AppTypography.serif(size: 22),
                ),
                const SizedBox(height: 7),
                Text(
                  'Contact Wavoo Jewellers using the phone number or email address below.',
                  style: AppTypography.sans(
                    size: 10,
                    color: AppColors.muted,
                    height: 1.55,
                  ),
                ),
                const SizedBox(height: 16),
                _contactAction(
                  icon: Icons.phone_outlined,
                  label: 'Company Mobile No',
                  value: '8925162888',
                  onTap: () => _launchContact(
                    Uri(scheme: 'tel', path: '8925162888'),
                  ),
                ),
                const SizedBox(height: 10),
                _contactAction(
                  icon: Icons.mail_outline,
                  label: 'Company Email',
                  value: 'wavoojewellers@yahoo.com',
                  onTap: () => _launchContact(
                    Uri(
                      scheme: 'mailto',
                      path: 'wavoojewellers@yahoo.com',
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

  static Widget _contactAction({
    required IconData icon,
    required String label,
    required String value,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.line),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Container(
                width: 42,
                height: 42,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: AppColors.gold.withOpacity(.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, size: 20, color: AppColors.goldDark),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: AppTypography.sans(
                        size: 8,
                        color: AppColors.muted,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      value,
                      style: AppTypography.sans(
                        size: 11,
                        weight: FontWeight.w700,
                        color: AppColors.goldDark,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.arrow_outward,
                size: 17,
                color: AppColors.goldDark,
              ),
            ],
          ),
        ),
      ),
    );
  }

  static Future<void> _launchContact(Uri uri) async {
    try {
      final opened = await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );
      if (opened) return;
    } catch (e) {
      log(e.toString());
      _toast('Error $e');
      // The user receives the same message for unsupported platform handlers.
    }
    // if (Get.isBottomSheetOpen == true) {
    //   _toast('Unable to open this contact option on your device');
    // }
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
                        Future<void>.delayed(
                          const Duration(milliseconds: 220),
                          AppSheets.showCheckout,
                        );
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
        final items =
            shop.products.where((p) => shop.wishlist.contains(p.id)).toList();
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
                        size: 9,
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
                                        size: 9,
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
                                        size: 8,
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
                                size: 10,
                                weight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              address.lines,
                              style: AppTypography.sans(
                                size: 9,
                                color: AppColors.muted,
                                height: 1.45,
                              ),
                            ),
                            if (!address.isDefault) ...[
                              const SizedBox(height: 8),
                              Text(
                                'SET AS DEFAULT',
                                style: AppTypography.sans(
                                  size: 10,
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
                                  size: 9,
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
            style: AppTypography.sans(size: 9, color: AppColors.muted),
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
              paid
                  ? '✓'
                  : payment.isNext
                      ? '●'
                      : '${payment.installment}',
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
                    size: 9,
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
                                color: scheme.selectedPlanMonths.value == months
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
                                      size: 9,
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
                  onPressed: () {
                    final reachesMaturity = scheme.paidInstallments.value ==
                        scheme.totalInstallments - 1;
                    scheme.payInstallment();
                    if (reachesMaturity) {
                      Future<void>.delayed(
                        const Duration(milliseconds: 350),
                        AppSheets.showRedemption,
                      );
                    }
                  },
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
    final step = (scheme.isRedeemed.value ? 4 : 1).obs;
    final selectedMethod = ''.obs;
    final justConfirmed = false.obs;
    _open(
      Obx(
        () => Column(
          children: [
            _header(
              step.value == 1
                  ? 'Redeem maturity'
                  : step.value == 2
                      ? 'Choose redemption'
                      : step.value == 3
                          ? 'Confirm redemption'
                          : justConfirmed.value
                              ? 'Redemption confirmed'
                              : 'Redemption complete',
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(17, 16, 17, 30),
                child: step.value == 4
                    ? _redemptionSuccess(scheme, justConfirmed.value)
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _flowSteps(step.value),
                          const SizedBox(height: 14),
                          if (step.value == 1)
                            _redemptionIntro(scheme, step)
                          else if (step.value == 2)
                            _redemptionChoices(
                              scheme,
                              step,
                              selectedMethod,
                            )
                          else
                            _redemptionReview(
                              scheme,
                              step,
                              selectedMethod,
                              justConfirmed,
                            ),
                        ],
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  static Widget _flowSteps(int step) {
    return Row(
      children: [
        for (var index = 1; index <= 3; index++) ...[
          Expanded(
            child: Container(
              height: 4,
              decoration: BoxDecoration(
                color: index <= step ? AppColors.gold : AppColors.line,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
          if (index != 3) const SizedBox(width: 6),
        ],
      ],
    );
  }

  static Widget _redemptionIntro(
    SchemeController scheme,
    RxInt step,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: double.infinity,
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
              Text(
                'SCHEME MATURED',
                style: AppTypography.sans(
                  size: 8,
                  color: Colors.white.withOpacity(.75),
                  letterSpacing: .88,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                scheme.money(scheme.savedAmount),
                style: AppTypography.serif(
                  size: 30,
                  color: Colors.white,
                  height: 1,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '${scheme.planName} · ${scheme.totalInstallments} instalments completed · matured ${scheme.dateLabel(scheme.maturityDate)}',
                style: AppTypography.sans(
                  size: 9,
                  color: Colors.white.withOpacity(.78),
                  height: 1.45,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        _redemptionSummary([
          ('Scheme ID', 'WAV-GS-2404'),
          ('Total contributions', scheme.money(scheme.savedAmount)),
          ('Making charge benefit', 'Up to 8% off'),
          ('Redemption window', 'Open now'),
        ]),
        Text(
          'Your plan is ready for redemption. Continue to choose how you would like to use your matured savings.',
          style: AppTypography.sans(
            size: 10,
            color: AppColors.muted,
            height: 1.6,
          ),
        ),
        const SizedBox(height: 13),
        _redemptionButton(
          'CONTINUE TO REDEEM',
          onTap: () => step.value = 2,
        ),
      ],
    );
  }

  static Widget _redemptionChoices(
    SchemeController scheme,
    RxInt step,
    RxString selectedMethod,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Select how you would like to redeem your matured gold savings.',
          style: AppTypography.sans(
            size: 10,
            color: AppColors.muted,
            height: 1.6,
          ),
        ),
        const SizedBox(height: 12),
        _redemptionOption(
          symbol: '✦',
          value: 'showroom',
          title: 'Redeem at showroom',
          description:
              'Visit your nearest Wavoo store with your scheme ID and choose jewellery on the spot.',
          selectedMethod: selectedMethod,
        ),
        const SizedBox(height: 8),
        _redemptionOption(
          symbol: '◆',
          value: 'purchase',
          title: 'Apply to jewellery purchase',
          description:
              'Use your savings as credit towards necklaces, rings, bangles and more in the app.',
          selectedMethod: selectedMethod,
        ),
        const SizedBox(height: 8),
        _redemptionOption(
          symbol: '◎',
          value: 'pickup',
          title: 'Schedule home pickup',
          description:
              'Book a doorstep collection and receive your redemption voucher securely at home.',
          selectedMethod: selectedMethod,
        ),
        const SizedBox(height: 13),
        _redemptionButton(
          'REVIEW REDEMPTION',
          enabled: selectedMethod.value.isNotEmpty,
          onTap: () => step.value = 3,
        ),
      ],
    );
  }

  static Widget _redemptionOption({
    required String symbol,
    required String value,
    required String title,
    required String description,
    required RxString selectedMethod,
  }) {
    final selected = selectedMethod.value == value;
    return Material(
      color: selected ? AppColors.cream : Colors.white,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: () => selectedMethod.value = value,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
          decoration: BoxDecoration(
            border: Border.all(
              color: selected ? AppColors.gold : AppColors.line,
            ),
            borderRadius: BorderRadius.circular(12),
            boxShadow: selected
                ? const [
                    BoxShadow(
                      color: Color(0x2EB97911),
                      blurRadius: 0,
                      spreadRadius: 1,
                    ),
                  ]
                : null,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 36,
                height: 36,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: AppColors.gold.withOpacity(.1),
                  shape: BoxShape.circle,
                ),
                child: Text(
                  symbol,
                  style: AppTypography.sans(
                    size: 14,
                    color: AppColors.goldDark,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: AppTypography.sans(
                        size: 10,
                        weight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: AppTypography.sans(
                        size: 8,
                        color: AppColors.muted,
                        height: 1.4,
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

  static Widget _redemptionReview(
    SchemeController scheme,
    RxInt step,
    RxString selectedMethod,
    RxBool justConfirmed,
  ) {
    final method = switch (selectedMethod.value) {
      'showroom' => 'Redeem at showroom',
      'purchase' => 'Apply to jewellery purchase',
      _ => 'Schedule home pickup',
    };
    final completionMethod = switch (selectedMethod.value) {
      'showroom' => 'Showroom redemption',
      'purchase' => 'Jewellery purchase credit',
      _ => 'Home pickup redemption',
    };
    final note = switch (selectedMethod.value) {
      'showroom' =>
        'Bring a valid ID and scheme reference WAV-GS-2404 to any Wavoo showroom. Our team will assist with redemption on the same day.',
      'purchase' =>
        'Your savings will be added as store credit and can be applied during checkout on your next jewellery purchase.',
      _ =>
        'Our team will contact you to schedule a secure pickup at your saved home address.',
    };
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _redemptionSummary([
          ('Redemption amount', scheme.money(scheme.savedAmount)),
          ('Redemption method', method),
          ('Maturity date', scheme.dateLabel(scheme.maturityDate)),
        ]),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.cream,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            note,
            style: AppTypography.sans(
              size: 9,
              color: AppColors.muted,
              height: 1.45,
            ),
          ),
        ),
        const SizedBox(height: 13),
        _redemptionButton(
          'CONFIRM REDEMPTION',
          onTap: () {
            scheme.redeem(completionMethod);
            justConfirmed.value = true;
            step.value = 4;
          },
        ),
        SizedBox(
          width: double.infinity,
          child: TextButton(
            onPressed: () => step.value = 2,
            child: Text(
              'Back',
              style: AppTypography.sans(
                size: 10,
                weight: FontWeight.w700,
                color: AppColors.goldDark,
              ),
            ),
          ),
        ),
      ],
    );
  }

  static Widget _redemptionSummary(List<(String, String)> rows) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.line),
        borderRadius: BorderRadius.circular(12),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          for (var index = 0; index < rows.length; index++)
            Container(
              constraints: const BoxConstraints(minHeight: 40),
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                border: index == rows.length - 1
                    ? null
                    : const Border(
                        bottom: BorderSide(color: AppColors.line),
                      ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      rows[index].$1,
                      style: AppTypography.sans(
                        size: 9,
                        color: const Color(0xFF5E574E),
                      ),
                    ),
                  ),
                  Text(
                    rows[index].$2,
                    style: AppTypography.sans(
                      size: 10,
                      weight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  static Widget _redemptionButton(
    String label, {
    required VoidCallback onTap,
    bool enabled = true,
  }) {
    return Opacity(
      opacity: enabled ? 1 : .55,
      child: Container(
        width: double.infinity,
        height: 47,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFC48A27), Color(0xFF9E6106)],
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: enabled ? onTap : null,
            borderRadius: BorderRadius.circular(8),
            child: Center(
              child: Text(
                label,
                style: AppTypography.sans(
                  size: 11,
                  weight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  static Widget _redemptionSuccess(
    SchemeController scheme,
    bool justConfirmed,
  ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 28),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.white, Color(0xFFFBF2E5)],
        ),
        border: Border.all(color: const Color(0xFFEADBC4)),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Container(
            width: 54,
            height: 54,
            alignment: Alignment.center,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [AppColors.goldLight, AppColors.goldDeep],
              ),
              shape: BoxShape.circle,
            ),
            child: Text(
              '✓',
              style: AppTypography.sans(
                size: 22,
                weight: FontWeight.w800,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            justConfirmed ? 'Redemption submitted' : 'Maturity redeemed',
            style: AppTypography.serif(size: 22),
          ),
          const SizedBox(height: 8),
          Text(
            justConfirmed
                ? 'Your matured savings of ${scheme.money(scheme.savedAmount)} are being processed via ${scheme.redemptionMethod.value}.'
                : 'Your gold savings of ${scheme.money(scheme.savedAmount)} have been processed via ${scheme.redemptionMethod.value}.',
            textAlign: TextAlign.center,
            style: AppTypography.sans(
              size: 10,
              color: AppColors.muted,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.cream,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              'Reference · ${scheme.redemptionReference.value}',
              style: AppTypography.sans(
                size: 9,
                weight: FontWeight.w700,
                color: AppColors.goldDark,
              ),
            ),
          ),
          const SizedBox(height: 14),
          _redemptionButton('DONE', onTap: () => Get.back<void>()),
        ],
      ),
    );
  }
}

class _ProductSpecs {
  const _ProductSpecs({
    required this.purity,
    required this.hallmark,
    required this.grossWeight,
    required this.netWeight,
    required this.productCode,
    required this.size,
    required this.stoneDetails,
    required this.stoneWeight,
    required this.goldValue,
    required this.makingCharge,
    required this.wastageCharge,
    required this.stoneCharge,
    required this.gst,
  });

  final String purity;
  final String hallmark;
  final String grossWeight;
  final String netWeight;
  final String productCode;
  final String size;
  final String stoneDetails;
  final String stoneWeight;
  final int goldValue;
  final int makingCharge;
  final int wastageCharge;
  final int stoneCharge;
  final int gst;

  factory _ProductSpecs.forProduct(Product product) {
    const grossWeights = [
      '18.42 g',
      '12.80 g',
      '3.84 g',
      '22.60 g',
      '4.60 g',
      '30.85 g',
      '14.20 g',
      '4.12 g',
    ];
    const netWeights = [
      '17.65 g',
      '12.10 g',
      '3.62 g',
      '22.60 g',
      '3.90 g',
      '29.10 g',
      '13.30 g',
      '3.58 g',
    ];
    const stoneDetails = [
      'Ruby & CZ · 22 stones',
      'Ruby stones · 18 stones',
      'White CZ · 28 stones',
      'Hand engraved · No stones',
      'White CZ · 7 stones',
      'Ruby stones · 31 stones',
      'Ruby stones · 16 stones',
      'VVS Diamond · 17 stones',
    ];
    const stoneWeights = [
      '0.77 g',
      '0.70 g',
      '0.22 g',
      'No stones',
      '0.70 g',
      '1.75 g',
      '0.90 g',
      '0.54 ct',
    ];
    const sizes = [
      '18 inches',
      'Free size',
      'Size 14',
      'Size 2.6',
      '16-inch chain',
      '20 inches',
      'Free size',
      'Size 13',
    ];
    final index = (product.id - 1).clamp(0, 7).toInt();
    final goldValue = (product.price * .75).round();
    final makingCharge = (goldValue * .12).round();
    final wastageCharge = (goldValue * .03).round();
    final gst = (product.price * .03).round();
    final stoneCharge =
        product.price - goldValue - makingCharge - wastageCharge - gst;
    final codePrefix = switch (product.category) {
      'Necklaces' => 'NK',
      'Earrings' => 'ER',
      'Rings' => 'RG',
      'Bangles' => 'BG',
      'Pendants' => 'PD',
      _ => 'JW',
    };
    final isDiamond = product.name.toLowerCase().contains('diamond');

    return _ProductSpecs(
      purity: isDiamond ? '18K Gold' : '22K Gold',
      hallmark: isDiamond ? 'BIS 750 HUID' : 'BIS 916 HUID',
      grossWeight: grossWeights[index],
      netWeight: netWeights[index],
      productCode: 'WAV-$codePrefix-${(1000 + product.id * 37).toString()}',
      size: sizes[index],
      stoneDetails: stoneDetails[index],
      stoneWeight: stoneWeights[index],
      goldValue: goldValue,
      makingCharge: makingCharge,
      wastageCharge: wastageCharge,
      stoneCharge: stoneCharge,
      gst: gst,
    );
  }
}
