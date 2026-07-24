import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controllers/scheme_controller.dart';
import '../../core/constants/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../widgets/page_heading.dart';
import '../widgets/sheets.dart';

class SchemesView extends StatelessWidget {
  const SchemesView({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = Get.find<SchemeController>();
    return ListView(
      padding: const EdgeInsets.fromLTRB(13, 0, 13, 24),
      children: [
        const PageHeading(
          title: 'Gold Schemes',
          subtitle: 'Save monthly, redeem with pride',
          horizontalPadding: 2,
        ),
        _SectionHeader(
          title: 'My plans',
          action: 'View details',
          onTap: AppSheets.showSchemeDetails,
        ),
        Obx(() {
          // Keep this Obx scoped to the plan values that redraw the card.
          scheme.paidInstallments.value;
          scheme.monthlyAmount.value;
          scheme.isRedeemed.value;
          return _PlanCard(scheme: scheme);
        }),
        const SizedBox(height: 18),
        const _SectionHeader(title: 'Enroll in a scheme'),
        Obx(() {
          scheme.hasJoined.value;
          return _EnrollmentCard(scheme: scheme);
        }),
      ],
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title, this.action, this.onTap});

  final String title;
  final String? action;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Expanded(child: Text(title, style: AppTypography.serif(size: 18))),
          if (action != null)
            TextButton.icon(
              onPressed: onTap,
              style: TextButton.styleFrom(
                padding: EdgeInsets.zero,
                minimumSize: const Size(0, 26),
                foregroundColor: AppColors.goldDark,
              ),
              label: Text(
                action!,
                style: AppTypography.sans(
                  size: 9,
                  weight: FontWeight.w700,
                  color: AppColors.goldDark,
                ),
              ),
              icon: const Icon(Icons.arrow_forward, size: 13),
            ),
        ],
      ),
    );
  }
}

class _PlanCard extends StatelessWidget {
  const _PlanCard({required this.scheme});

  final SchemeController scheme;

