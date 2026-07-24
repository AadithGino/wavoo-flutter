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
        onTap: onOpenPlan,
        borderRadius: BorderRadius.circular(13),
        child: Container(
          margin: const EdgeInsets.only(top: 14, bottom: 4),
          padding: const EdgeInsets.fromLTRB(16, 14, 14, 12),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [AppColors.ivory, AppColors.pageCard],
            ),
            borderRadius: BorderRadius.circular(13),
            border: Border.all(color: AppColors.goldBorder),
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
                                scheme.matured
                                    ? 'PLAN MATURED'
                                    : 'GOLD PLAN ACTIVE',
                                style: AppTypography.sans(
                                  size: 7,
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
                                  scheme.matured
                                      ? 'Fully paid'
                                      : '${scheme.remainingInstallments} remaining',
                                  style: AppTypography.sans(
                                    size: 7,
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
                          'SAVED SO FAR',
                          style: AppTypography.sans(
                            size: 7,
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
                                size: 8,
                                weight: FontWeight.w800,
                                color: AppColors.goldDark,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Next ${scheme.money(scheme.monthlyAmount.value)} · ${scheme.dateLabel(scheme.nextDueDate)}',
                          style: AppTypography.sans(
                            size: 8,
                            color: AppColors.muted,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                'Due in 20 days',
                                style: AppTypography.sans(
                                  size: 7,
                                  weight: FontWeight.w700,
                                  color: AppColors.muted,
                                ),
                              ),
                            ),
                            SizedBox(
                              height: 28,
                              child: FilledButton(
                                onPressed: AppSheets.showSchemePayment,
                                style: FilledButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 11,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                ),
                                child: Text(
                                  'Pay ${scheme.money(scheme.monthlyAmount.value)}  →',
                                  style: AppTypography.sans(
                                    size: 7,
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
          child: Column(
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
