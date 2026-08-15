import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controllers/home_controller.dart';
import '../../controllers/scheme_controller.dart';
import '../../core/constants/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/utils/money.dart';
import '../../data/models/scheme.dart';
import '../widgets/history_sheets.dart';
import '../widgets/page_heading.dart';
import '../widgets/sheets.dart';
import '../widgets/shimmers.dart';

class SchemesView extends StatefulWidget {
  const SchemesView({super.key});

  @override
  State<SchemesView> createState() => _SchemesViewState();
}

class _SchemesViewState extends State<SchemesView> {
  bool _mineTab = true;

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
          final home = Get.isRegistered<HomeController>()
              ? Get.find<HomeController>()
              : null;
          home?.schemesPastPreview.length;
          final current = scheme.enrollments
              .where((item) => !item.isPast)
              .toList()
            ..sort((a, b) {
              final aReady = a.isRedeemable ? 1 : 0;
              final bReady = b.isRedeemable ? 1 : 0;
              return bReady.compareTo(aReady);
            });
          final past = _uniqueEnrollments([
            ...scheme.enrollments.where((item) => item.isPast),
            ...?home?.schemesPastPreview,
          ])
            ..sort((a, b) {
              final aDate = a.closedAt ?? a.maturityDate ?? a.joinedAt;
              final bDate = b.closedAt ?? b.maturityDate ?? b.joinedAt;
              if (aDate == null && bDate == null) return 0;
              if (aDate == null) return 1;
              if (bDate == null) return -1;
              return bDate.compareTo(aDate);
            });
          return Column(
            children: [
              _SchemeTabs(
                mineSelected: _mineTab,
                currentCount: current.length,
                onMine: () => setState(() => _mineTab = true),
                onNew: () => setState(() => _mineTab = false),
              ),
              const SizedBox(height: 16),
              if (_mineTab)
                _MineSchemesTab(
                  scheme: scheme,
                  current: current,
                  past: past,
                  onStartNew: () => setState(() => _mineTab = false),
                )
              else
                const _StartNewTab(),
            ],
          );
        }),
      ],
    );
  }
}

List<SchemeEnrollment> _uniqueEnrollments(List<SchemeEnrollment> items) {
  final byId = <String, SchemeEnrollment>{};
  for (final item in items) {
    if (item.enrollmentId.isEmpty) continue;
    byId.putIfAbsent(item.enrollmentId, () => item);
  }
  return byId.values.toList();
}

class _SchemeTabs extends StatelessWidget {
  const _SchemeTabs({
    required this.mineSelected,
    required this.currentCount,
    required this.onMine,
    required this.onNew,
  });

  final bool mineSelected;
  final int currentCount;
  final VoidCallback onMine;
  final VoidCallback onNew;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: const Color(0xFFF6F0E7),
        borderRadius: BorderRadius.circular(11),
        border: Border.all(color: AppColors.line),
      ),
      child: Row(
        children: [
          Expanded(
            child: _TabButton(
              label: 'MY SCHEMES · $currentCount',
              selected: mineSelected,
              onTap: onMine,
            ),
          ),
          const SizedBox(width: 4),
          Expanded(
            child: _TabButton(
              label: 'START NEW',
              selected: !mineSelected,
              onTap: onNew,
            ),
          ),
        ],
      ),
    );
  }
}

class _TabButton extends StatelessWidget {
  const _TabButton({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        height: 38,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: selected ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          boxShadow: selected
              ? const [
                  BoxShadow(
                    color: Color(0x1755370F),
                    blurRadius: 10,
                    offset: Offset(0, 3),
                  ),
                ]
              : null,
        ),
        child: Text(
          label,
          style: AppTypography.sans(
            size: 8,
            weight: FontWeight.w800,
            color: selected ? AppColors.goldDark : AppColors.muted,
          ),
        ),
      ),
    );
  }
}

class _MineSchemesTab extends StatelessWidget {
  const _MineSchemesTab({
    required this.scheme,
    required this.current,
    required this.past,
    required this.onStartNew,
  });

  final SchemeController scheme;
  final List<SchemeEnrollment> current;
  final List<SchemeEnrollment> past;
  final VoidCallback onStartNew;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _SectionHead(
          title: 'Current schemes',
          trailing: _StatusBadge(
            label: '${current.length} plan${current.length == 1 ? '' : 's'}',
            kind: _BadgeKind.active,
          ),
        ),
        if (current.isEmpty)
          const _EmptyNote(text: 'No active or redeemable schemes.')
        else
          for (var i = 0; i < current.length; i++) ...[
            if (i > 0) const SizedBox(height: 8),
            _CurrentSchemeCard(scheme: scheme, enrollment: current[i]),
          ],
        const SizedBox(height: 18),
        _SectionHead(
          title: 'Past schemes',
          action: past.isEmpty ? null : 'View all →',
          onAction: past.isEmpty ? null : showPastSchemesSheet,
        ),
        if (past.isEmpty)
          const _EmptyNote(text: 'Completed schemes will appear here.')
        else
          for (var i = 0; i < past.length; i++) ...[
            if (i > 0) const SizedBox(height: 8),
            _PastPreviewCard(enrollment: past[i]),
          ],
        const SizedBox(height: 12),
        _StartAnotherPrompt(onStartNew: onStartNew),
      ],
    );
  }
}

