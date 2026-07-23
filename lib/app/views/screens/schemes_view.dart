import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../controllers/scheme_controller.dart';
import '../../core/constants/app_colors.dart';
import '../widgets/page_heading.dart';
import '../widgets/primary_button.dart';
import '../widgets/sheets.dart';

class SchemesView extends StatelessWidget {
  const SchemesView({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = Get.find<SchemeController>();
    return Obx(
      () => ListView(
        padding: const EdgeInsets.only(bottom: 24),
        children: [
          const PageHeading(
            title: 'Gold Schemes',
            subtitle: 'Save monthly, redeem with pride',
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppColors.goldDark, AppColors.gold],
                ),
                borderRadius: BorderRadius.circular(18),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x332A1700),
                    blurRadius: 24,
                    offset: Offset(0, 12),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'WAVOO GOLD SAVINGS',
                        style: GoogleFonts.notoSerif(
                          color: AppColors.goldSoft,
                          fontSize: 10,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1.2,
                        ),
                      ),
                      Icon(Icons.auto_awesome, color: AppColors.goldSoft),
                    ],
                  ),
                  const SizedBox(height: 22),
                  Text(
                    'Your savings',
                    style: GoogleFonts.notoSerif(color: Colors.white70),
                  ),
                  Text(
                    '₹${scheme.savedAmount}',
                    style: GoogleFonts.notoSerif(
                      color: Colors.white,
                      fontSize: 35,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 18),
                  LinearProgressIndicator(
                    value: scheme.progress,
                    minHeight: 8,
                    borderRadius: BorderRadius.circular(8),
                    color: AppColors.goldSoft,
                    backgroundColor: Colors.white24,
                  ),
                  SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${scheme.paidInstallments.value} of ${scheme.totalInstallments} instalments',
                        style: GoogleFonts.notoSerif(
                          color: Colors.white70,
                          fontSize: 11,
                        ),
                      ),
                      Text(
                        '${(scheme.progress * 100).round()}%',
                        style: GoogleFonts.notoSerif(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: PrimaryButton(
              label: scheme.matured
                  ? 'REDEEM MATURITY'
                  : 'PAY ₹${scheme.monthlyAmount.value} NOW',
              icon: scheme.matured ? Icons.redeem : Icons.lock_outline,
              onPressed: scheme.matured
                  ? AppSheets.showRedemption
                  : AppSheets.showSchemePayment,
            ),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(16, 8, 16, 12),
            child: Text(
              'Why save with Wavoo?',
              style: GoogleFonts.notoSerif(
                fontSize: 22,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const _Benefit(
            icon: Icons.calendar_month_outlined,
            title: 'Flexible monthly savings',
            text: 'Choose a comfortable monthly amount from ₹2,000.',
          ),
          const _Benefit(
            icon: Icons.card_giftcard,
            title: 'A rewarding maturity',
            text: 'Unlock jewellery value and exclusive scheme benefits.',
          ),
          const _Benefit(
            icon: Icons.verified_user_outlined,
            title: 'Transparent and secure',
            text: 'Track every instalment and your maturity in one place.',
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(16, 22, 16, 8),
            child: Text(
              'Monthly plan',
              style: GoogleFonts.notoSerif(
                fontSize: 22,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Wrap(
              spacing: 8,
              children: [2000, 5000, 10000, 25000]
                  .map(
                    (amount) => ChoiceChip(
                      label: Text('₹$amount'),
                      selected: scheme.monthlyAmount.value == amount,
                      onSelected: (_) => scheme.choosePlan(amount),
                    ),
                  )
                  .toList(),
            ),
          ),
        ],
      ),
    );
  }
}

class _Benefit extends StatelessWidget {
  const _Benefit({required this.icon, required this.title, required this.text});
  final IconData icon;
  final String title;
  final String text;

  @override
  Widget build(BuildContext context) => ListTile(
    contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 4),
    leading: CircleAvatar(
      backgroundColor: AppColors.cream,
      foregroundColor: AppColors.goldDark,
      child: Icon(icon),
    ),
    title: Text(
      title,
      style: GoogleFonts.notoSerif(fontWeight: FontWeight.w700),
    ),
    subtitle: Text(text),
  );
}
