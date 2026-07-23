import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../controllers/shop_controller.dart';
import '../../core/constants/app_colors.dart';
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
                style: GoogleFonts.notoSerif(
                  color: Colors.black,
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: SizedBox(
              height: 35,
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
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 0,
                      ),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: selected
                            ? AppColors.gold
                            : Colors
                                  .transparent, // Adjust unselected color as needed
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: selected
                              ? AppColors.gold
                              : AppColors.ink.withOpacity(0.3),
                        ),
                      ),
                      child: Text(
                        category,
                        style: GoogleFonts.notoSerif(
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
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 24),
            sliver: SliverGrid.builder(
              itemCount: shop.filteredProducts.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 0.67,
              ),
              itemBuilder: (_, index) =>
                  ProductCard(product: shop.filteredProducts[index]),
            ),
          ),
        ],
      ),
    );
  }
}
