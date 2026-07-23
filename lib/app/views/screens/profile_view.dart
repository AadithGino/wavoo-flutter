import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../controllers/shop_controller.dart';
import '../../core/constants/app_colors.dart';
import '../widgets/page_heading.dart';
import '../widgets/sheets.dart';

class ProfileView extends StatelessWidget {
  const ProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    final shop = Get.find<ShopController>();
    return ListView(
      padding: const EdgeInsets.only(bottom: 24),
      children: [
        const PageHeading(
          title: 'My Wavoo',
          subtitle: 'Your jewellery, orders and privileges',
        ),
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppColors.cream,
            borderRadius: BorderRadius.circular(18),
          ),
          child: Column(
            children: [
              CircleAvatar(
                radius: 32,
                backgroundColor: AppColors.gold,
                foregroundColor: Colors.white,
                child: Text(
                  'AG',
                  style: GoogleFonts.notoSerif(
                    fontSize: 19,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              SizedBox(height: 10),
              Text(
                'Welcome, Aadith',
                style: GoogleFonts.notoSerif(
                  fontSize: 23,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                'Gold Member',
                style: GoogleFonts.notoSerif(
                  color: AppColors.goldDark,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 22, 8, 6),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  'Saved addresses',
                  style: GoogleFonts.notoSerif(fontWeight: FontWeight.w800),
                ),
              ),
              TextButton(
                onPressed: AppSheets.showAddresses,
                child: const Text('Manage'),
              ),
            ],
          ),
        ),
        Obx(() {
          final address = shop.addresses.firstWhere((item) => item.isDefault);
          return Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.line),
              borderRadius: BorderRadius.circular(13),
            ),
            child: Row(
              children: [
                const Icon(Icons.home_outlined, color: AppColors.goldDark),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        address.label,
                        style: GoogleFonts.notoSerif(
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      Text(
                        address.lines,
                        style: GoogleFonts.notoSerif(
                          color: AppColors.muted,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
                const Chip(label: Text('Default')),
              ],
            ),
          );
        }),
        const SizedBox(height: 18),
        _ProfileItem(
          icon: Icons.shopping_bag_outlined,
          label: 'My Orders',
          onTap: AppSheets.showOrders,
        ),
        _ProfileItem(
          icon: Icons.favorite_border,
          label: 'Saved Jewellery',
          onTap: AppSheets.showWishlist,
        ),
        _ProfileItem(
          icon: Icons.savings_outlined,
          label: 'My Gold Scheme',
          onTap: AppSheets.showSchemePayment,
        ),
        _ProfileItem(
          icon: Icons.calendar_month_outlined,
          label: 'Appointments',
          onTap: () => _message('No upcoming appointments.'),
        ),
        _ProfileItem(
          icon: Icons.help_outline,
          label: 'Help & Support',
          onTap: () => _message('Our support team will be happy to help.'),
        ),
      ],
    );
  }

  void _message(String value) => Get.showSnackbar(
    GetSnackBar(
      message: value,
      duration: const Duration(seconds: 2),
      margin: const EdgeInsets.all(16),
      borderRadius: 12,
    ),
  );
}

class _ProfileItem extends StatelessWidget {
  const _ProfileItem({
    required this.icon,
    required this.label,
    required this.onTap,
  });
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => ListTile(
    contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 3),
    leading: Icon(icon, color: AppColors.goldDark),
    title: Text(
      label,
      style: GoogleFonts.notoSerif(fontWeight: FontWeight.w600),
    ),
    trailing: const Icon(Icons.chevron_right),
    onTap: onTap,
  );
}
