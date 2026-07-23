class Product {
  const Product({
    required this.id,
    required this.name,
    required this.price,
    required this.oldPrice,
    required this.category,
    required this.image,
    required this.tag,
    required this.description,
  });

  final int id;
  final String name;
  final int price;
  final int oldPrice;
  final String category;
  final String image;
  final String tag;
  final String description;
}

