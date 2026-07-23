import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import '../controllers/navigation_controller.dart';
import '../controllers/shop_controller.dart';
import '../core/constants/app_colors.dart';
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
        toolbarHeight: 76,
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
          width: 76,
          height: 66,
          fit: BoxFit.contain,
        ),
        actions: [
          IconButton(
            tooltip: 'Search',
            onPressed: AppSheets.showSearch,
            icon: const Icon(Icons.search),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 7),
            child: Obx(
              () => Badge(
                isLabelVisible: shop.cartCount > 0,
                label: Text('${shop.cartCount}'),
                backgroundColor: AppColors.gold,
                child: IconButton(
                  tooltip: 'Shopping bag',
                  onPressed: AppSheets.showCart,
                  icon: const Icon(Icons.shopping_bag_outlined),
                ),
              ),
            ),
          ),
        ],
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(1),
          child: Divider(height: 1),
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
          indicatorColor: AppColors.cream2,
          labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.home_outlined),
              selectedIcon: Icon(Icons.home),
              label: 'Home',
            ),
            NavigationDestination(
              icon: Icon(Icons.grid_view_outlined),
              selectedIcon: Icon(Icons.grid_view),
              label: 'Categories',
            ),
            NavigationDestination(
              icon: Icon(Icons.savings_outlined),
              selectedIcon: Icon(Icons.savings),
              label: 'Schemes',
            ),
            NavigationDestination(
              icon: Icon(Icons.local_offer_outlined),
              selectedIcon: Icon(Icons.local_offer),
              label: 'Offers',
            ),
            NavigationDestination(
              icon: Icon(Icons.person_outline),
              selectedIcon: Icon(Icons.person),
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
      backgroundColor: AppColors.ivory,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.horizontal(right: Radius.circular(24)),
      ),
      child: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 4, 8, 2),
              child: Row(
                children: [
                  Image.asset('assets/images/logo.png', width: 88, height: 78),
                  const Spacer(),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
            ),
            const Divider(),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(vertical: 8),
                children: [
                  _DrawerLink(
                    icon: Icons.home_outlined,
                    label: 'Home',
                    onTap: () => onNavigate(0),
                  ),
                  _DrawerLink(
                    icon: Icons.explore_outlined,
                    label: 'Explore Collections',
                    onTap: () => onNavigate(1),
                  ),
                  _DrawerLink(
                    icon: Icons.savings_outlined,
                    label: 'Gold Savings Scheme',
                    onTap: () => onNavigate(2),
                  ),
                  _DrawerLink(
                    icon: Icons.local_offer_outlined,
                    label: 'Offers & Privileges',
                    onTap: () => onNavigate(3),
                  ),
                  Obx(
                    () => _DrawerLink(
                      icon: Icons.favorite_border,
                      label: 'Saved Jewellery',
                      badge: shop.wishlist.length,
                      onTap: () {
                        Navigator.of(context).pop();
                        AppSheets.showWishlist();
                      },
                    ),
                  ),
                  _DrawerLink(
                    icon: Icons.location_on_outlined,
                    label: 'Find a Store',
                    onTap: () => _notice(
                      context,
                      'Store finder is ready for your location service integration.',
                    ),
                  ),
                  _DrawerLink(
                    icon: Icons.phone_outlined,
                    label: 'Contact Wavoo',
                    onTap: () => _notice(context, 'Support request opened.'),
                  ),
                ],
              ),
            ),
            Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppColors.cream2, AppColors.cream],
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Private jewellery styling',
                    style: GoogleFonts.notoSerif(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 5),
                  Text(
                    'Book a one-to-one consultation with our experts.',
                    style: GoogleFonts.notoSerif(
                      color: AppColors.muted,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
          ],
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
        margin: const EdgeInsets.all(16),
        borderRadius: 12,
      ),
    );
  }
}

class _DrawerLink extends StatelessWidget {
  const _DrawerLink({
    required this.icon,
    required this.label,
    required this.onTap,
    this.badge = 0,
  });
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final int badge;

  @override
  Widget build(BuildContext context) => ListTile(
    contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 2),
    leading: Icon(icon, color: AppColors.goldDark),
    title: Text(
      label,
      style: GoogleFonts.notoSerif(fontWeight: FontWeight.w600),
    ),
    trailing: badge > 0
        ? CircleAvatar(
            radius: 10,
            backgroundColor: AppColors.gold,
            foregroundColor: Colors.white,
            child: Text('$badge', style: GoogleFonts.notoSerif(fontSize: 9)),
          )
        : const Icon(Icons.chevron_right, size: 19),
    onTap: onTap,
  );
}
