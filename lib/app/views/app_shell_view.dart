import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';

import '../controllers/navigation_controller.dart';
import '../controllers/shop_controller.dart';
import '../core/constants/app_colors.dart';
import '../core/theme/app_typography.dart';
import 'screens/catalog_view.dart';
import 'screens/home_view.dart';
import 'screens/offers_view.dart';
import 'screens/profile_view.dart';
import 'screens/schemes_view.dart';
import 'widgets/sheets.dart';

class AppShellView extends GetView<NavigationController> {
  const AppShellView({super.key});

  static const _pages = [
    HomeView(),
    CatalogView(),
    SchemesView(),
    OffersView(),
    ProfileView(),
  ];

  @override
  Widget build(BuildContext context) {
    final shop = Get.find<ShopController>();
    return Scaffold(
      drawer: _AppDrawer(
        onNavigate: (index) {
          Navigator.of(context).pop();
          controller.changePage(index);
        },
      ),
      appBar: AppBar(
        toolbarHeight: 88,
        centerTitle: true,
        leading: Builder(
          builder: (context) => IconButton(
            tooltip: 'Open menu',
            onPressed: Scaffold.of(context).openDrawer,
            icon: const Icon(Icons.menu),
          ),
        ),
        title: Image.asset(
          'assets/images/logo.png',
          width: 96,
          height: 88,
          fit: BoxFit.contain,
        ),
        actions: [
          IconButton(
            tooltip: 'Search',
            onPressed: AppSheets.showSearch,
            icon: SvgPicture.asset(
              "assets/svg/search.svg",
              color: AppColors.goldDark,
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 7),
            child: Obx(
              () => Badge(
                isLabelVisible: shop.cartCount > 0,
                label: Text('${shop.cartCount}'),
                backgroundColor: AppColors.gold,
                child: SvgPicture.asset(
                  "assets/svg/shopping-bag.svg",
                  color: AppColors.goldDark,
                ),
              ),
            ),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(1),
          child: Divider(height: 1, color: Colors.grey.withOpacity(.4)),
        ),
      ),
      body: Obx(
        () => IndexedStack(
          index: controller.currentIndex.value,
          children: _pages,
        ),
      ),
      bottomNavigationBar: Obx(
        () => NavigationBar(
          height: 72,
          selectedIndex: controller.currentIndex.value,
          onDestinationSelected: controller.changePage,
          backgroundColor: AppColors.ivory,
          indicatorColor: Colors.white,
          labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
          destinations: [
            NavigationDestination(
              icon: SvgPicture.asset("assets/svg/home.svg"),
              selectedIcon: SvgPicture.asset(
                "assets/svg/home-selected.svg",
                color: AppColors.gold,
              ),
              label: 'Home',
            ),
            NavigationDestination(
              icon: SvgPicture.asset("assets/svg/category.svg"),
              selectedIcon: SvgPicture.asset(
                "assets/svg/category.svg",
                color: AppColors.gold,
              ),
              label: 'Categories',
            ),
            NavigationDestination(
              icon: SvgPicture.asset(
                'assets/svg/scheme.svg',
                width: 24,
                height: 24,
                colorFilter: const ColorFilter.mode(
                  AppColors.muted,
                  BlendMode.srcIn,
                ),
              ),
              selectedIcon: SvgPicture.asset(
                'assets/svg/scheme.svg',
                width: 24,
                height: 24,
                colorFilter: const ColorFilter.mode(
                  AppColors.gold,
                  BlendMode.srcIn,
                ),
              ),
              label: 'Schemes',
            ),
            NavigationDestination(
              icon: SvgPicture.asset("assets/svg/offer.svg"),
              selectedIcon: SvgPicture.asset(
                "assets/svg/offer.svg",
                color: AppColors.gold,
              ),
              label: 'Offers',
            ),
            NavigationDestination(
              icon: SvgPicture.asset("assets/svg/profile.svg"),
              selectedIcon: SvgPicture.asset(
                "assets/svg/profile.svg",
                color: AppColors.gold,
              ),
              label: 'Profile',
            ),
          ],
        ),
      ),
    );
  }
}

class _AppDrawer extends StatelessWidget {
  const _AppDrawer({required this.onNavigate});

  final ValueChanged<int> onNavigate;

