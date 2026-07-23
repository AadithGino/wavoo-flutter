import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';

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
                  style: TextStyle(fontSize: 19, fontWeight: FontWeight.w800),
                ),
              ),
              SizedBox(height: 10),
              Text(
                'Welcome, Aadith',
                style: TextStyle(fontSize: 23, fontWeight: FontWeight.w600),
              ),
              Text(
                'Gold Member',
                style: TextStyle(
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
                  style: TextStyle(fontWeight: FontWeight.w500, fontSize: 16),
                ),
              ),
              TextButton(
                onPressed: AppSheets.showAddresses,
                child: Text(
                  'Manage',
                  style: TextStyle(fontWeight: FontWeight.w500, fontSize: 16),
                ),
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
                // const Icon(Icons.home_outlined, color: AppColors.goldDark),
                // const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            address.label,
                            style: TextStyle(fontWeight: FontWeight.w800),
                          ),
                          SizedBox(width: 10),
                          address.isDefault
                              ? Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppColors.goldSoft.withOpacity(.3),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    "DEFAULT",
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w800,
                                      color: AppColors.goldDark,
                                    ),
                                  ),
                                )
                              : SizedBox.shrink(),
                        ],
                      ),
                      SizedBox(height: 4),
                      Text(
                        address.user,
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                      Text(
                        address.lines,
                        style: TextStyle(color: AppColors.muted, fontSize: 11),
                      ),
                    ],
                  ),
                ),
                // const Chip(label: Text('Default')),
              ],
            ),
          );
        }),
        const SizedBox(height: 18),
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          // padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.line),
            borderRadius: BorderRadius.circular(13),
          ),
          child: Column(
            children: [
              _ProfileItem(
                icon: Icons.shopping_bag_outlined,
                label: 'My Orders',
                onTap: AppSheets.showOrders,
              ),
              Divider(color: AppColors.line),
              _ProfileItem(
                icon: Icons.favorite_border,
                label: 'Saved Jewellery',
                onTap: AppSheets.showWishlist,
              ),
              Divider(color: AppColors.line),
              _ProfileItem(
                icon: Icons.savings_outlined,
                label: 'My Gold Scheme',
                onTap: AppSheets.showSchemePayment,
              ),
              Divider(color: AppColors.line),
              _ProfileItem(
                icon: Icons.calendar_month_outlined,
                label: 'Appointments',
                onTap: () => _message('No upcoming appointments.'),
              ),
              Divider(color: AppColors.line),
              _ProfileItem(
                icon: Icons.help_outline,
                label: 'Help & Support',
                onTap: () =>
                    _message('Our support team will be happy to help.'),
              ),
            ],
          ),
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
    contentPadding: const EdgeInsets.symmetric(horizontal: 16),
    leading: Icon(icon, color: AppColors.goldDark),
    title: Text(label, style: TextStyle(fontWeight: FontWeight.w300)),
    trailing: SvgPicture.asset("assets/svg/chevron-right-svgrepo-com.svg"),
    onTap: onTap,
  );
}
