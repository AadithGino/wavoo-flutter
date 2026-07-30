import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controllers/scheme_controller.dart';
import '../../core/constants/app_colors.dart';
import '../../core/theme/app_typography.dart';
import 'sheets.dart';

class SchemeProgressCard extends StatelessWidget {
  const SchemeProgressCard({required this.onOpenPlan, super.key});

  final VoidCallback onOpenPlan;

  @override
  Widget build(BuildContext context) {
    final scheme = Get.find<SchemeController>();
    return Obx(
      () => InkWell(
        onTap: scheme.matured ? AppSheets.showRedemption : onOpenPlan,
        borderRadius: BorderRadius.circular(13),
        child: Container(
          margin: const EdgeInsets.only(top: 14, bottom: 4),
          padding: const EdgeInsets.fromLTRB(16, 14, 14, 12),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: scheme.matured && !scheme.isRedeemed.value
                  ? const [Color(0xFFFFF9EF), Color(0xFFF7EAD0)]
                  : const [AppColors.ivory, AppColors.pageCard],
            ),
            borderRadius: BorderRadius.circular(13),
            border: Border.all(
              color: scheme.matured
                  ? const Color(0xFFDFC9A8)
                  : AppColors.goldBorder,
            ),
            boxShadow: const [
              BoxShadow(
                color: Color(0x128B5A14),
                blurRadius: 20,
                offset: Offset(0, 6),
              ),
            ],
          ),
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Positioned(
                left: -16,
                top: -2,
                bottom: -2,
                child: Container(
                  width: 3,
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [AppColors.goldLight, AppColors.goldDeep],
                    ),
                    borderRadius: BorderRadius.horizontal(
                      right: Radius.circular(3),
                    ),
                  ),
                ),
              ),
              Row(
                children: [
                  _ProgressRing(scheme: scheme),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 5,
                              height: 5,
                              decoration: BoxDecoration(
                                color: scheme.matured
                                    ? AppColors.gold
                                    : AppColors.success,
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: (scheme.matured
                                            ? AppColors.gold
                                            : AppColors.success)
                                        .withOpacity(.16),
                                    spreadRadius: 3,
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                scheme.isRedeemed.value
                                    ? 'REDEEMED'
                                    : scheme.matured
                                        ? 'PLAN MATURED'
                                        : 'GOLD PLAN ACTIVE',
                                style: AppTypography.sans(
                                  size: 9,
                                  weight: FontWeight.w800,
                                  color: AppColors.goldDark,
                                  letterSpacing: .9,
                                ),
                              ),
                            ),
                            DecoratedBox(
                              decoration: BoxDecoration(
                                color: AppColors.gold.withOpacity(.1),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 7,
                                  vertical: 3,
                                ),
                                child: Text(
                                  scheme.isRedeemed.value
                                      ? 'Complete'
                                      : scheme.matured
                                          ? 'Fully paid'
                                          : '${scheme.remainingInstallments} remaining',
                                  style: AppTypography.sans(
                                    size: 9,
                                    weight: FontWeight.w700,
                                    color: AppColors.goldDark,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          scheme.isRedeemed.value
                              ? 'TOTAL REDEEMED'
                              : scheme.matured
                                  ? 'TOTAL SAVED'
                                  : 'SAVED SO FAR',
                          style: AppTypography.sans(
                            size: 9,
                            weight: FontWeight.w800,
                            color: AppColors.muted,
                            letterSpacing: .84,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text.rich(
                          TextSpan(
                            children: [
                              TextSpan(
                                text: scheme.money(scheme.savedAmount),
                                style: AppTypography.serif(
                                  size: 20,
                                  height: 1.05,
                                ),
                              ),
                              TextSpan(
                                text: '  of ${scheme.money(scheme.goalAmount)}',
                                style: AppTypography.sans(
                                  size: 10,
                                  weight: FontWeight.w600,
                                  color: AppColors.muted,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Expanded(
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: LinearProgressIndicator(
                                  value: scheme.progress,
                                  minHeight: 6,
                                  color: AppColors.goldLight,
                                  backgroundColor: AppColors.line,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '${scheme.progressPercent}%',
                              style: AppTypography.sans(
                                size: 10,
                                weight: FontWeight.w800,
                                color: AppColors.goldDark,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          scheme.isRedeemed.value
                              ? 'Redeemed · ref ${scheme.redemptionReference.value}'
                              : scheme.matured
                                  ? 'Ready to redeem · matured ${scheme.dateLabel(scheme.maturityDate)}'
                                  : 'Next ${scheme.money(scheme.monthlyAmount.value)} · ${scheme.dateLabel(scheme.nextDueDate)}',
                          style: AppTypography.sans(
                            size: 10,
                            color: AppColors.muted,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                scheme.isRedeemed.value
                                    ? 'Plan completed'
                                    : scheme.matured
                                        ? 'Maturity reached'
                                        : 'Due in 20 days',
                                style: AppTypography.sans(
                                  size: 9,
                                  weight: FontWeight.w700,
                                  color: AppColors.muted,
                                ),
                              ),
                            ),
                            SizedBox(
                              height: 28,
                              child: FilledButton(
                                onPressed: scheme.isRedeemed.value
                                    ? AppSheets.showSchemeDetails
                                    : scheme.matured
                                        ? AppSheets.showRedemption
                                        : AppSheets.showSchemePayment,
                                style: FilledButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 11,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                ),
                                child: Text(
                                  scheme.isRedeemed.value
                                      ? 'View details  →'
                                      : scheme.matured
                                          ? 'Redeem now  →'
                                          : 'Pay ${scheme.money(scheme.monthlyAmount.value)}  →',
                                  style: AppTypography.sans(
                                    size: 9,
                                    weight: FontWeight.w800,
                                    color: Colors.white,
                                    letterSpacing: .28,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProgressRing extends StatelessWidget {
  const _ProgressRing({required this.scheme});

  final SchemeController scheme;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 80,
      height: 80,
      child: CustomPaint(
        painter: _RingPainter(progress: scheme.progress),
        child: Center(
          child: scheme.matured
              ? Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 24,
                      height: 24,
                      alignment: Alignment.center,
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [AppColors.goldLight, AppColors.goldDeep],
                        ),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Color(0x38975C06),
                            blurRadius: 12,
                            offset: Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Text(
                        '✓',
                        style: AppTypography.sans(
                          size: 12,
                          weight: FontWeight.w800,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      scheme.isRedeemed.value ? 'REDEEMED' : 'MATURED',
                      style: AppTypography.sans(
                        size: 6,
                        weight: FontWeight.w800,
                        color: AppColors.goldDark,
                        letterSpacing: .6,
                      ),
                    ),
                  ],
                )
              : Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '${scheme.paidInstallments.value}',
                      style: AppTypography.serif(
                        size: 22,
                        weight: FontWeight.w500,
                        height: 1,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '/${scheme.totalInstallments}',
                      style: AppTypography.sans(
                        size: 10,
                        weight: FontWeight.w600,
                        color: AppColors.muted,
                        height: 1,
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  const _RingPainter({required this.progress});

  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final rect = Rect.fromCircle(center: center, radius: 31);
    canvas.drawCircle(
      center,
      35,
      Paint()
        ..shader = const RadialGradient(
          center: Alignment(0, -.25),
          colors: [AppColors.ivory, Color(0xFFF6EAD8), AppColors.goldBorder],
          stops: [0, .72, 1],
        ).createShader(Rect.fromCircle(center: center, radius: 35)),
    );
    canvas.drawArc(
      rect,
      -math.pi / 2,
      math.pi * 2,
      false,
      Paint()
        ..color = const Color(0xFFE8DFD2)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 10,
    );
    canvas.drawArc(
      rect,
      -math.pi / 2,
      math.pi * 2 * progress,
      false,
      Paint()
        ..shader = const LinearGradient(
          colors: [Color(0xFFE8C46A), AppColors.goldLight, AppColors.goldDark],
        ).createShader(rect)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 10
        ..strokeCap = StrokeCap.round,
    );
  }

  @override
  bool shouldRepaint(covariant _RingPainter oldDelegate) =>
      oldDelegate.progress != progress;
}
