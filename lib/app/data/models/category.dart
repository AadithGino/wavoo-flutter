import '../../core/utils/media.dart';

class ShopCategory {
  const ShopCategory({
    required this.id,
    required this.name,
    this.slug = '',
    this.imageUrl,
    this.sortOrder = 0,
    this.isActive = true,
  });

  final String id;
  final String name;
  final String slug;
  final String? imageUrl;
  final int sortOrder;
  final bool isActive;

  factory ShopCategory.fromJson(Map<String, dynamic> json) {
    return ShopCategory(
      id: json['id']?.toString() ?? json['_id']?.toString() ?? '',
      name: (json['name'] as String?)?.trim() ?? '',
      slug: (json['slug'] as String?)?.trim() ?? '',
      imageUrl: Media.resolve(
        (json['imageUrl'] as String?) ?? (json['image'] as String?),
      ),
      sortOrder: (json['sortOrder'] as num?)?.toInt() ?? 0,
      isActive: json['isActive'] != false,
    );
  }
}
