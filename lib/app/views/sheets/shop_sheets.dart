import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../../controllers/shop_controller.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/indian_states.dart';
import '../../core/theme/app_typography.dart';
import '../../core/utils/money.dart';
import '../../data/models/address.dart';
import '../../data/models/order.dart';
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
                final price = latest.breakdown;
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
                    const SizedBox(height: 6),
                    Text(
                      [
                        if (latest.category.isNotEmpty) latest.category,
                        if (latest.purityLabel != null) latest.purityLabel,
                        if (latest.productCode != null) latest.productCode,
                      ].join(' · '),
                      style: AppTypography.sans(size: 13, color: AppColors.muted),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      latest.description.isEmpty
                          ? 'Fine jewellery from Wavoo Jewellers.'
                          : latest.description,
                      style: const TextStyle(color: AppColors.muted, height: 1.45),
                    ),
                    const SizedBox(height: 16),
                    if (latest.weightLabel.isNotEmpty)
                      _spec('Net weight', latest.weightLabel),
                    if (latest.hallmark != null && latest.hallmark!.isNotEmpty)
                      _spec('Hallmark', latest.hallmark!),
                    if (latest.size != null && latest.size!.isNotEmpty)
                      _spec('Size', latest.size!),
                    if (latest.stoneDetails != null && latest.stoneDetails!.isNotEmpty)
                      _spec('Stones', latest.stoneDetails!),
                    if (latest.stock != null)
                      _spec('Availability', latest.inStock
                          ? '${latest.stock} in stock'
                          : 'Sold out'),
                    if (price?.gstPaise != null || price?.makingChargePaise != null) ...[
                      const SizedBox(height: 8),
                      Text('Price break-up', style: AppTypography.serif(size: 18)),
                      const SizedBox(height: 8),
                      if (price?.goldValuePaise != null)
                        _spec('Gold value', Money.fromPaise(price!.goldValuePaise)),
                      if (price?.makingChargePaise != null)
                        _spec('Making', Money.fromPaise(price!.makingChargePaise)),
                      if (price?.wastageChargePaise != null)
                        _spec('Wastage', Money.fromPaise(price!.wastageChargePaise)),
                      if (price?.gstPaise != null)
                        _spec('GST', Money.fromPaise(price!.gstPaise)),
                    ],
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
                        child: Text(
                          shop.wishlist.contains(product.id) ? 'SAVED' : 'SAVE',
                        ),
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

Widget _spec(String label, String value) => Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          Expanded(
            child: Text(label, style: AppTypography.sans(color: AppColors.muted)),
          ),
          Text(value, style: AppTypography.sans(weight: FontWeight.w700)),
        ],
      ),
    );

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
                          title: const Text('Unavailable item'),
                          trailing: IconButton(
                            onPressed: () => shop.removeFromCart(entry.key),
                            icon: const Icon(Icons.delete_outline),
                          ),
                        );
                      }
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
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              onPressed: () => shop.changeQuantity(product.id, -1),
                              icon: const Icon(Icons.remove_circle_outline),
                            ),
                            Text('${entry.value}'),
                            IconButton(
                              onPressed: () => shop.changeQuantity(product.id, 1),
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
      final items = shop.wishlistItems;
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
  if (shop.addresses.isEmpty) {
    unawaited(shop.loadAddresses());
  }
  await openAppSheet(
    Obx(() {
      final address = shop.defaultAddress;
      final method = shop.paymentMethod.value;
      return Column(
        children: [
          sheetHeader('Checkout'),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text('Delivery address', style: AppTypography.serif(size: 18)),
                    ),
                    TextButton(
                      onPressed: () async {
                        await showAddressFormSheet(
                          prefilling: address,
                          asNew: address == null,
                        );
                      },
                      child: Text(address == null ? 'Add' : 'Change'),
                    ),
                  ],
                ),
                if (shop.addresses.isEmpty)
                  const Text('Add a delivery address to continue.')
                else
                  ...shop.addresses.map(
                    (item) => RadioListTile<String>(
                      contentPadding: EdgeInsets.zero,
                      value: item.id,
                      groupValue: shop.selectedAddressId.value.isEmpty
                          ? address?.id
                          : shop.selectedAddressId.value,
                      onChanged: (value) {
                        if (value != null) shop.selectAddress(value);
                      },
                      title: Text(item.label),
                      subtitle: Text(
                        item.isComplete
                            ? item.lines
                            : '${item.lines}\nIncomplete for checkout',
                      ),
                    ),
                  ),
                const SizedBox(height: 8),
                Text('Payment', style: AppTypography.serif(size: 18)),
                RadioListTile<String>(
                  contentPadding: EdgeInsets.zero,
                  value: 'PHONEPE',
                  groupValue: method,
                  onChanged: (value) {
                    if (value != null) shop.paymentMethod.value = value;
                  },
                  title: const Text('PhonePe'),
                  subtitle: const Text('Pay securely online'),
                ),
                RadioListTile<String>(
                  contentPadding: EdgeInsets.zero,
                  value: 'COD',
                  groupValue: method,
                  onChanged: (value) {
                    if (value != null) shop.paymentMethod.value = value;
                  },
                  title: const Text('Cash on delivery'),
                  subtitle: const Text('Available on eligible pincodes'),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Total'),
                    Text(
                      Money.fromPaise(shop.subtotalPaise),
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 18,
                      ),
                    ),
                  ],
                ),
                if (shop.paymentStatus.value != null) ...[
                  const SizedBox(height: 10),
                  Text(
                    shop.paymentStatus.value!,
                    style: AppTypography.sans(size: 13, color: AppColors.muted),
                  ),
                ],
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: FilledButton(
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
                        : Text(
                            method == 'PHONEPE' ? 'PAY WITH PHONEPE' : 'PLACE ORDER',
                          ),
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
                        title: Text(order.orderNumber),
                        subtitle: Text(
                          '${order.itemCount} items · ${order.statusLabel}',
                        ),
                        trailing: Text(Money.fromPaise(order.totalPaise)),
                        onTap: () => showOrderDetailSheet(order),
                      );
                    },
                  ),
          ),
        ],
      );
    }),
  );
}