  @override
  Widget build(BuildContext context) {
    final shop = Get.find<ShopController>();
    return Drawer(
      width: (MediaQuery.sizeOf(context).width * .84)
          .clamp(0.0, 340.0)
          .toDouble(),
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.zero,
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(18, 12, 18, 27),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(4, 0, 0, 12),
                child: Row(
                  children: [
                    Image.asset(
                      'assets/images/logo.png',
                      width: 96,
                      height: 96,
                    ),
                    const Spacer(),
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: SvgPicture.asset(
                        'assets/svg/close.svg',
                        width: 20,
                        height: 20,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView(
                  padding: EdgeInsets.zero,
                  children: [
                    _DrawerLink(
                      svgAsset: 'assets/svg/home.svg',
                      label: 'Home',
                      onTap: () => onNavigate(0),
                    ),
                    _DrawerLink(
                      svgAsset: 'assets/svg/explore.svg',
                      label: 'Explore Collections',
                      onTap: () => onNavigate(1),
                    ),
                    _DrawerLink(
                      svgAsset: 'assets/svg/scheme.svg',
                      label: 'Gold Savings Scheme',
                      onTap: () => onNavigate(2),
                    ),
                    _DrawerLink(
                      svgAsset: 'assets/svg/offer.svg',
                      label: 'Offers & Privileges',
                      onTap: () => onNavigate(3),
                    ),
                    Obx(
                      () => _DrawerLink(
                        svgAsset: 'assets/svg/wishlist.svg',
                        label: 'Saved Jewellery',
                        badge: shop.wishlist.length,
                        onTap: () {
                          Navigator.of(context).pop();
                          AppSheets.showWishlist();
                        },
                      ),
                    ),
                    _DrawerLink(
                      svgAsset: 'assets/svg/location.svg',
                      label: 'Find a Store',
                      onTap: () => _notice(
                        context,
                        'Nearest Wavoo showroom: 2.4 km',
                      ),
                    ),
                    _DrawerLink(
                      svgAsset: 'assets/svg/phone.svg',
                      label: 'Contact Wavoo',
                      onTap: () => _notice(
                        context,
                        'Wavoo support: +91 98765 43210',
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(17),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFFB97911), Color(0xFF845005)],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Private jewellery styling',
                      style: AppTypography.serif(
                        size: 18,
                        color: Colors.white,
                        height: 1.1,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Book a one-to-one consultation with our experts.',
                      style: AppTypography.sans(
                        size: 9,
                        color: Colors.white.withOpacity(.82),
                      ),
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

  void _notice(BuildContext context, String message) {
    Navigator.of(context).pop();
    Get.showSnackbar(
      GetSnackBar(
        message: message,
        duration: const Duration(seconds: 2),
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.fromLTRB(20, 0, 20, 88),
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 11),
        borderRadius: 20,
        backgroundColor: const Color(0xFF211D18),
      ),
    );
  }
}

class _DrawerLink extends StatelessWidget {
  const _DrawerLink({
    required this.svgAsset,
    required this.label,
    required this.onTap,
    this.badge = 0,
  });
  final String svgAsset;
  final String label;
  final VoidCallback onTap;
  final int badge;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 5),
    child: Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(9),
      child: InkWell(
        borderRadius: BorderRadius.circular(9),
        onTap: onTap,
        child: SizedBox(
          height: 49,
          child: Row(
            children: [
              const SizedBox(width: 12),
              SvgPicture.asset(
                svgAsset,
                width: 19,
                height: 19,
                colorFilter: const ColorFilter.mode(
                  AppColors.goldDark,
                  BlendMode.srcIn,
                ),
              ),
              const SizedBox(width: 13),
              Expanded(
                child: Text(label, style: AppTypography.sans(size: 12)),
              ),
              if (badge > 0)
                Container(
                  constraints: const BoxConstraints(minWidth: 20),
                  height: 20,
                  alignment: Alignment.center,
                  padding: const EdgeInsets.symmetric(horizontal: 5),
                  decoration: const BoxDecoration(
                    color: AppColors.gold,
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    '$badge',
                    style: AppTypography.sans(size: 9, color: Colors.white),
                  ),
                )
              else
                SvgPicture.asset(
                  'assets/svg/chevron-right-svgrepo-com.svg',
                  width: 13,
                  height: 13,
                ),
              const SizedBox(width: 12),
            ],
          ),
        ),
      ),
    ),
  );
}
