import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controllers/shop_controller.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/money.dart';
import '../../data/models/product.dart';
import '../sheets/app_sheets.dart';
import 'product_image.dart';

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
                    ProductImage(url: product.image),
                    Positioned(
                      left: 4,
                      top: 4,
                      child: Container(
                        constraints: const BoxConstraints(minWidth: 55),
                        decoration: BoxDecoration(
                          color: AppColors.gold.withOpacity(0.92),
                          borderRadius: BorderRadius.circular(2),
                        ),
                        child: Center(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 5,
                            ),
                            child: Text(
                              product.tag.toUpperCase(),
                              style: const TextStyle(
                                color: AppColors.ivory,
                                fontSize: 11,
                                fontWeight: FontWeight.w800,
                              ),
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
                          visualDensity: VisualDensity.compact,
                          constraints: const BoxConstraints(
                            minWidth: 44,
                            minHeight: 44,
                          ),
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
                      style: const TextStyle(fontSize: 13, height: 1.25),
                    ),
                    const SizedBox(height: 5),
                    Row(
                      children: [
                        Text(
                          Money.fromPaise(product.pricePaise),
                          style: const TextStyle(
                            color: AppColors.goldDark,
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        if (product.oldPricePaise != null) ...[
                          const SizedBox(width: 6),
                          Text(
                            Money.fromPaise(product.oldPricePaise),
                            style: const TextStyle(
                              color: AppColors.muted,
                              fontSize: 11,
                              decoration: TextDecoration.lineThrough,
                            ),
                          ),
                        ],
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
