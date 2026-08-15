import 'dart:convert';

import 'package:hive_flutter/hive_flutter.dart';

import '../models/product.dart';

class LocalBag {
  const LocalBag({
    required this.cart,
    required this.wishlist,
    required this.snapshots,
  });

  final Map<String, int> cart;
  final Set<String> wishlist;
  final Map<String, Product> snapshots;
}

/// On-device cart / wishlist. Cleared on logout.
class LocalShopStore {
  static const boxName = 'wavoo_shop_bag';
  static const _cartKey = 'cart';
  static const _wishlistKey = 'wishlist';
  static const _snapshotsKey = 'snapshots';

  Box<dynamic>? _box;

  Future<void> init() async {
    if (_box != null && _box!.isOpen) return;
    _box = Hive.isBoxOpen(boxName)
        ? Hive.box<dynamic>(boxName)
        : await Hive.openBox<dynamic>(boxName);
  }

  LocalBag read() {
    final box = _box;
    if (box == null || !box.isOpen) {
      return const LocalBag(cart: {}, wishlist: {}, snapshots: {});
    }
    return LocalBag(
      cart: _readCart(box.get(_cartKey)),
      wishlist: _readWishlist(box.get(_wishlistKey)),
      snapshots: _readSnapshots(box.get(_snapshotsKey)),
    );
  }

  Future<void> save({
    required Map<String, int> cart,
    required Set<String> wishlist,
    required Map<String, Product> snapshots,
  }) async {
    await init();
    final box = _box;
    if (box == null) return;
    await box.put(_cartKey, jsonEncode(cart));
    await box.put(_wishlistKey, jsonEncode(wishlist.toList()));
    await box.put(
      _snapshotsKey,
      jsonEncode(
        snapshots.map((id, product) => MapEntry(id, product.toBagJson())),
      ),
    );
  }

  Future<void> clear() async {
    await init();
    final box = _box;
    if (box == null || !box.isOpen) return;
    await box.clear();
  }

  Map<String, int> _readCart(dynamic raw) {
    final decoded = _decodeMap(raw);
    if (decoded == null) return {};
    final cart = <String, int>{};
    decoded.forEach((key, value) {
      final id = key.toString();
      final qty = value is num ? value.toInt() : int.tryParse('$value') ?? 0;
      if (id.isNotEmpty && qty > 0) cart[id] = qty;
    });
    return cart;
  }

  Set<String> _readWishlist(dynamic raw) {
    if (raw is String) {
      try {
        raw = jsonDecode(raw);
      } catch (_) {
        return {};
      }
    }
    if (raw is! List) return {};
    return raw
        .map((item) => item.toString())
        .where((id) => id.isNotEmpty)
        .toSet();
  }

  Map<String, Product> _readSnapshots(dynamic raw) {
    final decoded = _decodeMap(raw);
    if (decoded == null) return {};
    final snapshots = <String, Product>{};
    decoded.forEach((key, value) {
      if (value is! Map) return;
      final product = Product.fromBagJson(Map<dynamic, dynamic>.from(value));
      if (product.id.isEmpty) return;
      snapshots[product.id] = product;
    });
    return snapshots;
  }

  Map<dynamic, dynamic>? _decodeMap(dynamic raw) {
    if (raw is String) {
      try {
        raw = jsonDecode(raw);
      } catch (_) {
        return null;
      }
    }
    if (raw is Map) return raw;
    return null;
  }
}
