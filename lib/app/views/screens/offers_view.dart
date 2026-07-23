import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../controllers/navigation_controller.dart';
import '../../core/constants/app_colors.dart';
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
          height: 195,
          image: 'assets/images/design_08.webp',
          tag: '✦ FESTIVE SEASON',
          title: 'Festive Gold Edit',
          text:
              'Save up to 20% on selected making charges across necklaces, rings and more.',
          button: 'SHOP THE EDIT',
          onTap: () => Get.find<NavigationController>().changePage(1),
        ),
        _OfferTile(
          height: 195,
          tag: '✦ BY APPOINTMENT',
          title: 'Bridal Privilege',
          text:
              'Book a private styling session and unlock exclusive bridal benefits.',
          button: 'BOOK NOW',
          onTap: () =>
              _message('Your private styling request has been received.'),
          color: const Color(0xFF442016),
        ),
        _OfferTile(
          height: 195,
          tag: '✦ MEMBERS ONLY',
          title: 'Golden Rewards',
          text: 'Earn double points every time you shop with Wavoo Jewellers.',
          button: 'JOIN FREE',
          onTap: () => _message('Welcome to Golden Rewards!'),
          color: const Color(0xFF283124),
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
  });
  final String tag;
  final String title;
  final String text;
  final String button;
  final VoidCallback onTap;
  final String? image;
  final double height;
  final Color color;

  @override
  Widget build(BuildContext context) => Container(
    height: height,
    margin: const EdgeInsets.fromLTRB(16, 0, 16, 14),
    decoration: BoxDecoration(
      color: color,
      borderRadius: BorderRadius.circular(18),
      image: image == null
          ? null
          : DecorationImage(image: AssetImage(image!), fit: BoxFit.cover),
    ),
    clipBehavior: Clip.antiAlias,
    child: Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xDC100A05), Color(0x42100A05)],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            tag,
            style: GoogleFonts.notoSerif(
              color: AppColors.goldSoft,
              fontSize: 9,
              fontWeight: FontWeight.w900,
              letterSpacing: 1.1,
            ),
          ),
          const SizedBox(height: 7),
          Text(
            title,
            style: GoogleFonts.notoSerif(
              color: Colors.white,
              fontSize: 26,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 7),
          SizedBox(
            width: 270,
            child: Text(
              text,
              style: GoogleFonts.notoSerif(color: Colors.white70, height: 1.35),
            ),
          ),
          const SizedBox(height: 14),
          TextButton.icon(
            onPressed: onTap,
            style: TextButton.styleFrom(
              foregroundColor: Colors.white,
              padding: EdgeInsets.zero,
            ),
            label: Text(
              button,
              style: GoogleFonts.notoSerif(
                fontSize: 10,
                fontWeight: FontWeight.w900,
              ),
            ),
            icon: const Icon(Icons.arrow_forward, size: 17),
          ),
        ],
      ),
    ),
  );
}
