import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';

import '../../controllers/auth_controller.dart';
import '../../controllers/home_controller.dart';
import '../../controllers/navigation_controller.dart';
import '../../controllers/shop_controller.dart';
import '../../core/constants/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/utils/money.dart';
import '../../data/models/activity.dart';
import '../../data/models/address.dart';
import '../widgets/delete_account_sheet.dart';
import '../widgets/history_sheets.dart';
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
          subtitleSize: 11,
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
                style: AppTypography.sans(size: 11, color: AppColors.muted),
              ),
            ],
          ),
        ),
        Obx(() {
          final auth = Get.find<AuthController>();
          final home = Get.find<HomeController>();
          final loading = auth.profileLoading.value ||
              (home.isLoading.value &&
                  auth.profile.value?.historySummary == null &&
                  home.historySummary.value == null);
          if (loading) {
            return const Padding(
              padding: EdgeInsets.only(top: 12),
              child: ProfilePageShimmer(),
            );
          }
          final summary = auth.profile.value?.historySummary ??
              home.historySummary.value;
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                child: _ProfileOverview(summary: summary),
              ),
              const SizedBox(height: 14),
              _profileMenu(summary),
            ],
          );
        }),
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
                    size: 11,
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
            return const AddressListShimmer();
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
                      size: 12,
                      weight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Add a delivery address to place jewellery orders.',
                    style: AppTypography.sans(
                      size: 10,
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
                size: 12,
                weight: FontWeight.w700,
                color: AppColors.goldDark,
              ),
            ),
          ),
        ),
        TextButton(
          onPressed: () {
            final auth = Get.find<AuthController>();
            showDeleteAccountSheet(
              phone: auth.accountPhone,
              lockPhone: auth.accountPhone != null,
            );
          },
          child: Text(
            'DELETE ACCOUNT',
            style: AppTypography.sans(
              size: 11,
              weight: FontWeight.w700,
              color: const Color(0xFF8A3B32),
            ),
          ),
        ),
      ],
    );
  }

  Widget _profileMenu(HistorySummary? summary) {
    final schemesCount = summary?.schemesTotal ??
        ((summary?.schemesInProgress ?? 0) +
            (summary?.schemesRedeemable ?? 0) +
            (summary?.schemesPast ?? 0));
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.line),
        borderRadius: BorderRadius.circular(13),
      ),
      child: Column(
        children: [
          _ProfileItem(
            svgAsset: 'assets/svg/scheme.svg',
            label: 'My Gold Schemes',
            subtitle: 'Active, redeemable and past plans',
            count: schemesCount,
            onTap: () => Get.find<NavigationController>().changePage(2),
          ),
          const Divider(color: AppColors.line, height: 1),
          _ProfileItem(
            svgAsset: 'assets/svg/orders.svg',
            label: 'All Transactions',
            subtitle: 'Scheme payments and jewellery orders together',
            onTap: showTransactionsSheet,
          ),
          const Divider(color: AppColors.line, height: 1),
          _ProfileItem(
            svgAsset: 'assets/svg/calendar.svg',
            label: 'Past Schemes',
            subtitle: 'Completed and redeemed scheme records',
            count: summary?.schemesPast ?? 0,
            onTap: showPastSchemesSheet,
          ),
          const Divider(color: AppColors.line, height: 1),
          _ProfileItem(
            svgAsset: 'assets/svg/diamond.svg',
            label: 'Redemption History',
            subtitle: 'Amounts, methods and reference numbers',
            count: summary?.redemptionsCount ?? 0,
            onTap: showRedemptionHistorySheet,
          ),
          const Divider(color: AppColors.line, height: 1),
          _ProfileItem(
            svgAsset: 'assets/svg/orders.svg',
            label: 'My Orders',
            subtitle: 'E-commerce purchases and delivery status',
            onTap: AppSheets.showOrders,
          ),
          const Divider(color: AppColors.line, height: 1),
          _ProfileItem(
            svgAsset: 'assets/svg/wishlist.svg',
            label: 'Saved Jewellery',
            subtitle: 'Your wishlist and favourite pieces',
            onTap: AppSheets.showWishlist,
          ),
          const Divider(color: AppColors.line, height: 1),
          _ProfileItem(
            svgAsset: 'assets/svg/help.svg',
            label: 'Help & Support',
            subtitle: 'Help with schemes, orders or redemption',
            onTap: () => _message('Wavoo support: +91 89251 62888'),
          ),
        ],
      ),
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
                style: AppTypography.sans(size: 12, weight: FontWeight.w800),
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
                      size: 8,
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
            style: AppTypography.sans(size: 11, weight: FontWeight.w700),
          ),
          const SizedBox(height: 4),
          Text(
            [
              if (address.streetLine.isNotEmpty) address.streetLine,
              if (address.localityLine.isNotEmpty) address.localityLine,
            ].join('\n'),
            style: AppTypography.sans(
              size: 10,
              color: AppColors.muted,
              height: 1.45,
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileOverview extends StatelessWidget {
  const _ProfileOverview({this.summary});

  final HistorySummary? summary;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFFFFDF9), Color(0xFFF8EDDD)],
        ),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.goldBorder),
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'LIFETIME SCHEME CONTRIBUTIONS',
                      style: AppTypography.sans(
                        size: 9,
                        weight: FontWeight.w800,
                        color: AppColors.muted,
                        letterSpacing: .72,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      Money.fromPaise(
                        summary?.lifetimeSchemeContributionsPaise ?? 0,
                      ),
                      style: AppTypography.serif(size: 24, height: 1),
                    ),
                  ],
                ),
              ),
              FilledButton(
                onPressed: showTransactionsSheet,
                style: FilledButton.styleFrom(
                  minimumSize: const Size(0, 34),
                  padding: const EdgeInsets.symmetric(horizontal: 11),
                  backgroundColor: AppColors.gold,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(7),
                  ),
                ),
                child: Text(
                  'VIEW ACTIVITY',
                  style: AppTypography.sans(
                    size: 9,
                    weight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 13),
          Row(
            children: [
              Expanded(
                child: _Metric(
                  value: '${summary?.schemesInProgress ?? 0}',
                  label: 'In progress',
                ),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: _Metric(
                  value: '${summary?.schemesRedeemable ?? 0}',
                  label: 'Ready to redeem',
                ),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: _Metric(
                  value: '${summary?.schemesPast ?? 0}',
                  label: 'Past schemes',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Metric extends StatelessWidget {
  const _Metric({required this.value, required this.label});

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 9),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(.7),
        borderRadius: BorderRadius.circular(9),
        border: Border.all(color: const Color(0x21B97911)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            value,
            style: AppTypography.sans(
              size: 14,
              weight: FontWeight.w700,
              color: AppColors.goldDark,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: AppTypography.sans(
              size: 9,
              color: AppColors.muted,
              height: 1.2,
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
    this.subtitle,
    this.count,
  });
  final String svgAsset;
  final String label;
  final String? subtitle;
  final int? count;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => InkWell(
        onTap: onTap,
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 60),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
            child: Row(
              children: [
                SvgPicture.asset(
                  svgAsset,
                  width: 20,
                  height: 20,
                  colorFilter: const ColorFilter.mode(
                    AppColors.goldDark,
                    BlendMode.srcIn,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        label,
                        style: AppTypography.sans(
                          size: 12,
                          weight: FontWeight.w700,
                        ),
                      ),
                      if (subtitle != null) ...[
                        const SizedBox(height: 3),
                        Text(
                          subtitle!,
                          style: AppTypography.sans(
                            size: 10,
                            color: AppColors.muted,
                            height: 1.3,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                if (count != null)
                  Container(
                    constraints: const BoxConstraints(minWidth: 22),
                    height: 22,
                    margin: const EdgeInsets.only(right: 8),
                    padding: const EdgeInsets.symmetric(horizontal: 5),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: AppColors.cream,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      '$count',
                      style: AppTypography.sans(
                        size: 9,
                        weight: FontWeight.w800,
                        color: AppColors.goldDark,
                      ),
                    ),
                  ),
                SvgPicture.asset(
                  'assets/svg/chevron-right-svgrepo-com.svg',
                  width: 13,
                  height: 13,
                  colorFilter: const ColorFilter.mode(
                    Color(0xFFA49B90),
                    BlendMode.srcIn,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
}
