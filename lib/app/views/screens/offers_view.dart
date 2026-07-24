import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controllers/navigation_controller.dart';
import '../../core/constants/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../widgets/page_heading.dart';

class OffersView extends StatelessWidget {
  const OffersView({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.only(bottom: 24),
      children: [
        const PageHeading(
          title: 'Offers',
          subtitle: 'Curated privileges for you',
        ),
        _OfferTile(
          height: 156,
          image: 'assets/images/design_08.webp',
          tag: '✦ FESTIVE SEASON',
          title: 'Festive Gold Edit',
          text:
              'Save up to 20% on selected making charges across necklaces, rings and more.',
          button: 'SHOP THE EDIT',
          onTap: () => Get.find<NavigationController>().changePage(1),
        ),
        _OfferTile(
          height: 132,
          tag: '✦ BY APPOINTMENT',
          title: 'Bridal Privilege',
          text:
              'Book a private styling session and unlock exclusive bridal benefits.',
          button: 'BOOK NOW',
          onTap: () =>
              _message('Your private styling request has been received.'),
          color: AppColors.ivory,
          dark: false,
        ),
        _OfferTile(
          height: 132,
          tag: '✦ MEMBERS ONLY',
          title: 'Golden Rewards',
          text: 'Earn double points every time you shop with Wavoo Jewellers.',
          button: 'JOIN FREE',
          onTap: () => _message('Welcome to Golden Rewards!'),
          color: const Color(0xFFFFF9F0),
          dark: false,
        ),
      ],
    );
  }

  void _message(String message) => Get.showSnackbar(
    GetSnackBar(
      message: message,
      duration: const Duration(seconds: 2),
      margin: const EdgeInsets.all(16),
      borderRadius: 12,
    ),
  );
}

class _OfferTile extends StatelessWidget {
  const _OfferTile({
    required this.tag,
    required this.title,
    required this.text,
    required this.button,
    required this.onTap,
    this.image,
    this.height = 190,
    this.color = AppColors.goldDark,
    this.dark = true,
  });
  final String tag;
  final String title;
  final String text;
  final String button;
  final VoidCallback onTap;
  final String? image;
  final double height;
  final Color color;
  final bool dark;

  @override
  Widget build(BuildContext context) => Container(
    height: height,
    margin: const EdgeInsets.fromLTRB(16, 0, 16, 14),
    decoration: BoxDecoration(
      color: color,
      borderRadius: BorderRadius.circular(16),
      border: dark ? null : Border.all(color: const Color(0xFFEADBC4)),
      image: image == null
          ? null
          : DecorationImage(image: AssetImage(image!), fit: BoxFit.cover),
    ),
    clipBehavior: Clip.antiAlias,
    child: Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: dark
            ? const LinearGradient(
                colors: [Color(0xF71F1812), Color(0x473F2A0D)],
              )
            : const LinearGradient(
                colors: [Color(0xFFFFFDF9), Color(0xB8FFF9F0)],
              ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            tag,
            style: TextStyle(
              color: dark ? const Color(0xFFFFE5A8) : AppColors.goldDark,
              fontSize: 7,
              fontWeight: FontWeight.w900,
              letterSpacing: 1.1,
            ),
          ),
          const SizedBox(height: 7),
          Text(
            title,
            style: AppTypography.serif(
              size: 24,
              color: dark ? Colors.white : AppColors.ink,
              height: 1.05,
              letterSpacing: -.48,
            ),
          ),
          const SizedBox(height: 7),
          SizedBox(
            width: 270,
            child: Text(
              text,
              style: TextStyle(
                color: dark ? Colors.white70 : AppColors.muted,
                fontSize: 9,
                height: 1.5,
              ),
            ),
          ),
          const SizedBox(height: 14),
          TextButton.icon(
            onPressed: onTap,
            style: TextButton.styleFrom(
              foregroundColor:
                  dark ? const Color(0xFFFFE5A8) : AppColors.goldDark,
              padding: EdgeInsets.zero,
            ),
            label: Text(
              button,
              style: TextStyle(fontSize: 9, fontWeight: FontWeight.w700),
            ),
            icon: const Icon(Icons.arrow_forward, size: 17),
          ),
        ],
      ),
    ),
  );
}
