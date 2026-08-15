import '../../core/utils/media.dart';

class ProductPrice {
  const ProductPrice({
    required this.unitTotalPaise,
    this.lineTotalPaise,
    this.goldValuePaise,
    this.makingChargePaise,
    this.wastageChargePaise,
    this.stoneChargePaise,
    this.gstPaise,
  });

  final int unitTotalPaise;
  final int? lineTotalPaise;
  final int? goldValuePaise;
  final int? makingChargePaise;
  final int? wastageChargePaise;
  final int? stoneChargePaise;
  final int? gstPaise;

  factory ProductPrice.fromJson(Map<String, dynamic> json) {
    final unit = (json['unitTotalPaise'] as num?)?.toInt() ??
        (json['lineTotalPaise'] as num?)?.toInt() ??
        0;
    return ProductPrice(
      unitTotalPaise: unit,
      lineTotalPaise: (json['lineTotalPaise'] as num?)?.toInt(),
      goldValuePaise: (json['goldValuePaise'] as num?)?.toInt(),
      makingChargePaise: (json['makingChargePaise'] as num?)?.toInt(),
      wastageChargePaise: (json['wastageChargePaise'] as num?)?.toInt(),
      stoneChargePaise: (json['stoneChargePaise'] as num?)?.toInt(),
      gstPaise: (json['gstPaise'] as num?)?.toInt(),
    );
  }
}

class Product {
  const Product({
    required this.id,
    required this.name,
    required this.pricePaise,
    this.oldPricePaise,
    required this.category,
    this.categoryId = '',
    this.categoryImage,
    required this.image,
    this.images = const [],
    this.tag = '',
    this.description = '',
    this.inStock = true,
    this.purityLabel,
    this.productCode,
    this.stock,
    this.isNewArrival = false,
    this.isBestSeller = false,
    this.netWeightMg,
    this.grossWeightMg,
    this.stoneDetails,
    this.hallmark,
    this.size,
    this.breakdown,
  });

  final String id;
  final String name;
  final int pricePaise;
  final int? oldPricePaise;
  final String category;
  final String categoryId;
  final String? categoryImage;
  final String image;
  final List<String> images;
  final String tag;
  final String description;
  final bool inStock;
  final String? purityLabel;
  final String? productCode;
  final int? stock;
  final bool isNewArrival;
  final bool isBestSeller;
  final int? netWeightMg;
  final int? grossWeightMg;
  final String? stoneDetails;
  final String? hallmark;
  final String? size;
  final ProductPrice? breakdown;

  /// Rupees, matching the f2501df product card / sheet contract.
  int get price => pricePaise ~/ 100;

  /// Rupees for the strikethrough price when the API sends MRP.
  int get oldPrice {
    final old = oldPricePaise;
    if (old != null && old > 0) return old ~/ 100;
    return price;
  }

  int get priceRupees => price;
  int? get oldPriceRupees =>
      oldPricePaise == null ? null : oldPricePaise! ~/ 100;

  String get weightLabel => _gramsLabel(netWeightMg);

  String get grossWeightLabel => _gramsLabel(grossWeightMg);

  static String _gramsLabel(int? mg) {
    if (mg == null || mg <= 0) return '';
    final grams = mg / 1000;
    final text = grams == grams.roundToDouble()
        ? grams.toInt().toString()
        : grams.toStringAsFixed(2);
    return '$text g';
  }

