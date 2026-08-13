import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';

import '../../controllers/auth_controller.dart';
import '../../controllers/navigation_controller.dart';
import '../../controllers/shop_controller.dart';
import '../../core/constants/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/utils/phone.dart';
import '../sheets/app_sheets.dart';
import '../widgets/page_heading.dart';

class ProfileView extends StatelessWidget {
  const ProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    final shop = Get.find<ShopController>();
    final auth = Get.find<AuthController>();
    final nav = Get.find<NavigationController>();

    return ListView(
      padding: const EdgeInsets.only(bottom: 24),
      children: [
        const PageHeading(
          title: 'My Wavoo',
          subtitle: 'Your jewellery, orders and privileges',
        ),
        Obx(() {
          final profile = auth.profile.value;
          final user = auth.user.value;
          final name = profile?.displayName ??
              ((user?.name.isNotEmpty ?? false) ? user!.name : 'Guest');
          final initials = profile?.initials ?? user?.initials ?? 'W';
          final phone = PhoneUtils.display(profile?.phone ?? user?.phone);
          final kyc = profile?.kycStatus;

          return Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 25),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Colors.white, Color(0xFFFBF2E5)],
              ),
              border: Border.all(color: AppColors.line),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                Container(
                  width: 72,
                  height: 72,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [Color(0xFFCF9638), Color(0xFF9A5A04)],
                    ),
                    border: Border.all(color: const Color(0xFFF7E8CF), width: 5),
                  ),
                  child: Text(
                    initials,
                    style: AppTypography.serif(size: 26, color: Colors.white),
                  ),
                ),
                const SizedBox(height: 12),
                Text('Welcome, $name', style: AppTypography.serif(size: 22, height: 1)),
                const SizedBox(height: 8),
                Text(
                  phone.isEmpty ? 'Gold Member' : phone,
                  style: AppTypography.sans(size: 13, color: AppColors.muted),
                ),
                if (kyc != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    'KYC: $kyc',
                    style: AppTypography.sans(size: 12, color: AppColors.goldDark),
                  ),
                ],
              ],
            ),
          );
        }),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 14, 8, 10),
          child: Row(
            children: [
              Expanded(
                child: Text('Saved addresses', style: AppTypography.serif(size: 18)),
              ),
              TextButton(
                onPressed: AppSheets.showAddresses,
                child: Text(
                  'Manage',
                  style: AppTypography.sans(
                    size: 12,
                    weight: FontWeight.w700,
                    color: AppColors.goldDark,
                  ),
                ),
              ),
            ],
          ),
        ),
        Obx(() {
          final address = shop.defaultAddress;
          if (address == null) {
            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: AppColors.line),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text('No default address yet.'),
            );
          }
          return Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: AppColors.line),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  address.label,
                  style: AppTypography.sans(size: 13, weight: FontWeight.w800),
                ),
                const SizedBox(height: 6),
                Text(address.lines, style: AppTypography.sans(size: 13, color: AppColors.muted)),
              ],
            ),
          );
        }),
        const SizedBox(height: 16),
        _ProfileTile(
          icon: 'assets/svg/orders.svg',
          title: 'My Orders',
          onTap: AppSheets.showOrders,
          fallbackIcon: Icons.receipt_long_outlined,
        ),
        _ProfileTile(
          icon: 'assets/svg/wishlist.svg',
          title: 'Saved Jewellery',
          onTap: AppSheets.showWishlist,
          fallbackIcon: Icons.favorite_border,
        ),
        _ProfileTile(
          icon: 'assets/svg/scheme.svg',
          title: 'My Gold Scheme',
          onTap: () => nav.changePage(2),
          fallbackIcon: Icons.savings_outlined,
        ),
        _ProfileTile(
          icon: 'assets/svg/help.svg',
          title: 'Help & Support',
          onTap: AppSheets.showContactWavoo,
          fallbackIcon: Icons.help_outline,
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
          child: OutlinedButton(
            onPressed: auth.logout,
            style: OutlinedButton.styleFrom(
              minimumSize: const Size.fromHeight(48),
              foregroundColor: Colors.red.shade700,
            ),
            child: const Text('Log out'),
          ),
        ),
      ],
    );
  }
}

class _ProfileTile extends StatelessWidget {
  const _ProfileTile({
    required this.icon,
    required this.title,
    required this.onTap,
    this.fallbackIcon,
  });

  final String icon;
  final String title;
  final VoidCallback onTap;
  final IconData? fallbackIcon;

  @override
  Widget build(BuildContext context) {
    Widget leading;
    try {
      leading = SvgPicture.asset(
        icon,
        width: 22,
        height: 22,
        colorFilter: const ColorFilter.mode(AppColors.goldDark, BlendMode.srcIn),
      );
    } catch (_) {
      leading = Icon(fallbackIcon ?? Icons.circle_outlined, color: AppColors.goldDark);
    }
    return ListTile(
      onTap: onTap,
      leading: leading,
      title: Text(title, style: AppTypography.sans(size: 14, weight: FontWeight.w600)),
      trailing: const Icon(Icons.chevron_right),
    );
  }
}
