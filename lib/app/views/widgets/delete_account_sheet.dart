import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../../controllers/auth_controller.dart';
import '../../core/constants/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/utils/phone.dart';
import 'primary_button.dart';

Future<void> showDeleteAccountSheet({String? phone, bool lockPhone = false}) {
  return Get.dialog<void>(
    _DeleteAccountDialog(initialPhone: phone, lockPhone: lockPhone),
    barrierDismissible: false,
  );
}

class _DeleteAccountDialog extends StatefulWidget {
  const _DeleteAccountDialog({
    this.initialPhone,
    this.lockPhone = false,
  });

  final String? initialPhone;
  final bool lockPhone;

  @override
  State<_DeleteAccountDialog> createState() => _DeleteAccountDialogState();
}

class _DeleteAccountDialogState extends State<_DeleteAccountDialog> {
  late final TextEditingController _phoneController;
  final _reasonController = TextEditingController();
  bool _submitting = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    final digits = (widget.initialPhone ?? '')
        .replaceAll(RegExp(r'\D'), '')
        .replaceFirst(RegExp(r'^91'), '');
    _phoneController = TextEditingController(
      text: digits.length > 10 ? digits.substring(digits.length - 10) : digits,
    );
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _reasonController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_submitting) return;
    final auth = Get.find<AuthController>();
    setState(() {
      _submitting = true;
      _error = null;
    });
    final result = await auth.requestAccountDeletion(
      phone: _phoneController.text,
      reason: _reasonController.text,
    );
    if (!mounted) return;
    if (result == null) {
      setState(() {
        _submitting = false;
        _error = auth.errorMessage.value ??
            'Could not submit the request. Please try again.';
      });
      return;
    }
    Get.back<void>();
    Get.showSnackbar(
      GetSnackBar(
        duration: const Duration(seconds: 4),
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.fromLTRB(20, 0, 20, 88),
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 11),
        borderRadius: 20,
        backgroundColor: const Color(0xFF211D18),
        messageText: Text(
          'Deletion request submitted for ${PhoneUtils.display(result.phone.isEmpty ? auth.accountPhone : result.phone)}. Wavoo will review it — your account is not removed immediately.',
          textAlign: TextAlign.center,
          style: AppTypography.sans(size: 11, color: Colors.white, height: 1.4),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Text('Delete account?', style: AppTypography.serif(size: 20)),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'This sends a request for review. Your account, schemes and orders are not wiped immediately.',
              style: AppTypography.sans(
                size: 12,
                color: AppColors.muted,
                height: 1.45,
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _phoneController,
              enabled: !widget.lockPhone && !_submitting,
              keyboardType: TextInputType.phone,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(10),
              ],
              decoration: InputDecoration(
                labelText: 'Mobile number',
                prefixText: '+91 ',
                labelStyle: AppTypography.sans(size: 12, color: AppColors.muted),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _reasonController,
              enabled: !_submitting,
              maxLines: 3,
              maxLength: 240,
              decoration: InputDecoration(
                labelText: 'Reason (optional)',
                alignLabelWithHint: true,
                labelStyle: AppTypography.sans(size: 12, color: AppColors.muted),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            if (_error != null) ...[
              const SizedBox(height: 4),
              Text(
                _error!,
                style: AppTypography.sans(
                  size: 12,
                  color: Colors.red.shade700,
                  height: 1.35,
                ),
              ),
            ],
          ],
        ),
      ),
      actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      actions: [
        TextButton(
          onPressed: _submitting ? null : () => Get.back<void>(),
          child: Text(
            'CANCEL',
            style: AppTypography.sans(
              size: 11,
              weight: FontWeight.w700,
              color: AppColors.muted,
            ),
          ),
        ),
        const SizedBox(height: 8),
        PrimaryButton(
          label: 'REQUEST DELETION',
          loading: _submitting,
          onPressed: _submit,
        ),
      ],
    );
  }
}