  factory Product.fromApi(Map<String, dynamic> json) {
    ProductPrice? breakdown;
    int pricePaise = 0;
    final rawPrice = json['price'];
    if (rawPrice is Map) {
      breakdown = ProductPrice.fromJson(Map<String, dynamic>.from(rawPrice));
      pricePaise = breakdown.unitTotalPaise;
    } else if (rawPrice is num) {
      pricePaise = rawPrice.toInt();
    }

    final urls = <String>[];
    final images = json['images'];
    if (images is List) {
      for (final item in images) {
        String? raw;
        if (item is String && item.isNotEmpty) {
          raw = item;
        } else if (item is Map && item['url'] is String) {
          raw = (item['url'] as String).trim();
        }
        final resolved = Media.resolve(raw);
        if (resolved != null) urls.add(resolved);
      }
    }

    var categoryName = '';
    var categoryId = json['categoryId']?.toString() ?? '';
    String? categoryImage;
    final rawCategory = json['category'];
    if (rawCategory is Map) {
      final map = Map<String, dynamic>.from(rawCategory);
      categoryName = (map['name'] as String?)?.trim() ?? '';
      if (categoryId.isEmpty) {
        categoryId = map['id']?.toString() ?? map['_id']?.toString() ?? '';
      }
      categoryImage = Media.resolve(map['imageUrl'] as String?);
    } else if (rawCategory is String) {
      categoryName = rawCategory.trim();
    }

    final name = (json['name'] as String?)?.trim() ?? 'Jewellery';
    final inStock = json['inStock'] != false;
    final purity = (json['purityLabel'] as String?)?.trim();
    final isNew = _flag(json['isNewArrival']) || _flag(json['newArrival']);
    final isBest = _flag(json['isBestSeller']) || _flag(json['bestSeller']);
    final tag = !inStock
        ? 'Sold out'
        : isNew
            ? 'New'
            : isBest
                ? 'Best'
                : (purity != null && purity.isNotEmpty ? purity : 'Wavoo');

    return Product(
      id: json['id']?.toString() ?? json['_id']?.toString() ?? '',
      name: name,
      pricePaise: pricePaise,
      category: _normalizeCategory(categoryName),
      categoryId: categoryId,
      categoryImage: categoryImage,
      image: urls.isNotEmpty ? urls.first : '',
      images: urls,
      tag: tag,
      description: (json['description'] as String?)?.trim() ??
          (json['productCode'] as String?) ??
          '',
      inStock: inStock,
      purityLabel: purity,
      productCode: json['productCode'] as String?,
      stock: (json['stock'] as num?)?.toInt(),
      isNewArrival: isNew,
      isBestSeller: isBest,
      netWeightMg: (json['netWeightMg'] as num?)?.toInt(),
      grossWeightMg: (json['grossWeightMg'] as num?)?.toInt(),
      stoneDetails: (json['stoneDetails'] as String?)?.trim(),
      hallmark: (json['hallmark'] as String?)?.trim(),
      size: (json['size'] as String?)?.trim(),
      breakdown: breakdown,
      oldPricePaise: (json['oldPricePaise'] as num?)?.toInt() ??
          (json['mrpPaise'] as num?)?.toInt(),
    );
  }

  Map<String, dynamic> toBagJson() => {
        'id': id,
        'name': name,
        'pricePaise': pricePaise,
        'oldPricePaise': oldPricePaise,
        'category': category,
        'categoryId': categoryId,
        'image': image,
        'images': images,
        'tag': tag,
        'inStock': inStock,
      };

  factory Product.fromBagJson(Map<dynamic, dynamic> json) {
    final urls = <String>[];
    final images = json['images'];
    if (images is List) {
      for (final item in images) {
        final url = item?.toString() ?? '';
        if (url.isNotEmpty) urls.add(url);
      }
    }
    final image = json['image']?.toString() ?? '';
    if (image.isNotEmpty && urls.isEmpty) urls.add(image);
    return Product(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? 'Jewellery',
      pricePaise: (json['pricePaise'] as num?)?.toInt() ?? 0,
      oldPricePaise: (json['oldPricePaise'] as num?)?.toInt(),
      category: json['category']?.toString() ?? '',
      categoryId: json['categoryId']?.toString() ?? '',
      image: urls.isNotEmpty ? urls.first : image,
      images: urls,
      tag: json['tag']?.toString() ?? '',
      inStock: json['inStock'] != false,
    );
  }

  static String _normalizeCategory(String raw) {
    final lower = raw.toLowerCase();
    if (lower.contains('necklace')) return 'Necklaces';
    if (lower.contains('earring')) return 'Earrings';
    if (lower.contains('ring')) return 'Rings';
    if (lower.contains('bangle')) return 'Bangles';
    if (lower.contains('pendant')) return 'Pendants';
    return raw;
  }

  static bool _flag(dynamic value) {
    if (value == true || value == 1) return true;
    if (value is String) {
      final normalized = value.trim().toLowerCase();
      return normalized == 'true' || normalized == '1' || normalized == 'yes';
    }
    return false;
  }
}
