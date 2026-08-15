import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controllers/scheme_controller.dart';
import '../../core/constants/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../data/models/scheme.dart';
import '../widgets/page_heading.dart';
import '../widgets/sheets.dart';
import '../widgets/shimmers.dart';

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
        Obx(() {
          if (scheme.isLoading.value) {
            return const SchemePageShimmer();
          }
          scheme.paymentBusy.value;
          final plans = scheme.enrollments.toList();
          final available = scheme.catalogue.toList();
          return Column(
            children: [
              if (plans.isNotEmpty) ...[
                _SectionHeader(
                  title: plans.length == 1 ? 'My plan' : 'My plans',
                  action: 'View details',
                  onTap: () {
                    scheme.selectEnrollment(plans.first);
                    AppSheets.showSchemeDetails();
                  },
                ),
                for (var i = 0; i < plans.length; i++) ...[
                  if (i > 0) const SizedBox(height: 12),
                  _PlanCard(
                    scheme: scheme,
                    enrollment: plans[i],
                    compact: plans.length > 1,
                  ),
                ],
                const SizedBox(height: 18),
              ],
              _SectionHeader(
                title: available.length > 1
                    ? 'Available schemes'
                    : 'Enroll in a scheme',
              ),
              if (available.isEmpty)
                _EnrollmentCard(scheme: scheme)
              else
                for (var i = 0; i < available.length; i++) ...[
                  if (i > 0) const SizedBox(height: 12),
                  _CatalogueCard(scheme: scheme, item: available[i]),
                ],
            ],
          );
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
  const _PlanCard({
    required this.scheme,
    required this.enrollment,
    this.compact = false,
  });

  final SchemeController scheme;
  final SchemeEnrollment enrollment;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final redeemed = enrollment.isRedeemed;
    final matured = enrollment.isMatured;
    final upcoming = compact
        ? const <SchemePayment>[]
        : scheme.upcomingFor(enrollment).take(4).toList();
    final statusLabel = redeemed
        ? 'REDEEMED'
        : matured
            ? 'MATURED'
            : 'ACTIVE';
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
                      redeemed
                          ? 'REDEEMED PLAN'
                          : matured
                              ? 'MATURED PLAN'
                              : 'ACTIVE PLAN',
                      style: AppTypography.sans(
                        size: 9,
                        weight: FontWeight.w800,
                        color: AppColors.goldDark,
                        letterSpacing: .84,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      enrollment.planName,
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
                  statusLabel,
                  style: AppTypography.sans(
                    size: 9,
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
                  value: scheme.moneyPaise(enrollment.savedPaise),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _StatCard(
                  label: 'Instalments',
                  value:
                      '${enrollment.paidInstallments}/${enrollment.totalInstallments}',
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _StatCard(
                  label: 'Maturity',
                  value: scheme.dateLabel(enrollment.maturityDate),
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
                '${(enrollment.progress * 100).round()}%',
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
              value: enrollment.progress,
              minHeight: 6,
              color: AppColors.goldLight,
              backgroundColor: AppColors.line,
            ),
          ),
          if (!matured && !redeemed && upcoming.isNotEmpty) ...[
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
                          ? () {
                              scheme.selectEnrollment(enrollment);
                              AppSheets.showSchemePayment();
                            }
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
                  onPressed: () {
                    scheme.selectEnrollment(enrollment);
                    AppSheets.showSchemeDetails();
                  },
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
                  child: const Text(
                    'Full schedule',
                    style: TextStyle(fontSize: 10),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: FilledButton(
                  onPressed: () {
                    scheme.selectEnrollment(enrollment);
                    if (matured) {
                      AppSheets.showRedemption();
                    } else {
                      AppSheets.showSchemePayment();
                    }
                  },
                  style: FilledButton.styleFrom(
                    minimumSize: const Size(0, 36),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    matured ? 'Redeem now' : 'Pay next',
                    style: const TextStyle(fontSize: 10),
                  ),
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
            style: AppTypography.sans(size: 9, color: AppColors.muted),
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
                size: 10,
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
                    size: 10,
                    weight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${scheme.dateLabel(payment.date)} · ${scheme.money(payment.amount)}',
                  style: AppTypography.sans(
                    size: 10,
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

class _CatalogueCard extends StatelessWidget {
  const _CatalogueCard({required this.scheme, required this.item});

  final SchemeController scheme;
  final SchemeCatalogueItem item;

  @override
  Widget build(BuildContext context) {
    final busy = scheme.paymentBusy.value &&
        scheme.selectedCatalogueItem.value?.templateId == item.templateId;
    final description = item.shortDescription.isNotEmpty
        ? item.shortDescription
        : item.description;
    return Container(
      padding: const EdgeInsets.all(16),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  item.isFeatured ? 'FEATURED SCHEME' : 'GOLD SCHEME',
                  style: AppTypography.sans(
                    size: 9,
                    weight: FontWeight.w800,
                    color: AppColors.goldDark,
                    letterSpacing: .84,
                  ),
                ),
              ),
              if (item.totalInstallments > 0)
                Text(
                  '${item.totalInstallments} months',
                  style: AppTypography.sans(
                    size: 9,
                    weight: FontWeight.w700,
                    color: AppColors.muted,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 6),
          Text(item.name, style: AppTypography.serif(size: 20, height: 1.05)),
          if (description.isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(
              description,
              style: AppTypography.sans(
                size: 9,
                color: AppColors.muted,
                height: 1.45,
              ),
            ),
          ],
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _StatCard(
                  label: 'Monthly',
                  value: item.amountPaise > 0
                      ? scheme.moneyPaise(item.amountPaise)
                      : '—',
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _StatCard(
                  label: 'Tenure',
                  value: item.totalInstallments > 0
                      ? '${item.totalInstallments} months'
                      : '—',
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _StatCard(
                  label: 'Goal',
                  value: item.goalPaise > 0
                      ? scheme.moneyPaise(item.goalPaise)
                      : '—',
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            height: 44,
            child: FilledButton(
              onPressed: busy || item.versionId.isEmpty
                  ? null
                  : () => scheme.joinCatalogueItem(item),
              child: busy
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.2,
                        color: Colors.white,
                      ),
                    )
                  : Text(
                      'ENROLL',
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
              size: 8,
              color: AppColors.muted,
              height: 1.2,
            ),
          ),
        ],
      ),
    );
  }
}
