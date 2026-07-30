import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';

import '../../controllers/shop_controller.dart';
import '../../core/constants/app_colors.dart';
import '../../core/theme/app_typography.dart';
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
                  'AG',
                  style: AppTypography.serif(size: 26, color: Colors.white),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Welcome, Aadith',
                style: AppTypography.serif(size: 22, height: 1),
              ),
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
          final address = shop.addresses.firstWhere((item) => item.isDefault);
          return Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: AppColors.line),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            address.label,
                            style: AppTypography.sans(
                              size: 10,
                              weight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(width: 8),
                          address.isDefault
                              ? Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 7,
                                    vertical: 3,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppColors.goldSoft.withOpacity(.3),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Text(
                                    "DEFAULT",
                                    style: AppTypography.sans(
                                      size: 8,
                                      weight: FontWeight.w800,
                                      color: AppColors.goldDark,
                                      letterSpacing: .48,
                                    ),
                                  ),
                                )
                              : const SizedBox.shrink(),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        address.user,
                        style: AppTypography.sans(
                          size: 10,
                          weight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        address.lines,
                        style: AppTypography.sans(
                          size: 9,
                          color: AppColors.muted,
                          height: 1.45,
                        ),
                      ),
                    ],
                  ),
                ),
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
      ],
    );
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
