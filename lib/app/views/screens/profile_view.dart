import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';

import '../../controllers/auth_controller.dart';
import '../../controllers/shop_controller.dart';
import '../../core/constants/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../data/models/address.dart';
import '../widgets/page_heading.dart';
import '../widgets/primary_button.dart';
import '../widgets/sheets.dart';
import '../widgets/shimmers.dart';

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
                child: Obx(() {
                  final auth = Get.find<AuthController>();
                  return Text(
                    auth.user.value?.initials ??
                        auth.profile.value?.initials ??
                        'W',
                    style: AppTypography.serif(size: 26, color: Colors.white),
                  );
                }),
              ),
              const SizedBox(height: 12),
              Obx(() {
                final auth = Get.find<AuthController>();
                final name = auth.profile.value?.displayName ??
                    auth.user.value?.name ??
                    'Guest';
                final first = name.trim().isEmpty
                    ? 'Guest'
                    : name.trim().split(RegExp(r'\s+')).first;
                return Text(
                  'Welcome, $first',
                  style: AppTypography.serif(size: 22, height: 1),
                );
              }),
              const SizedBox(height: 8),
              Text(
                'Gold Member',
                style: AppTypography.sans(size: 10, color: AppColors.muted),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 14, 8, 10),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  'Saved addresses',
                  style: AppTypography.serif(size: 18),
                ),
              ),
              TextButton(
                onPressed: AppSheets.showAddresses,
                child: Text(
                  'Manage',
                  style: AppTypography.sans(
                    size: 10,
                    weight: FontWeight.w700,
                    color: AppColors.goldDark,
                  ),
                ),
              ),
            ],
          ),
        ),
        Obx(() {
          if (shop.addressesLoading.value && shop.addresses.isEmpty) {
            return const AddressCardShimmer();
          }
          final addresses = shop.addresses;
          if (addresses.isEmpty) {
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
                    'No saved address',
                    style: AppTypography.sans(
                      size: 10,
                      weight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Add a delivery address to place jewellery orders.',
                    style: AppTypography.sans(
                      size: 8,
                      color: AppColors.muted,
                      height: 1.45,
                    ),
                  ),
                  const SizedBox(height: 12),
                  PrimaryButton(
                    label: 'ADD ADDRESS',
                    onPressed: AppSheets.showAddressForm,
                  ),
                ],
              ),
            );
          }
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              children: [
                for (var i = 0; i < addresses.length; i++) ...[
                  if (i > 0) const SizedBox(height: 10),
                  _ProfileAddressCard(address: addresses[i]),
                ],
              ],
            ),
          );
        }),
        const SizedBox(height: 14),
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.line),
            borderRadius: BorderRadius.circular(13),
          ),
          child: Column(
            children: [
              _ProfileItem(
                svgAsset: 'assets/svg/orders.svg',
                label: 'My Orders',
                onTap: AppSheets.showOrders,
              ),
              Divider(color: AppColors.line),
              _ProfileItem(
                svgAsset: 'assets/svg/wishlist.svg',
                label: 'Saved Jewellery',
                onTap: AppSheets.showWishlist,
              ),
              Divider(color: AppColors.line),
              _ProfileItem(
                svgAsset: 'assets/svg/scheme.svg',
                label: 'My Gold Scheme',
                onTap: AppSheets.showSchemeDetails,
              ),
              Divider(color: AppColors.line),
              _ProfileItem(
                svgAsset: 'assets/svg/calendar.svg',
                label: 'Appointments',
                onTap: () => _message('Appointment request started'),
              ),
              Divider(color: AppColors.line),
              _ProfileItem(
                svgAsset: 'assets/svg/help.svg',
                label: 'Help & Support',
                onTap: () => _message('Wavoo support: +91 98765 43210'),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: OutlinedButton(
            onPressed: () => _confirmLogout(),
            style: OutlinedButton.styleFrom(
              minimumSize: const Size.fromHeight(47),
              foregroundColor: AppColors.goldDark,
              side: const BorderSide(color: AppColors.goldBorder),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text(
              'LOG OUT',
              style: AppTypography.sans(
                size: 11,
                weight: FontWeight.w700,
                color: AppColors.goldDark,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _confirmLogout() async {
    final confirmed = await Get.dialog<bool>(
      AlertDialog(
        title: Text('Log out?', style: AppTypography.serif(size: 20)),
        content: Text(
          'You will be signed out and all local data on this device will be cleared.',
          style: AppTypography.sans(size: 12, color: AppColors.muted, height: 1.45),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: Text(
              'CANCEL',
              style: AppTypography.sans(
                size: 11,
                weight: FontWeight.w700,
                color: AppColors.muted,
              ),
            ),
          ),
          TextButton(
            onPressed: () => Get.back(result: true),
            child: Text(
              'LOG OUT',
              style: AppTypography.sans(
                size: 11,
                weight: FontWeight.w700,
                color: AppColors.goldDark,
              ),
            ),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await Get.find<AuthController>().logout();
    }
  }

  void _message(String value) => Get.showSnackbar(
        GetSnackBar(
          duration: const Duration(seconds: 2),
          snackPosition: SnackPosition.BOTTOM,
          margin: const EdgeInsets.fromLTRB(20, 0, 20, 88),
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 11),
          borderRadius: 20,
          backgroundColor: const Color(0xFF211D18),
          boxShadows: const [
            BoxShadow(
              color: Color(0x38000000),
              blurRadius: 30,
              offset: Offset(0, 8),
            ),
          ],
          messageText: Text(
            value,
            textAlign: TextAlign.center,
            style: AppTypography.sans(size: 10, color: Colors.white),
          ),
        ),
      );
}

class _ProfileAddressCard extends StatelessWidget {
  const _ProfileAddressCard({required this.address});

  final Address address;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: AppColors.line),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                address.label,
                style: AppTypography.sans(size: 10, weight: FontWeight.w800),
              ),
              if (address.isDefault) ...[
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 7,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.gold.withOpacity(.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    'DEFAULT',
                    style: AppTypography.sans(
                      size: 6,
                      weight: FontWeight.w800,
                      color: AppColors.goldDark,
                      letterSpacing: .48,
                    ),
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 6),
          Text(
            address.user,
            style: AppTypography.sans(size: 9, weight: FontWeight.w700),
          ),
          const SizedBox(height: 4),
          Text(
            [
              if (address.streetLine.isNotEmpty) address.streetLine,
              if (address.localityLine.isNotEmpty) address.localityLine,
            ].join('\n'),
            style: AppTypography.sans(
              size: 8,
              color: AppColors.muted,
              height: 1.45,
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileItem extends StatelessWidget {
  const _ProfileItem({
    required this.svgAsset,
    required this.label,
    required this.onTap,
  });
  final String svgAsset;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => InkWell(
        onTap: onTap,
        child: SizedBox(
          height: 49,
          child: Row(
            children: [
              const SizedBox(width: 15),
              SvgPicture.asset(
                svgAsset,
                width: 18,
                height: 18,
                colorFilter: const ColorFilter.mode(
                  AppColors.goldDark,
                  BlendMode.srcIn,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(child: Text(label, style: AppTypography.sans(size: 11))),
              SvgPicture.asset(
                'assets/svg/chevron-right-svgrepo-com.svg',
                width: 13,
                height: 13,
                colorFilter: const ColorFilter.mode(
                  Color(0xFFA49B90),
                  BlendMode.srcIn,
                ),
              ),
              const SizedBox(width: 15),
            ],
          ),
        ),
      );
}
