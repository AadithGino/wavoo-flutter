import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controllers/shop_controller.dart';
import '../../core/constants/app_colors.dart';
import '../widgets/empty_state.dart';
import '../widgets/page_heading.dart';
import '../widgets/product_card.dart';
import '../widgets/shimmers.dart';

class CatalogView extends StatelessWidget {
  const CatalogView({super.key});

  @override
  Widget build(BuildContext context) {
    final shop = Get.find<ShopController>();
    return Obx(() {
      final loading = shop.isLoading.value && shop.products.isEmpty;
      final hasCategories = shop.categoryTiles.isNotEmpty;
      final items = shop.filteredProducts;
      final catalogEmpty = !loading && shop.products.isEmpty;
      final filterEmpty = !loading && shop.products.isNotEmpty && items.isEmpty;

      return CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: PageHeading(
              title: 'Collections',
              subtitle: catalogEmpty
                  ? 'New pieces will appear here soon'
                  : 'Fine jewellery for every moment',
              trailing: catalogEmpty
                  ? null
                  : Text(
                      '${items.length} pieces',
                      style: const TextStyle(
                        color: Colors.black,
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
            ),
          ),
          if (loading && !hasCategories)
            const SliverToBoxAdapter(child: CatalogChipShimmer())
          else if (hasCategories)
            SliverToBoxAdapter(
              child: SizedBox(
                height: 35,
                child: ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  scrollDirection: Axis.horizontal,
                  itemCount: shop.categoryFilterChips.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 8),
                  itemBuilder: (_, index) {
                    final category = shop.categoryFilterChips[index];
                    final selected =
                        shop.selectedCategoryId.value == category.id;
                    return GestureDetector(
                      onTap: () => shop.chooseCategory(category.id),
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
                          category.name,
                          style: TextStyle(
                            color: selected ? Colors.white : AppColors.ink,
                            fontWeight: selected
                                ? FontWeight.bold
                                : FontWeight.normal,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          if (loading)
            const SliverToBoxAdapter(child: ProductGridShimmer())
          else if (catalogEmpty || filterEmpty)
            SliverFillRemaining(
              hasScrollBody: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 24, 16, 32),
                child: Center(
                  child: EmptyState(
                    icon: catalogEmpty
                        ? Icons.diamond_outlined
                        : Icons.search_off_rounded,
                    title: catalogEmpty
                        ? 'No collections yet'
                        : 'Nothing in this collection',
                    message: catalogEmpty
                        ? 'Fine jewellery will appear here as soon as new pieces are added.'
                        : 'Try another category, or view all pieces in the collection.',
                    actionLabel: catalogEmpty ? 'REFRESH' : 'VIEW ALL',
                    onAction: catalogEmpty
                        ? shop.loadCatalog
                        : () => shop.chooseCategory('All'),
                  ),
                ),
              ),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 24),
              sliver: SliverGrid.builder(
                itemCount: items.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: 0.67,
                ),
                itemBuilder: (_, index) => ProductCard(product: items[index]),
              ),
            ),
        ],
      );
    });
  }
}
