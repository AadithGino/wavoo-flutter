import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controllers/home_controller.dart';
import '../../controllers/navigation_controller.dart';
import '../../controllers/scheme_controller.dart';
import '../../controllers/shop_controller.dart';
import '../../core/constants/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/utils/money.dart';
import '../../data/models/scheme.dart';
import '../widgets/empty_state.dart';
import '../widgets/product_card.dart';
import '../widgets/product_image.dart';
import '../widgets/scheme_progress_card.dart';
import '../widgets/sheets.dart';
import '../widgets/shimmers.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  final PageController _pageController = PageController();
  int _slide = 0;

  static const _slides = [
    (
      'assets/images/design_00.webp',
      'TIMELESS BEAUTY',
      'Crafted for\nyour moments',
      'Discover elegance in every sparkle.',
    ),
    (
      'assets/images/design_11.webp',
      'BRIDAL EDIT',
      'Made for your\nforever moment',
      'Jewellery as unforgettable as your story.',
    ),
    (
      'assets/images/design_12.webp',
      'HERITAGE GOLD',
      'Tradition,\nbeautifully retold',
      'Fine craft inspired by Kerala celebrations.',
    ),
    (
      'assets/images/design_13.webp',
      'EVERYDAY ICONS',
      'A little gold\nfor every day',
      'Effortless pieces that feel uniquely yours.',
    ),
  ];

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
        SizedBox(
          height: 184,
          child: Stack(
            children: [
              PageView.builder(
                controller: _pageController,
                itemCount: _slides.length,
                onPageChanged: (value) => setState(() => _slide = value),
                itemBuilder: (_, index) {
                  final slide = _slides[index];
                  return ClipRRect(
                    borderRadius: BorderRadius.circular(14),
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        Image.asset(slide.$1, fit: BoxFit.cover),
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
                                slide.$2,
                                style: TextStyle(
                                  color: AppColors.goldDark,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 1.3,
                                ),
                              ),
                              const SizedBox(height: 5),
                              Text(
                                slide.$3,
                                style: AppTypography.serif(
                                  size: 23,
                                  height: .99,
                                  letterSpacing: -.58,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                slide.$4,
                                style: TextStyle(
                                  fontSize: 10,
                                  color: AppColors.muted,
                                ),
                              ),
                              const SizedBox(height: 8),
                              SizedBox(
                                height: 30,
                                child: FilledButton(
                                  onPressed: () => nav.changePage(1),
                                  style: FilledButton.styleFrom(
                                    backgroundColor: AppColors.gold,
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 14,
                                    ),
                                  ),
                                  child: Text(
                                    'SHOP NOW',
                                    style: TextStyle(
                                      fontSize: 11,
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
                    _slides.length,
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
        ),
        const SizedBox(height: 12),
        Obx(() {
          final scheme = Get.find<SchemeController>();
          if (scheme.isLoading.value) return const SchemeCardShimmer();
          if (!scheme.hasJoined.value) return const SizedBox.shrink();
          return SchemeProgressCard(onOpenPlan: () => nav.changePage(2));
        }),
        Obx(() {
          final home = Get.find<HomeController>();
          final scheme = Get.find<SchemeController>();
          final shownId = scheme.hasJoined.value
              ? scheme.activeEnrollment?.enrollmentId
              : null;
          final fromHome = home.schemesRedeemable.toList();
          final fromScheme = scheme.enrollments
              .where((item) => item.isRedeemable && !item.isPast)
              .toList();
          if (home.isLoading.value && fromHome.isEmpty && fromScheme.isEmpty) {
            return const HomeSectionsShimmer();
          }
          final redeemable = (fromHome.isNotEmpty ? fromHome : fromScheme)
              .where((item) => item.enrollmentId != shownId)
              .toList();
          if (redeemable.isEmpty) return const SizedBox.shrink();
          return Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Column(
              children: [
                for (var i = 0; i < redeemable.length; i++) ...[
                  if (i > 0) const SizedBox(height: 8),
                  _RedeemableHomeCard(enrollment: redeemable[i]),
                ],
              ],
            ),
          );
        }),
        const SizedBox(height: 12),
        InkWell(
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
                              ?.copyWith(fontSize: 10),
                        ),
                      ],
                    ),
                  ),
                ),
                Image.asset(
                  'assets/images/design_01.webp',
                  width: 150,
                  height: double.infinity,
                  fit: BoxFit.cover,
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        Obx(() {
          if (shop.isLoading.value && shop.categoryTiles.isEmpty) {
            return const CategoryRowShimmer();
          }
          final tiles = shop.categoryTiles;
          if (tiles.isEmpty) return const SizedBox.shrink();
          return SizedBox(
            height: 70,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: tiles.length,
              itemBuilder: (_, index) {
                final category = tiles[index];
                return Padding(
                  padding: const EdgeInsets.only(right: 14),
                  child: InkWell(
                    onTap: () {
                      shop.chooseCategory(category.id);
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
                            child: ProductImage(
                              url: category.image,
                              width: 50,
                              height: 50,
                            ),
                          ),
                          const SizedBox(height: 5),
                          Text(
                            category.name,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontSize: 9),
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
        Obx(() {
          if (shop.isLoading.value && shop.newArrivals.isEmpty) {
            return const ProductRowShimmer();
          }
          final arrivals = shop.newArrivals.take(4).toList();
          if (arrivals.isEmpty) return const SizedBox.shrink();
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _sectionHeader(context, 'New Arrivals', () {
                shop.chooseCategory('All');
                nav.changePage(1);
              }),
              SizedBox(
                height: 220,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: arrivals.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 10),
                  itemBuilder: (_, index) =>
                      ProductCard(product: arrivals[index], width: 156),
                ),
              ),
            ],
          );
        }),
        Obx(() {
          if (shop.isLoading.value && shop.bestSellers.isEmpty) {
            return const ProductRowShimmer(height: 238);
          }
          final sellers = shop.bestSellers.take(4).toList();
          if (sellers.isEmpty) return const SizedBox.shrink();
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _sectionHeader(context, 'Best Sellers', () {
                shop.chooseCategory('All');
                nav.changePage(1);
              }),
              SizedBox(
                height: 238,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: sellers.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 10),
                  itemBuilder: (_, index) =>
                      ProductCard(product: sellers[index], width: 156),
                ),
              ),
            ],
          );
        }),
        Obx(() {
          if (shop.isLoading.value) return const SizedBox.shrink();
          if (shop.products.isNotEmpty ||
              shop.categoryTiles.isNotEmpty ||
              shop.newArrivals.isNotEmpty ||
              shop.bestSellers.isNotEmpty) {
            return const SizedBox.shrink();
          }
          return Padding(
            padding: const EdgeInsets.only(top: 8, bottom: 4),
            child: EmptyState(
              compact: true,
              title: 'No collections yet',
              message:
                  'New arrivals and curated jewellery will appear here as soon as they are added.',
              actionLabel: 'REFRESH',
              onAction: shop.loadCatalog,
            ),
          );
        }),
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

  // IconData _categoryIcon(String value) => switch (value) {
  //   'Necklaces' => Icons.workspace_premium_outlined,
  //   'Earrings' => Icons.diamond_outlined,
  //   'Rings' => Icons.circle_outlined,
  //   'Bangles' => Icons.blur_circular,
  //   _ => Icons.auto_awesome,
  // };
}

class _RedeemableHomeCard extends StatelessWidget {
  const _RedeemableHomeCard({required this.enrollment});

  final SchemeEnrollment enrollment;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Get.find<SchemeController>().selectEnrollment(enrollment);
        AppSheets.showRedemption();
      },
      borderRadius: BorderRadius.circular(13),
      child: Container(
        constraints: const BoxConstraints(minHeight: 88),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFFFF9ED), Color(0xFFF3DFB8)],
          ),
          borderRadius: BorderRadius.circular(13),
          border: Border.all(color: const Color(0xFFD6AF69)),
          boxShadow: const [
            BoxShadow(
              color: Color(0x0F8B5A14),
              blurRadius: 16,
              offset: Offset(0, 5),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              alignment: Alignment.center,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFFD39B3C), Color(0xFF8D5908)],
                ),
              ),
              child: const Text(
                '✓',
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
            ),
            const SizedBox(width: 11),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'READY TO REDEEM',
                    style: AppTypography.sans(
                      size: 8,
                      weight: FontWeight.w800,
                      color: AppColors.goldDark,
                      letterSpacing: .48,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    enrollment.planName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTypography.sans(
                      size: 11,
                      weight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    enrollment.enrollmentNumber.isEmpty
                        ? 'Fully paid'
                        : '${enrollment.enrollmentNumber} · fully paid',
                    style: AppTypography.sans(
                      size: 9,
                      color: AppColors.muted,
                    ),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  Money.fromPaise(
                    enrollment.redeemableBalancePaise > 0
                        ? enrollment.redeemableBalancePaise
                        : enrollment.savedPaise,
                  ),
                  style: AppTypography.sans(
                    size: 12,
                    weight: FontWeight.w700,
                    color: AppColors.goldDark,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Redeem now →',
                  style: AppTypography.sans(
                    size: 7,
                    weight: FontWeight.w700,
                    color: AppColors.goldDark,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
