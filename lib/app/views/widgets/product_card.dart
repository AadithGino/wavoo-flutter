import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controllers/shop_controller.dart';
import '../../core/constants/app_colors.dart';
import '../../data/models/product.dart';
import '../widgets/sheets.dart';

class ProductCard extends StatelessWidget {
  const ProductCard({required this.product, this.width, super.key});

  final Product product;
  final double? width;

  @override
  Widget build(BuildContext context) {
    final shop = Get.find<ShopController>();
    return SizedBox(
      width: width,
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: () => AppSheets.showProduct(product),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppColors.line),
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AspectRatio(
                aspectRatio: 1,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.asset(product.image, fit: BoxFit.cover),
                    Positioned(
                      left: 4,
                      top: 4,
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          color: AppColors.gold.withOpacity(0.92),
                          borderRadius: BorderRadius.circular(2),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 5,
                          ),
                          child: Text(
                            product.tag.toUpperCase(),
                            style: TextStyle(
                              color: AppColors.ivory,
                              fontSize: 5,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      right: 6,
                      top: 6,
                      child: Obx(
                        () => IconButton.filledTonal(
                          color: Colors.white,
                          highlightColor: Colors.white,
                          splashColor: Colors.white,
                          focusColor: Colors.white,

                          visualDensity: VisualDensity.compact,
                          onPressed: () => shop.toggleWishlist(product.id),
                          icon: Icon(
                            shop.wishlist.contains(product.id)
                                ? Icons.favorite
                                : Icons.favorite_border,
                            color: AppColors.goldDark,
                            size: 18,
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
                      product.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 10, height: 1.25),
                    ),
                    const SizedBox(height: 5),
                    Row(
                      children: [
                        Text(
                          '₹${product.price}',
                          style: TextStyle(
                            color: AppColors.goldDark,
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          '₹${product.oldPrice}',
                          style: TextStyle(
                            color: AppColors.muted,
                            fontSize: 8,
                            decoration: TextDecoration.lineThrough,
                          ),
                        ),
                      ],
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
}
