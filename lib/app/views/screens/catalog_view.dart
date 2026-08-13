import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controllers/shop_controller.dart';
import '../../core/constants/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../widgets/page_heading.dart';
import '../widgets/product_card.dart';

class CatalogView extends StatelessWidget {
  const CatalogView({super.key});

  @override
  Widget build(BuildContext context) {
    final shop = Get.find<ShopController>();
    return Obx(
      () => CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: PageHeading(
              title: 'Collections',
              subtitle: 'Fine jewellery for every moment',
              trailing: Text(
                '${shop.filteredProducts.length} pieces',
                style: const TextStyle(
                  color: Colors.black,
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: SizedBox(
              height: 44,
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                scrollDirection: Axis.horizontal,
                itemCount: shop.categories.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (_, index) {
                  final category = shop.categories[index];
                  final selected = shop.selectedCategory.value == category;

                  return GestureDetector(
                    onTap: () => shop.chooseCategory(category),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: selected ? AppColors.gold : Colors.transparent,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: selected
                              ? AppColors.gold
                              : AppColors.ink.withOpacity(0.3),
                        ),
                      ),
                      child: Text(
                        category,
                        style: TextStyle(
                          color: selected ? Colors.white : AppColors.ink,
                          fontWeight:
                              selected ? FontWeight.bold : FontWeight.w500,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          if (shop.isLoading.value && shop.products.isEmpty)
            const SliverFillRemaining(
              child: Center(child: CircularProgressIndicator()),
            )
          else if (shop.filteredProducts.isEmpty)
            SliverFillRemaining(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Text(
                    shop.loadError.value ?? 'No pieces in this collection yet.',
                    textAlign: TextAlign.center,
                    style: AppTypography.sans(size: 14, color: AppColors.muted),
                  ),
                ),
              ),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 24),
              sliver: SliverLayoutBuilder(
                builder: (context, constraints) {
                  final width = constraints.crossAxisExtent;
                  final crossAxisCount = width >= 700
                      ? 3
                      : width >= 480
                          ? 2
                          : 2;
                  return SliverGrid(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: crossAxisCount,
                      mainAxisSpacing: 12,
                      crossAxisSpacing: 12,
                      childAspectRatio: 0.67,
                    ),
                    delegate: SliverChildBuilderDelegate(
                      (_, index) =>
                          ProductCard(product: shop.filteredProducts[index]),
                      childCount: shop.filteredProducts.length,
                    ),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}
