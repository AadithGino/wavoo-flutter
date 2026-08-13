class Product {
  const Product({
    required this.id,
    required this.name,
    required this.pricePaise,
    this.oldPricePaise,
    required this.category,
    required this.image,
    this.images = const [],
    this.tag = '',
    this.description = '',
    this.inStock = true,
    this.purityLabel,
    this.productCode,
    this.stock,
  });

  final String id;
  final String name;
  final int pricePaise;
  final int? oldPricePaise;
  final String category;
  final String image;
  final List<String> images;
  final String tag;
  final String description;
  final bool inStock;
  final String? purityLabel;
  final String? productCode;
  final int? stock;

  int get priceRupees => pricePaise ~/ 100;
  int? get oldPriceRupees =>
      oldPricePaise == null ? null : oldPricePaise! ~/ 100;

  factory Product.fromApi(Map<String, dynamic> json) {
    final price = json['price'];
    int pricePaise = 0;
    if (price is Map) {
      pricePaise = (price['unitTotalPaise'] as num?)?.toInt() ??
          (price['lineTotalPaise'] as num?)?.toInt() ??
          0;
    } else if (price is num) {
      pricePaise = price.toInt();
    }

    final urls = <String>[];
    final images = json['images'];
    if (images is List) {
      for (final item in images) {
        if (item is String && item.isNotEmpty) {
          urls.add(item);
        } else if (item is Map && item['url'] is String) {
          final url = (item['url'] as String).trim();
          if (url.isNotEmpty) urls.add(url);
        }
      }
    }

    final category = (json['category'] as String?)?.trim() ?? '';
    final name = (json['name'] as String?)?.trim() ?? 'Jewellery';
    final inStock = json['inStock'] != false;
    final purity = (json['purityLabel'] as String?)?.trim();
    final tag = !inStock
        ? 'Sold out'
        : (purity != null && purity.isNotEmpty ? purity : 'New');

    return Product(
      id: json['id']?.toString() ?? json['_id']?.toString() ?? '',
      name: name,
      pricePaise: pricePaise,
      category: _normalizeCategory(category),
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
}
