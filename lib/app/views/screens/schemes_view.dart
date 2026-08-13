import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controllers/scheme_controller.dart';
import '../../core/constants/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/utils/money.dart';
import '../../data/models/scheme.dart';
import '../sheets/app_sheets.dart';
import '../widgets/page_heading.dart';

class SchemesView extends StatelessWidget {
  const SchemesView({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = Get.find<SchemeController>();
    return Obx(() {
      final enrollment = scheme.activeEnrollment;
      return ListView(
        padding: const EdgeInsets.fromLTRB(13, 0, 13, 24),
        children: [
          const PageHeading(
            title: 'Gold Schemes',
            subtitle: 'Save monthly, redeem with pride',
            horizontalPadding: 2,
          ),
          if (scheme.isLoading.value)
            const Padding(
              padding: EdgeInsets.all(32),
              child: Center(child: CircularProgressIndicator()),
            )
          else ...[
            _SectionHeader(
              title: 'My plans',
              action: enrollment == null ? null : 'View details',
              onTap: enrollment == null ? null : AppSheets.showSchemeDetails,
            ),
            if (enrollment == null)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.line),
                ),
                child: Text(
                  scheme.loadError.value ??
                      'You have not joined a gold scheme yet. Enroll below to start saving.',
                  style: AppTypography.sans(size: 13, color: AppColors.muted),
                ),
              )
            else
              _PlanCard(scheme: scheme, enrollment: enrollment),
            const SizedBox(height: 18),
            const _SectionHeader(title: 'Enroll in a scheme'),
            _EnrollmentCard(scheme: scheme),
          ],
        ],
      );
    });
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
                minimumSize: const Size(48, 44),
                foregroundColor: AppColors.goldDark,
              ),
              label: Text(
                action!,
                style: AppTypography.sans(
                  size: 12,
                  weight: FontWeight.w700,
                  color: AppColors.goldDark,
                ),
              ),
              icon: const Icon(Icons.arrow_forward, size: 16),
            ),
        ],
      ),
    );
  }
}

class _PlanCard extends StatelessWidget {
  const _PlanCard({required this.scheme, required this.enrollment});

  final SchemeController scheme;
  final SchemeEnrollment enrollment;

  @override
  Widget build(BuildContext context) {
    final upcoming = enrollment.installments.where((i) => !i.isPaid).take(4).toList();
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
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            scheme.isRedeemed.value
                ? 'REDEEMED PLAN'
                : enrollment.isMatured
                    ? 'MATURED PLAN'
                    : 'ACTIVE PLAN',
            style: AppTypography.sans(
              size: 11,
              weight: FontWeight.w800,
              color: AppColors.goldDark,
              letterSpacing: .84,
            ),
          ),
          const SizedBox(height: 6),
          Text(enrollment.planName, style: AppTypography.serif(size: 20, height: 1.05)),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _StatCard(
                  label: 'Saved so far',
                  value: Money.fromPaise(enrollment.savedPaise),
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
                  label: 'Status',
                  value: enrollment.status,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: enrollment.progress,
              minHeight: 6,
              color: AppColors.goldLight,
              backgroundColor: AppColors.line,
            ),
          ),
          if (upcoming.isNotEmpty && !enrollment.isMatured) ...[
            const SizedBox(height: 14),
            Text('Upcoming payments', style: AppTypography.serif(size: 18)),
            const SizedBox(height: 9),
            ...upcoming.map(
              (payment) => ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text('Instalment ${payment.sequenceNumber}'),
                subtitle: Text(scheme.dateLabel(payment.dueDate)),
                trailing: payment == upcoming.first
                    ? FilledButton(
                        onPressed: AppSheets.showSchemePayment,
                        child: const Text('PAY'),
                      )
                    : Text(Money.fromPaise(payment.amountPaise)),
              ),
            ),
          ],
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: AppSheets.showSchemeDetails,
                  child: const Text('Full schedule'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: FilledButton(
                  onPressed: enrollment.isMatured
                      ? AppSheets.showRedemption
                      : AppSheets.showSchemePayment,
                  child: Text(enrollment.isMatured ? 'Redeem now' : 'Pay next'),
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
          Text(label, style: AppTypography.sans(size: 11, color: AppColors.muted)),
          const SizedBox(height: 6),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTypography.sans(size: 12, weight: FontWeight.w700),
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
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          SizedBox(
            height: 118,
            width: double.infinity,
            child: ColoredBox(
              color: AppColors.cream2,
              child: Icon(Icons.savings_outlined, color: AppColors.goldDark, size: 42),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Start a new gold plan',
                  style: AppTypography.serif(size: 22, height: 1.05),
                ),
                const SizedBox(height: 6),
                Text(
                  'Choose a published scheme. Monthly amount and tenure are fixed by Wavoo scheme rules.',
                  style: AppTypography.sans(
                    size: 13,
                    color: AppColors.muted,
                    height: 1.45,
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: FilledButton(
                    onPressed: AppSheets.showSchemeEnrollment,
                    child: Text(
                      scheme.hasJoined ? 'ENROLL IN ANOTHER PLAN' : 'ENROLL NOW',
                      style: AppTypography.sans(
                        size: 13,
                        weight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