class _StartNewTab extends StatelessWidget {
  const _StartNewTab();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _EnrollHero(onChoose: AppSheets.showSchemeEnrollment),
        const SizedBox(height: 10),
        const _EmptyNote(
          text:
              'Starting a new scheme does not replace or merge any existing plan.',
        ),
      ],
    );
  }
}

class _SectionHead extends StatelessWidget {
  const _SectionHead({
    required this.title,
    this.trailing,
    this.action,
    this.onAction,
  });

  final String title;
  final Widget? trailing;
  final String? action;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Expanded(child: Text(title, style: AppTypography.serif(size: 18))),
          if (trailing != null) trailing!,
          if (action != null)
            TextButton(
              onPressed: onAction,
              style: TextButton.styleFrom(
                padding: EdgeInsets.zero,
                minimumSize: const Size(0, 26),
                foregroundColor: AppColors.goldDark,
              ),
              child: Text(
                action!,
                style: AppTypography.sans(
                  size: 8,
                  weight: FontWeight.w700,
                  color: AppColors.goldDark,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _CurrentSchemeCard extends StatelessWidget {
  const _CurrentSchemeCard({
    required this.scheme,
    required this.enrollment,
  });

  final SchemeController scheme;
  final SchemeEnrollment enrollment;

  @override
  Widget build(BuildContext context) {
    final redeemable = enrollment.isRedeemable;
    final progress = (enrollment.progress * 100).round().clamp(0, 100);
    final saved = enrollment.redeemableBalancePaise > 0
        ? enrollment.redeemableBalancePaise
        : enrollment.savedPaise;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: redeemable
              ? const [Color(0xFFFFF9ED), Color(0xFFF5E3C2)]
              : const [AppColors.ivory, AppColors.pageCard],
        ),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: redeemable ? const Color(0xFFD6AF69) : AppColors.goldBorder,
        ),
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
                      redeemable ? 'REDEMPTION AVAILABLE' : 'MONTHLY PLAN',
                      style: AppTypography.sans(
                        size: 7,
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
                    if (enrollment.enrollmentNumber.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        enrollment.enrollmentNumber,
                        style: AppTypography.sans(
                          size: 7,
                          color: AppColors.muted,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              _StatusBadge(
                label: redeemable ? 'Redeemable' : 'In progress',
                kind: redeemable ? _BadgeKind.redeemable : _BadgeKind.active,
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _StatBox(
                  label: redeemable ? 'Maturity value' : 'Saved so far',
                  value: Money.fromPaise(saved),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _StatBox(
                  label: 'Instalments',
                  value:
                      '${enrollment.paidInstallments}/${enrollment.totalInstallments}',
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _StatBox(
                  label: redeemable ? 'Matured on' : 'Next due',
                  value: scheme.dateLabel(
                    redeemable
                        ? enrollment.maturityDate
                        : enrollment.nextDueDate,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                redeemable ? 'Plan completed' : 'Plan progress',
                style: AppTypography.sans(size: 8, color: AppColors.muted),
              ),
              Text(
                '$progress%',
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
          const SizedBox(height: 12),
          _EmptyNote(
            text: redeemable
                ? 'All instalments are complete. Your savings are ready for redemption.'
                : 'Next instalment: ${Money.fromPaise(enrollment.amountPaise)} due ${scheme.dateLabel(enrollment.nextDueDate)}.',
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _SecondaryButton(
                  label: 'View details',
                  onPressed: () {
                    scheme.selectEnrollment(enrollment);
                    AppSheets.showSchemeDetails();
                  },
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _PrimaryButton(
                  label: redeemable
                      ? 'Redeem now'
                      : 'Pay ${Money.fromPaise(enrollment.amountPaise)}',
                  onPressed: () {
                    scheme.selectEnrollment(enrollment);
                    if (redeemable) {
                      AppSheets.showRedemption();
                    } else {
                      AppSheets.showSchemePayment();
                    }
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _PastPreviewCard extends StatelessWidget {
  const _PastPreviewCard({required this.enrollment});

  final SchemeEnrollment enrollment;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.line),
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
                      enrollment.enrollmentNumber.isEmpty
                          ? enrollment.passbookNumber
                          : enrollment.enrollmentNumber,
                      style: AppTypography.sans(
                        size: 7,
                        color: AppColors.muted,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      enrollment.planName,
                      style: AppTypography.serif(size: 17, height: 1.1),
                    ),
                  ],
                ),
              ),
              const _StatusBadge(
                label: 'Redeemed',
                kind: _BadgeKind.redeemed,
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _SoftMeta(
                  label: 'Final value',
                  value: Money.fromPaise(
                    enrollment.redeemableBalancePaise > 0
                        ? enrollment.redeemableBalancePaise
                        : enrollment.savedPaise,
                  ),
                ),
              ),
              const SizedBox(width: 7),
              Expanded(
                child: _SoftMeta(
                  label: 'Redeemed',
                  value: Get.find<SchemeController>().dateLabel(
                    enrollment.closedAt ?? enrollment.maturityDate,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: _SecondaryButton(
              label: 'View completed plan',
              onPressed: () {
                Get.find<SchemeController>().selectEnrollment(enrollment);
                AppSheets.showSchemeDetails();
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _StartAnotherPrompt extends StatelessWidget {
  const _StartAnotherPrompt({required this.onStartNew});

  final VoidCallback onStartNew;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFAF1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFFD8BD91),
          style: BorderStyle.solid,
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Saving for another goal?',
                  style: AppTypography.serif(size: 15, height: 1.1),
                ),
                const SizedBox(height: 4),
                Text(
                  'Create another scheme without affecting your current plans.',
                  style: AppTypography.sans(
                    size: 7,
                    color: AppColors.muted,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          FilledButton(
            onPressed: onStartNew,
            style: FilledButton.styleFrom(
              minimumSize: const Size(0, 32),
              padding: const EdgeInsets.symmetric(horizontal: 11),
              backgroundColor: AppColors.gold,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(7),
              ),
            ),
            child: Text(
              'START NEW',
              style: AppTypography.sans(
                size: 7,
                weight: FontWeight.w800,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _EnrollHero extends StatelessWidget {
  const _EnrollHero({required this.onChoose});

  final VoidCallback onChoose;

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
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Start another gold plan',
                    style: AppTypography.serif(size: 22, height: 1.05),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Each scheme stays separate with its own instalments, maturity date, payment history and redemption record.',
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
                        child: _Benefit(value: '11', label: 'Month plans'),
                      ),
                      SizedBox(width: 6),
                      Expanded(
                        child: _Benefit(value: '₹1K+', label: 'Monthly from'),
                      ),
                      SizedBox(width: 6),
                      Expanded(
                        child: _Benefit(value: 'Multi', label: 'Plans supported'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    height: 47,
                    child: FilledButton(
                      onPressed: onChoose,
                      child: Text(
                        'CHOOSE A SCHEME',
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

class _PrimaryButton extends StatelessWidget {
  const _PrimaryButton({required this.label, required this.onPressed});

  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 36,
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFC48A27), Color(0xFF9E6106)],
          ),
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onPressed,
            borderRadius: BorderRadius.circular(8),
            child: Center(
              child: Text(
                label,
                style: AppTypography.sans(
                  size: 8,
                  weight: FontWeight.w700,
                  color: Colors.white,
                  letterSpacing: .24,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _SecondaryButton extends StatelessWidget {
  const _SecondaryButton({required this.label, required this.onPressed});

  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 36,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: AppColors.goldDark,
          side: const BorderSide(color: Color(0xFFE6DAC9)),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        child: Text(
          label,
          style: AppTypography.sans(
            size: 8,
            weight: FontWeight.w700,
            color: AppColors.goldDark,
            letterSpacing: .24,
          ),
        ),
      ),
    );
  }
}

class _StatBox extends StatelessWidget {
  const _StatBox({required this.label, required this.value});

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

class _SoftMeta extends StatelessWidget {
  const _SoftMeta({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(9),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F4EE),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: AppTypography.sans(size: 6, color: AppColors.muted),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: AppTypography.sans(
              size: 9,
              weight: FontWeight.w700,
              color: AppColors.goldDark,
            ),
          ),
        ],
      ),
    );
  }
}

class _Benefit extends StatelessWidget {
  const _Benefit({required this.value, required this.label});

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: .72),
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

class _EmptyNote extends StatelessWidget {
  const _EmptyNote({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.cream,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        text,
        style: AppTypography.sans(
          size: 9,
          color: AppColors.muted,
          height: 1.45,
        ),
      ),
    );
  }
}

enum _BadgeKind { active, redeemable, redeemed }

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.label, required this.kind});

  final String label;
  final _BadgeKind kind;

  @override
  Widget build(BuildContext context) {
    late Color background;
    late Color color;
    switch (kind) {
      case _BadgeKind.active:
        background = const Color(0xFFE8F5EC);
        color = const Color(0xFF27713C);
      case _BadgeKind.redeemable:
        background = const Color(0xFFFFF0CF);
        color = const Color(0xFF9B5E00);
      case _BadgeKind.redeemed:
        background = const Color(0xFFEEE9E0);
        color = const Color(0xFF665C4C);
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label.toUpperCase(),
        style: AppTypography.sans(
          size: 6,
          weight: FontWeight.w900,
          color: color,
          letterSpacing: .48,
        ),
      ),
    );
  }
}
