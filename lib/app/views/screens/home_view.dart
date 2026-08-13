import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controllers/home_controller.dart';
import '../../controllers/navigation_controller.dart';
import '../../controllers/shop_controller.dart';
import '../../core/constants/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../widgets/product_card.dart';
import '../widgets/product_image.dart';
import '../widgets/scheme_progress_card.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  final PageController _pageController = PageController();
  int _slide = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final shop = Get.find<ShopController>();
    final nav = Get.find<NavigationController>();
    return ListView(
      padding: const EdgeInsets.fromLTRB(13, 9, 13, 24),
      children: [
        Obx(() {
          final slides = shop.products.take(4).toList();
          if (slides.isEmpty) {
            return ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: Container(
                height: 184,
                alignment: Alignment.center,
                color: AppColors.cream2,
                child: Text(
                  shop.isLoading.value
                      ? 'Loading jewellery…'
                      : (shop.loadError.value ?? 'No jewellery available yet'),
                  style: AppTypography.sans(size: 13, color: AppColors.muted),
                ),
              ),
            );
          }
          return SizedBox(
            height: 184,
            child: Stack(
              children: [
                PageView.builder(
                  controller: _pageController,
                  itemCount: slides.length,
                  onPageChanged: (value) => setState(() => _slide = value),
                  itemBuilder: (_, index) {
                    final product = slides[index];
                    return ClipRRect(
                      borderRadius: BorderRadius.circular(14),
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          ProductImage(url: product.image),
                          const DecoratedBox(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [Color(0xB8FFFDF9), Color(0x2AFFFDF9)],
                                stops: [0.05, 0.72],
                              ),
                            ),
                          ),
                          Positioned(
                            left: 18,
                            top: 24,
                            width: 190,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  product.category.toUpperCase(),
                                  style: const TextStyle(
                                    color: AppColors.goldDark,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w900,
                                    letterSpacing: 1.3,
                                  ),
                                ),
                                const SizedBox(height: 5),
                                Text(
                                  product.name,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: AppTypography.serif(
                                    size: 23,
                                    height: .99,
                                    letterSpacing: -.58,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                SizedBox(
                                  height: 40,
                                  child: FilledButton(
                                    onPressed: () => nav.changePage(1),
                                    style: FilledButton.styleFrom(
                                      backgroundColor: AppColors.gold,
                                      foregroundColor: Colors.white,
                                      minimumSize: const Size(48, 40),
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 14,
                                      ),
                                    ),
                                    child: const Text(
                                      'SHOP NOW',
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
                Positioned(
                  bottom: 9,
                  left: 0,
                  right: 0,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      slides.length,
                      (index) => AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        width: _slide == index ? 17 : 6,
                        height: 6,
                        margin: const EdgeInsets.symmetric(horizontal: 2),
                        decoration: BoxDecoration(
                          color:
                              _slide == index ? AppColors.gold : Colors.white70,
                          borderRadius: BorderRadius.circular(5),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        }),
        Obx(() {
          final label = Get.find<HomeController>().goldRateLabel.value;
          if (label == null || label.isEmpty) return const SizedBox.shrink();
          return Container(
            margin: const EdgeInsets.only(top: 10),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: AppColors.cream,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.goldBorder),
            ),
            child: Row(
              children: [
                const Icon(Icons.trending_up, color: AppColors.goldDark, size: 18),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    label,
                    style: AppTypography.sans(
                      size: 13,
                      weight: FontWeight.w700,
                      color: AppColors.goldDark,
                    ),
                  ),
                ),
              ],
            ),
          );
        }),
        const SizedBox(height: 12),
        SchemeProgressCard(onOpenPlan: () => nav.changePage(2)),
        const SizedBox(height: 12),
        Obx(() {
          final cover = shop.products.isEmpty ? null : shop.products.first.image;
          return InkWell(
            borderRadius: BorderRadius.circular(14),
            onTap: () => nav.changePage(2),
            child: Container(
              height: 146,
              decoration: BoxDecoration(
                color: AppColors.cream,
                borderRadius: BorderRadius.circular(14),
              ),
              clipBehavior: Clip.antiAlias,
              child: Row(
                children: [
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(17),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'GOLD SCHEME',
                            style: TextStyle(
                              color: AppColors.gold,
                              fontSize: 12,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 1.2,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Save More,\nShine More',
                            style: AppTypography.serif(size: 20, height: .95),
                          ),
                          const SizedBox(height: 7),
                          Text(
                            'Start your savings today',
                            style: Theme.of(context)
                                .textTheme
                                .bodySmall
                                ?.copyWith(fontSize: 13),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 150,
                    height: double.infinity,
                    child: ProductImage(url: cover),
                  ),
                ],
              ),
            ),
          );
        }),
        const SizedBox(height: 16),
        Obx(() {
          final tiles = shop.categoryTiles;
          if (tiles.isEmpty) return const SizedBox.shrink();
          return SizedBox(
            height: 70,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: tiles.length,
              itemBuilder: (_, index) {
                final tile = tiles[index];
                return Padding(
                  padding: const EdgeInsets.only(right: 14),
                  child: InkWell(
                    onTap: () {
                      shop.chooseCategory(tile.name);
                      nav.changePage(1);
                    },
                    child: SizedBox(
                      width: 58,
                      child: Column(
                        children: [
                          Container(
                            width: 50,
                            height: 50,
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: AppColors.gold.withOpacity(.4),
                              ),
                              shape: BoxShape.circle,
                            ),
                            clipBehavior: Clip.antiAlias,
                            child: ProductImage(url: tile.image),
                          ),
                          const SizedBox(height: 5),
                          Text(
                            tile.name,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontSize: 11),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          );
        }),
        _sectionHeader(context, 'New Arrivals', () {
          shop.chooseCategory('All');
          nav.changePage(1);
        }),
        Obx(() {
          final items = shop.products.take(4).toList();
          if (items.isEmpty) {
            return const SizedBox(
              height: 80,
              child: Center(child: Text('Jewellery loading…')),
            );
          }
          return SizedBox(
            height: 220,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: items.length,
              separatorBuilder: (_, __) => const SizedBox(width: 10),
              itemBuilder: (_, index) =>
                  ProductCard(product: items[index], width: 156),
            ),
          );
        }),
        _sectionHeader(context, 'Best Sellers', () {
          shop.chooseCategory('All');
          nav.changePage(1);
        }),
        Obx(() {
          final items = shop.products.skip(4).take(4).toList();
          final fallback = items.isEmpty ? shop.products.take(4).toList() : items;
          if (fallback.isEmpty) {
            return const SizedBox.shrink();
          }
          return SizedBox(
            height: 238,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: fallback.length,
              separatorBuilder: (_, __) => const SizedBox(width: 10),
              itemBuilder: (_, index) =>
                  ProductCard(product: fallback[index], width: 156),
            ),
          );
        }),
        const SizedBox(height: 17),
        InkWell(
          onTap: () => nav.changePage(3),
          child: Container(
            height: 118,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              image: const DecorationImage(
                image: AssetImage('assets/images/design_08.webp'),
                fit: BoxFit.cover,
              ),
            ),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
                gradient: const LinearGradient(
                  colors: [Color(0xD50E0904), Color(0x220E0904)],
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'EXCLUSIVE FOR YOU',
                    style: TextStyle(
                      color: AppColors.goldSoft,
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  Text(
                    'Special Offers',
                    style: AppTypography.serif(size: 20, color: Colors.white),
                  ),
                  Text(
                    'Up to 20% off on selected making charges',
                    style: TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _sectionHeader(
    BuildContext context,
    String title,
    VoidCallback onTap,
  ) =>
      Padding(
        padding: const EdgeInsets.only(top: 18, bottom: 10),
        child: Row(
          children: [
            Expanded(
              child:
                  Text(title, style: Theme.of(context).textTheme.headlineSmall),
            ),
            TextButton(onPressed: onTap, child: const Text('View All  ›')),
          ],
        ),
      );
}
