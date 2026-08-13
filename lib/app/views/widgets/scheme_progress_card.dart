import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controllers/scheme_controller.dart';
import '../../core/constants/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/utils/money.dart';
import '../sheets/app_sheets.dart';

class SchemeProgressCard extends StatelessWidget {
  const SchemeProgressCard({required this.onOpenPlan, super.key});

  final VoidCallback onOpenPlan;

  @override
  Widget build(BuildContext context) {
    final scheme = Get.find<SchemeController>();
    return Obx(() {
      final enrollment = scheme.activeEnrollment;
      if (enrollment == null) {
        return InkWell(
          onTap: AppSheets.showSchemeEnrollment,
          borderRadius: BorderRadius.circular(13),
          child: Container(
            margin: const EdgeInsets.only(top: 14, bottom: 4),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.cream,
              borderRadius: BorderRadius.circular(13),
              border: Border.all(color: AppColors.goldBorder),
            ),
            child: Row(
              children: [
                const Icon(Icons.savings_outlined, color: AppColors.goldDark),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Start a gold savings plan',
                    style: AppTypography.serif(size: 18),
                  ),
                ),
                const Icon(Icons.arrow_forward, color: AppColors.goldDark),
              ],
            ),
          ),
        );
      }

      final matured = enrollment.isMatured || scheme.isRedeemed.value;
      final progress = enrollment.progress;
      final remaining =
          (enrollment.totalInstallments - enrollment.paidInstallments)
              .clamp(0, enrollment.totalInstallments);

      return InkWell(
        onTap: matured ? AppSheets.showRedemption : onOpenPlan,
        borderRadius: BorderRadius.circular(13),
        child: Container(
          margin: const EdgeInsets.only(top: 14, bottom: 4),
          padding: const EdgeInsets.fromLTRB(16, 14, 14, 12),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: matured && !scheme.isRedeemed.value
                  ? const [Color(0xFFFFF9EF), Color(0xFFF7EAD0)]
                  : const [AppColors.ivory, AppColors.pageCard],
            ),
            borderRadius: BorderRadius.circular(13),
            border: Border.all(
              color: matured ? const Color(0xFFDFC9A8) : AppColors.goldBorder,
            ),
          ),
          child: Row(
            children: [
              SizedBox(
                width: 80,
                height: 80,
                child: CustomPaint(
                  painter: _RingPainter(progress: progress),
                  child: Center(
                    child: Text(
                      '${enrollment.paidInstallments}/${enrollment.totalInstallments}',
                      style: AppTypography.sans(
                        size: 12,
                        weight: FontWeight.w800,
                        color: AppColors.goldDark,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      scheme.isRedeemed.value
                          ? 'REDEEMED'
                          : matured
                              ? 'PLAN MATURED'
                              : 'GOLD PLAN ACTIVE',
                      style: AppTypography.sans(
                        size: 11,
                        weight: FontWeight.w800,
                        color: AppColors.goldDark,
                        letterSpacing: .9,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      Money.fromPaise(enrollment.savedPaise),
                      style: AppTypography.serif(size: 20, height: 1.05),
                    ),
                    Text(
                      'of ${Money.fromPaise(enrollment.goalPaise)} · $remaining remaining',
                      style: AppTypography.sans(size: 12, color: AppColors.muted),
                    ),
                    const SizedBox(height: 8),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: LinearProgressIndicator(
                        value: progress,
                        minHeight: 6,
                        color: AppColors.goldLight,
                        backgroundColor: AppColors.line,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Align(
                      alignment: Alignment.centerRight,
                      child: FilledButton(
                        onPressed: scheme.isRedeemed.value
                            ? AppSheets.showSchemeDetails
                            : matured
                                ? AppSheets.showRedemption
                                : AppSheets.showSchemePayment,
                        style: FilledButton.styleFrom(
                          minimumSize: const Size(0, 36),
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                        ),
                        child: Text(
                          scheme.isRedeemed.value
                              ? 'View details'
                              : matured
                                  ? 'Redeem now'
                                  : 'Pay ${Money.fromPaise(enrollment.amountPaise)}',
                          style: AppTypography.sans(
                            size: 12,
                            weight: FontWeight.w800,
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
        ),
      );
    });
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