  @override
  Widget build(BuildContext context) {
    final upcoming = scheme.upcomingPayments.take(4).toList();
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.ivory, AppColors.pageCard],
        ),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.goldBorder),
        boxShadow: const [
          BoxShadow(
            color: Color(0x128B5A14),
            blurRadius: 22,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      scheme.isRedeemed.value
                          ? 'REDEEMED PLAN'
                          : scheme.matured
                              ? 'MATURED PLAN'
                              : 'ACTIVE PLAN',
                      style: AppTypography.sans(
                        size: 7,
                        weight: FontWeight.w800,
                        color: AppColors.goldDark,
                        letterSpacing: .84,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      scheme.planName,
                      style: AppTypography.serif(size: 20, height: 1.05),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.gold.withOpacity(.1),
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(color: AppColors.goldBorder),
                ),
                child: Text(
                  scheme.isRedeemed.value
                      ? 'REDEEMED'
                      : scheme.matured
                          ? 'MATURED'
                          : 'ACTIVE',
                  style: AppTypography.sans(
                    size: 7,
                    weight: FontWeight.w800,
                    color: AppColors.goldDark,
                    letterSpacing: .56,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _StatCard(
                  label: 'Saved so far',
                  value: scheme.money(scheme.savedAmount),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _StatCard(
                  label: 'Instalments',
                  value:
                      '${scheme.paidInstallments.value}/${scheme.totalInstallments}',
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _StatCard(
                  label: 'Maturity',
                  value: scheme.dateLabel(scheme.maturityDate),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Plan progress',
                style: AppTypography.sans(size: 8, color: AppColors.muted),
              ),
              Text(
                '${scheme.progressPercent}%',
                style: AppTypography.sans(
                  size: 8,
                  weight: FontWeight.w800,
                  color: AppColors.goldDark,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: scheme.progress,
              minHeight: 6,
              color: AppColors.goldLight,
              backgroundColor: AppColors.line,
            ),
          ),
          if (!scheme.matured && !scheme.isRedeemed.value) ...[
            const SizedBox(height: 14),
            Text(
              'Upcoming payments',
              style: AppTypography.serif(size: 18),
            ),
            const SizedBox(height: 9),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: AppColors.line),
                borderRadius: BorderRadius.circular(12),
              ),
              clipBehavior: Clip.antiAlias,
              child: Column(
                children: [
                  for (var index = 0; index < upcoming.length; index++)
                    _PaymentRow(
                      payment: upcoming[index],
                      showDivider: index != upcoming.length - 1,
                      onPay: upcoming[index].isNext
                          ? AppSheets.showSchemePayment
                          : null,
                    ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: AppSheets.showSchemeDetails,
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size(0, 36),
                    side: const BorderSide(color: Color(0xFFE6DAC9)),
                    foregroundColor: AppColors.goldDark,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    textStyle: AppTypography.sans(
                      size: 8,
                      weight: FontWeight.w700,
                    ),
                  ),
                  child: const Text('Full schedule'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: FilledButton(
                  onPressed: scheme.matured
                      ? AppSheets.showRedemption
                      : AppSheets.showSchemePayment,
                  style: FilledButton.styleFrom(
                    minimumSize: const Size(0, 36),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(scheme.matured ? 'Redeem now' : 'Pay next'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minHeight: 58),
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(11),
        border: Border.all(color: AppColors.line),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: AppTypography.sans(size: 7, color: AppColors.muted),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTypography.sans(size: 10, weight: FontWeight.w700),
          ),
        ],
      ),
    );
  }
}

class _PaymentRow extends StatelessWidget {
  const _PaymentRow({
    required this.payment,
    required this.showDivider,
    this.onPay,
  });

  final SchemePayment payment;
  final bool showDivider;
  final VoidCallback? onPay;

  @override
  Widget build(BuildContext context) {
    final scheme = Get.find<SchemeController>();
    return Container(
      constraints: const BoxConstraints(minHeight: 52),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: payment.isNext ? AppColors.cream : AppColors.ivory,
        border: showDivider
            ? const Border(bottom: BorderSide(color: AppColors.line))
            : null,
      ),
      child: Row(
        children: [
          Container(
            width: 28,
            height: 28,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: payment.isNext ? AppColors.gold : const Color(0xFFFFF7E8),
              shape: BoxShape.circle,
              boxShadow: payment.isNext
                  ? [
                      BoxShadow(
                        color: AppColors.gold.withOpacity(.14),
                        spreadRadius: 3,
                      ),
                    ]
                  : null,
            ),
            child: Text(
              payment.isNext ? '●' : '${payment.installment}',
              style: AppTypography.sans(
                size: 8,
                weight: FontWeight.w800,
                color: payment.isNext ? Colors.white : AppColors.goldDark,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Instalment ${payment.installment}${payment.isNext ? ' · Due next' : ''}',
                  style: AppTypography.sans(
                    size: 9,
                    weight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${scheme.dateLabel(payment.date)} · ${scheme.money(payment.amount)}',
                  style: AppTypography.sans(
                    size: 7,
                    color: AppColors.muted,
                  ),
                ),
              ],
            ),
          ),
          if (onPay != null)
            SizedBox(
              height: 28,
              child: FilledButton(
                onPressed: onPay,
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
                child: const Text('PAY'),
              ),
            )
          else
            Text(
              scheme.money(payment.amount),
              style: AppTypography.sans(
                size: 10,
                weight: FontWeight.w700,
                color: AppColors.goldDark,
              ),
            ),
        ],
      ),
    );
  }
}

class _EnrollmentCard extends StatelessWidget {
  const _EnrollmentCard({required this.scheme});

  final SchemeController scheme;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.cream,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.goldBorder),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0F8B5A14),
            blurRadius: 22,
            offset: Offset(0, 8),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          SizedBox(
            height: 118,
            width: double.infinity,
            child: Stack(
              fit: StackFit.expand,
              children: [
                Image.asset(
                  'assets/images/design_01.webp',
                  fit: BoxFit.cover,
                ),
                const DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Color(0xEAFBF4E9),
                        AppColors.cream,
                      ],
                      stops: [.35, .78, 1],
                    ),
                  ),
                ),
              ],
            ),
          ),
          Transform.translate(
            offset: const Offset(0, -18),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Start a new gold plan',
                    style: AppTypography.serif(size: 22, height: 1.05),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Choose a monthly contribution, pay on schedule, and redeem your savings for fine jewellery at maturity.',
                    style: AppTypography.sans(
                      size: 9,
                      color: AppColors.muted,
                      height: 1.45,
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Row(
                    children: [
                      Expanded(
                        child: _EnrollmentBenefit(
                          value: '11',
                          label: 'Month plans',
                        ),
                      ),
                      SizedBox(width: 6),
                      Expanded(
                        child: _EnrollmentBenefit(
                          value: '₹5K+',
                          label: 'Monthly from',
                        ),
                      ),
                      SizedBox(width: 6),
                      Expanded(
                        child: _EnrollmentBenefit(
                          value: '0%',
                          label: 'Making charge bonus',
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    height: 47,
                    child: FilledButton(
                      onPressed: AppSheets.showSchemeEnrollment,
                      child: Text(
                        scheme.hasJoined.value
                            ? 'ENROLL IN ANOTHER PLAN'
                            : 'ENROLL NOW',
                        style: AppTypography.sans(
                          size: 11,
                          weight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _EnrollmentBenefit extends StatelessWidget {
  const _EnrollmentBenefit({required this.value, required this.label});

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(.72),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFEADFCE)),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: AppTypography.serif(size: 14, color: AppColors.goldDark),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            textAlign: TextAlign.center,
            style: AppTypography.sans(
              size: 6,
              color: AppColors.muted,
              height: 1.2,
            ),
          ),
        ],
      ),
    );
  }
}
