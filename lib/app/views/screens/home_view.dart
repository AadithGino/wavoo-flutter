import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controllers/navigation_controller.dart';
import '../../controllers/shop_controller.dart';
import '../../core/constants/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../widgets/product_card.dart';
import '../widgets/scheme_progress_card.dart';

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
                                  fontSize: 9,
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
                                      fontSize: 9,
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
                        color: _slide == index
                            ? AppColors.gold
                            : Colors.white70,
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
        SchemeProgressCard(onOpenPlan: () => nav.changePage(2)),
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
                            fontSize: 9,
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
                          style: Theme.of(context).textTheme.bodySmall,
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
        SizedBox(
          height: 70,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: shop.categories
                .skip(1)
                .map(
                  (category) => Padding(
                    padding: const EdgeInsets.only(right: 14),
                    child: InkWell(
                      onTap: () {
                        shop.chooseCategory(category);
                        nav.changePage(1);
                      },
                      child: SizedBox(
                        width: 58,
                        child: Column(
                          children: [
                            // CircleAvatar(
                            //   radius: 23,
                            //   backgroundColor: AppColors.cream,
                            //   child: Icon(
                            //     _categoryIcon(category),
                            //     color: AppColors.goldDark,
                            //   ),
                            // ),
                            Container(
                              width: 50,
                              height: 50,
                              decoration: BoxDecoration(
                                image: DecorationImage(
                                  image: AssetImage(
                                    "assets/images/design_09.webp",
                                  ),
                                ),
                                border: Border.all(
                                  color: AppColors.gold.withOpacity(.4),
                                ),
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(height: 5),
                            Text(
                              category,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(fontSize: 9),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                )
                .toList(),
          ),
        ),
        _sectionHeader(context, 'New Arrivals', () {
          shop.chooseCategory('All');
          nav.changePage(1);
        }),
        SizedBox(
          height: 220,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: 4,
            separatorBuilder: (_, __) => const SizedBox(width: 10),
            itemBuilder: (_, index) =>
                ProductCard(product: shop.products[index], width: 156),
          ),
        ),
        _sectionHeader(context, 'Best Sellers', () {
          shop.chooseCategory('All');
          nav.changePage(1);
        }),
        SizedBox(
          height: 238,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: 4,
            separatorBuilder: (_, __) => const SizedBox(width: 10),
            itemBuilder: (_, index) =>
                ProductCard(product: shop.products[index + 4], width: 156),
          ),
        ),
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
                      fontSize: 9,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  Text(
                    'Special Offers',
                    style: AppTypography.serif(size: 20, color: Colors.white),
                  ),
                  Text(
                    'Up to 20% off on selected making charges',
                    style: TextStyle(color: Colors.white70, fontSize: 10),
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
  ) => Padding(
    padding: const EdgeInsets.only(top: 18, bottom: 10),
    child: Row(
      children: [
        Expanded(
          child: Text(title, style: Theme.of(context).textTheme.headlineSmall),
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
