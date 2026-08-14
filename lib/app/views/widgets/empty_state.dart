import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../core/theme/app_typography.dart';
import 'primary_button.dart';

class EmptyState extends StatelessWidget {
  const EmptyState({
    required this.title,
    required this.message,
    this.icon = Icons.diamond_outlined,
    this.actionLabel,
    this.onAction,
    this.compact = false,
    super.key,
  });

  final String title;
  final String message;
  final IconData icon;
  final String? actionLabel;
  final VoidCallback? onAction;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final iconSize = compact ? 28.0 : 34.0;
    final ring = compact ? 72.0 : 88.0;
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 20 : 28,
        vertical: compact ? 28 : 36,
      ),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.white, AppColors.pageCard],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.goldBorder),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: ring,
            height: ring,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.cream,
              border: Border.all(color: AppColors.goldSoft, width: 1.4),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x148B5A14),
                  blurRadius: 18,
                  offset: Offset(0, 8),
                ),
              ],
            ),
            child: Icon(icon, size: iconSize, color: AppColors.goldDark),
          ),
          SizedBox(height: compact ? 16 : 20),
          Text(
            title,
            textAlign: TextAlign.center,
            style: AppTypography.serif(size: compact ? 20 : 24, height: 1.1),
          ),
          const SizedBox(height: 8),
          Text(
            message,
            textAlign: TextAlign.center,
            style: AppTypography.sans(
              size: compact ? 10 : 11,
              color: AppColors.muted,
              height: 1.55,
            ),
          ),
          if (actionLabel != null && onAction != null) ...[
            SizedBox(height: compact ? 16 : 20),
            SizedBox(
              width: compact ? 148 : 168,
              child: PrimaryButton(
                label: actionLabel!,
                onPressed: onAction,
                expanded: true,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