Future<void> showOrderDetailSheet(JewelleryOrder order) async {
  final shop = Get.find<ShopController>();
  await openAppSheet(
    Obx(() {
      final latest = shop.orderById(order.id) ?? order;
      return Column(
        children: [
          sheetHeader(latest.orderNumber),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
              children: [
                _spec('Status', latest.statusLabel),
                _spec('Payment', latest.paymentMethod ?? '—'),
                _spec('Items', '${latest.itemCount}'),
                if (latest.subtotalPaise != null)
                  _spec('Subtotal', Money.fromPaise(latest.subtotalPaise)),
                if (latest.gstPaise != null)
                  _spec('GST', Money.fromPaise(latest.gstPaise)),
                _spec('Total', Money.fromPaise(latest.totalPaise)),
                if (latest.address != null) ...[
                  const SizedBox(height: 12),
                  Text('Deliver to', style: AppTypography.serif(size: 18)),
                  const SizedBox(height: 6),
                  Text(latest.address!.lines),
                ],
                if (latest.lines.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  Text('Items', style: AppTypography.serif(size: 18)),
                  ...latest.lines.map(
                    (line) => ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(line.name),
                      subtitle: Text('Qty ${line.quantity}'),
                      trailing: Text(Money.fromPaise(line.lineTotalPaise)),
                    ),
                  ),
                ],
                const SizedBox(height: 16),
                if (latest.isPendingPayment)
                  FilledButton(
                    onPressed: shop.placingOrder.value
                        ? null
                        : () => shop.resumeOrderPayment(latest),
                    child: const Text('CHECK PAYMENT'),
                  ),
                if (latest.canCancel) ...[
                  const SizedBox(height: 8),
                  OutlinedButton(
                    onPressed: () => shop.cancelOrder(latest),
                    child: const Text('CANCEL ORDER'),
                  ),
                ],
              ],
            ),
          ),
        ],
      );
    }),
  );
}

Future<void> showAddressesSheet() async {
  final shop = Get.find<ShopController>();
  unawaited(shop.loadAddresses());
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
                      return Card(
                        margin: const EdgeInsets.only(bottom: 10),
                        child: ListTile(
                          title: Text(address.label),
                          subtitle: Text(address.lines),
                          isThreeLine: true,
                          trailing: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              if (address.isDefault)
                                const Text('Default')
                              else
                                TextButton(
                                  onPressed: () => shop.setDefaultAddress(address.id),
                                  child: const Text('Default'),
                                ),
                            ],
                          ),
                          onTap: () => showAddressFormSheet(
                            prefilling: address,
                            asNew: false,
                          ),
                          onLongPress: () => shop.removeAddress(address.id),
                        ),
                      );
                    },
                  ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
            child: SizedBox(
              width: double.infinity,
              height: 48,
              child: FilledButton(
                onPressed: () => showAddressFormSheet(asNew: true),
                child: const Text('ADD ADDRESS'),
              ),
            ),
          ),
        ],
      ),
    ),
  );
}

Future<void> showAddressFormSheet({Address? prefilling, bool asNew = true}) async {
  final shop = Get.find<ShopController>();
  final label = TextEditingController(text: prefilling?.label ?? 'Home');
  final name = TextEditingController(text: prefilling?.name ?? '');
  final phone = TextEditingController(
    text: (prefilling?.phone ?? '').replaceAll(RegExp(r'\D'), '').replaceFirst(RegExp(r'^91'), ''),
  );
  final line1 = TextEditingController(text: prefilling?.line1 ?? '');
  final line2 = TextEditingController(text: prefilling?.line2 ?? '');
  final city = TextEditingController(text: prefilling?.city ?? '');
  final pincode = TextEditingController(text: prefilling?.pincode ?? '');
  var stateName = prefilling?.stateName ?? '';
  if (stateName.isNotEmpty && !indianStates.contains(stateName)) {
    stateName = indianStates.contains('Kerala') ? stateName : 'Kerala';
  }
  var isDefault = prefilling?.isDefault ?? shop.addresses.isEmpty;

  await openAppSheet(
    StatefulBuilder(
      builder: (context, setState) {
        return Column(
          children: [
            sheetHeader(asNew ? 'Add address' : 'Edit address'),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                children: [
                  TextField(
                    controller: label,
                    decoration: const InputDecoration(labelText: 'Label'),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: name,
                    textCapitalization: TextCapitalization.words,
                    decoration: const InputDecoration(labelText: 'Full name'),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: phone,
                    keyboardType: TextInputType.phone,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(10),
                    ],
                    decoration: const InputDecoration(
                      labelText: 'Mobile number',
                      prefixText: '+91 ',
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: line1,
                    decoration: const InputDecoration(labelText: 'Address line 1'),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: line2,
                    decoration: const InputDecoration(labelText: 'Address line 2 (optional)'),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: city,
                    decoration: const InputDecoration(labelText: 'City'),
                  ),
                  const SizedBox(height: 10),
                  DropdownButtonFormField<String>(
                    initialValue: indianStates.contains(stateName) ? stateName : null,
                    decoration: const InputDecoration(labelText: 'State'),
                    items: indianStates
                        .map((item) => DropdownMenuItem(value: item, child: Text(item)))
                        .toList(),
                    onChanged: (value) => setState(() => stateName = value ?? ''),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: pincode,
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(6),
                    ],
                    decoration: const InputDecoration(labelText: 'Pincode'),
                  ),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Default address'),
                    value: isDefault,
                    onChanged: (value) => setState(() => isDefault = value),
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    height: 48,
                    child: Obx(
                      () => FilledButton(
                        onPressed: shop.addressBusy.value
                            ? null
                            : () async {
                                final draft = Address(
                                  id: asNew ? '' : (prefilling?.id ?? ''),
                                  label: label.text.trim().isEmpty ? 'Home' : label.text.trim(),
                                  name: name.text.trim(),
                                  phone: phone.text.trim(),
                                  line1: line1.text.trim(),
                                  line2: line2.text.trim().isEmpty ? null : line2.text.trim(),
                                  city: city.text.trim(),
                                  stateName: stateName,
                                  pincode: pincode.text.trim(),
                                  user: name.text.trim(),
                                  lines: '',
                                  isDefault: isDefault,
                                );
                                if (!draft.isComplete) {
                                  Get.showSnackbar(
                                    const GetSnackBar(
                                      message: 'Please complete name, phone, address, city, state and 6-digit pincode',
                                      duration: Duration(seconds: 2),
                                    ),
                                  );
                                  return;
                                }
                                final ok = await shop.saveAddress(
                                  draft,
                                  existingId: asNew ? null : prefilling?.id,
                                );
                                if (ok) Get.back<void>();
                              },
                        child: shop.addressBusy.value
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : Text(asNew ? 'SAVE ADDRESS' : 'UPDATE ADDRESS'),
                      ),
                    ),
                  ),
                  if (!asNew && prefilling != null)
                    TextButton(
                      onPressed: () async {
                        await shop.removeAddress(prefilling.id);
                        Get.back<void>();
                      },
                      child: const Text('Delete address'),
                    ),
                ],
              ),
            ),
          ],
        );
      },
    ),
  );
}
