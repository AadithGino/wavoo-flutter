import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../../controllers/auth_controller.dart';
import '../../core/constants/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/utils/phone.dart';
import '../widgets/delete_account_sheet.dart';
import '../widgets/primary_button.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  final _phoneController = TextEditingController();
  final _otpController = TextEditingController();
  final _nameController = TextEditingController();

  final _phoneFocus = FocusNode();
  final _otpFocus = FocusNode();
  final _nameFocus = FocusNode();

  Worker? _stepWorker;
  int _lastStep = -1;

  @override
  void initState() {
    super.initState();
    final auth = Get.find<AuthController>();
    _lastStep = auth.otpStep.value;
    _stepWorker = ever<int>(auth.otpStep, _onStepChanged);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _focusForStep(auth.otpStep.value);
    });
  }

  void _onStepChanged(int step) {
    if (!mounted || step == _lastStep) return;
    _lastStep = step;
    if (step == 1) {
      _otpController.clear();
    } else if (step == 2) {
      _nameController.clear();
    } else if (step == 0) {
      _otpController.clear();
      _nameController.clear();
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _focusForStep(step);
    });
  }

  Future<void> _focusForStep(int step) async {
    // Force keyboard type to reset when switching phone → OTP → name.
    FocusManager.instance.primaryFocus?.unfocus();
    await SystemChannels.textInput.invokeMethod<void>('TextInput.hide');
    await Future<void>.delayed(const Duration(milliseconds: 80));
    if (!mounted) return;
    switch (step) {
      case 0:
        _phoneFocus.requestFocus();
      case 1:
        _otpFocus.requestFocus();
      case 2:
        _nameFocus.requestFocus();
    }
  }

  @override
  void dispose() {
    _stepWorker?.dispose();
    _phoneController.dispose();
    _otpController.dispose();
    _nameController.dispose();
    _phoneFocus.dispose();
    _otpFocus.dispose();
    _nameFocus.dispose();
    super.dispose();
  }

  InputDecoration _fieldDecoration({
    required String label,
    String? hint,
    String? prefixText,
  }) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      prefixText: prefixText,
      filled: true,
      fillColor: Colors.white,
      labelStyle: AppTypography.sans(size: 13, color: AppColors.muted),
      hintStyle: AppTypography.sans(size: 14, color: AppColors.muted),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: AppColors.line),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: AppColors.line),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: AppColors.gold, width: 1.6),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = Get.find<AuthController>();
    return Scaffold(
      backgroundColor: AppColors.cream,
      body: SafeArea(
        child: Obx(() {
          final step = auth.otpStep.value;
          return ListView(
            padding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            children: [
              Center(
                child: Image.asset(
                  'assets/images/logo.png',
                  width: 120,
                  height: 120,
                  cacheWidth: 240,
                  cacheHeight: 240,
                  fit: BoxFit.contain,
                ),
              ),
              const SizedBox(height: 18),
              Text(
                step == 0
                    ? 'Welcome to Wavoo'
                    : step == 1
                        ? 'Verify OTP'
                        : 'Complete your profile',
                textAlign: TextAlign.center,
                style: AppTypography.serif(size: 28, height: 1.1),
              ),
              const SizedBox(height: 8),
              Text(
                step == 0
                    ? 'Sign in with your mobile number to shop and manage gold schemes.'
                    : step == 1
                        ? 'Enter the 6-digit code sent to ${PhoneUtils.display(auth.mobile.value)}'
                        : 'Enter your full name to finish creating your Wavoo account.',
                textAlign: TextAlign.center,
                style: AppTypography.sans(
                  size: 14,
                  color: AppColors.muted,
                  height: 1.45,
                ),
              ),
              const SizedBox(height: 28),
              if (step == 0)
                TextField(
                  key: const ValueKey('login-phone'),
                  controller: _phoneController,
                  focusNode: _phoneFocus,
                  keyboardType: TextInputType.phone,
                  textInputAction: TextInputAction.done,
                  autofillHints: const [AutofillHints.telephoneNumber],
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(10),
                  ],
                  onSubmitted: (_) => auth.requestOtp(_phoneController.text),
                  decoration: _fieldDecoration(
                    label: 'Mobile number',
                    hint: '9876543210',
                    prefixText: '+91 ',
                  ),
                )
              else if (step == 1) ...[
                _OtpPinField(
                  key: const ValueKey('login-otp'),
                  controller: _otpController,
                  focusNode: _otpFocus,
                  length: 6,
                  enabled: !auth.isLoading.value,
                  onCompleted: (code) => auth.verifyOtp(code),
                ),
                const SizedBox(height: 8),
                Align(
                  alignment: Alignment.centerLeft,
                  child: TextButton(
                    onPressed: auth.isLoading.value || auth.resendSecondsLeft.value > 0
                        ? null
                        : () async {
                            final ok = await auth.requestOtp(auth.mobile.value);
                            if (ok && mounted) {
                              _otpController.clear();
                              _otpFocus.requestFocus();
                            }
                          },
                    child: Text(
                      auth.resendSecondsLeft.value > 0
                          ? 'Resend OTP in ${auth.resendSecondsLeft.value}s'
                          : 'Resend OTP',
                    ),
                  ),
                ),
              ] else
                TextField(
                  key: const ValueKey('login-name'),
                  controller: _nameController,
                  focusNode: _nameFocus,
                  keyboardType: TextInputType.name,
                  textInputAction: TextInputAction.done,
                  textCapitalization: TextCapitalization.words,
                  autofillHints: const [AutofillHints.name],
                  enableSuggestions: true,
                  autocorrect: true,
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(
                      RegExp(r"[a-zA-Z\s.'-]"),
                    ),
                    LengthLimitingTextInputFormatter(120),
                  ],
                  onSubmitted: (_) => auth.register(_nameController.text),
                  decoration: _fieldDecoration(
                    label: 'Full name',
                    hint: 'Your name',
                  ),
                ),
              if (auth.errorMessage.value != null) ...[
                const SizedBox(height: 12),
                Text(
                  auth.errorMessage.value!,
                  style: AppTypography.sans(
                    size: 13,
                    color: Colors.red.shade700,
                  ),
                ),
              ],
              const SizedBox(height: 24),
              PrimaryButton(
                label: step == 0
                    ? 'CONTINUE'
                    : step == 1
                        ? 'VERIFY OTP'
                        : 'CREATE ACCOUNT',
                loading: auth.isLoading.value,
                onPressed: () {
                  if (step == 0) {
                    auth.requestOtp(_phoneController.text);
                  } else if (step == 1) {
                    auth.verifyOtp(_otpController.text);
                  } else {
                    auth.register(_nameController.text);
                  }
                },
              ),
              if (step > 0)
                TextButton(
                  onPressed: auth.isLoading.value
                      ? null
                      : () {
                          _otpController.clear();
                          _nameController.clear();
                          auth.resetToPhone();
                        },
                  child: const Text('Use a different number'),
                )
              else
                TextButton(
                  onPressed: () => showDeleteAccountSheet(
                    phone: _phoneController.text,
                  ),
                  child: Text(
                    'Delete account',
                    style: AppTypography.sans(
                      size: 12,
                      weight: FontWeight.w600,
                      color: AppColors.muted,
                    ),
                  ),
                ),
            ],
          );
        }),
      ),
    );
  }
}

class _OtpPinField extends StatefulWidget {
  const _OtpPinField({
    required this.controller,
    required this.focusNode,
    required this.length,
    required this.onCompleted,
    this.enabled = true,
    super.key,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final int length;
  final ValueChanged<String> onCompleted;
  final bool enabled;

  @override
  State<_OtpPinField> createState() => _OtpPinFieldState();
}

class _OtpPinFieldState extends State<_OtpPinField> {
  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onChanged);
  }

  @override
  void didUpdateWidget(covariant _OtpPinField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller.removeListener(_onChanged);
      widget.controller.addListener(_onChanged);
    }
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onChanged);
    super.dispose();
  }

  void _onChanged() {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final value = widget.controller.text;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: widget.enabled
          ? () {
              widget.focusNode.requestFocus();
              SystemChannels.textInput.invokeMethod<void>('TextInput.show');
            }
          : null,
      child: Stack(
        children: [
          Opacity(
            opacity: 0,
            child: SizedBox(
              height: 1,
              child: TextField(
                controller: widget.controller,
                focusNode: widget.focusNode,
                enabled: widget.enabled,
                keyboardType: TextInputType.number,
                textInputAction: TextInputAction.done,
                autofillHints: const [AutofillHints.oneTimeCode],
                showCursor: false,
                enableInteractiveSelection: false,
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  isCollapsed: true,
                ),
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(widget.length),
                ],
                onChanged: (text) {
                  if (text.length == widget.length) {
                    widget.onCompleted(text);
                  }
                },
                onSubmitted: (text) {
                  if (text.length >= 4) widget.onCompleted(text);
                },
              ),
            ),
          ),
          Row(
            children: List.generate(widget.length, (index) {
              final char = index < value.length ? value[index] : '';
              final isActive = widget.focusNode.hasFocus &&
                  index == value.length.clamp(0, widget.length - 1);
              return Expanded(
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 120),
                  margin: EdgeInsets.only(
                    left: index == 0 ? 0 : 4,
                    right: index == widget.length - 1 ? 0 : 4,
                  ),
                  height: 56,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isActive ? AppColors.gold : AppColors.line,
                      width: isActive ? 1.8 : 1,
                    ),
                    boxShadow: isActive
                        ? [
                            BoxShadow(
                              color: AppColors.gold.withValues(alpha: 0.18),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ]
                        : null,
                  ),
                  child: Text(
                    char.isEmpty ? '·' : char,
                    style: AppTypography.sans(
                      size: 22,
                      weight: FontWeight.w700,
                      color: char.isEmpty ? AppColors.muted : AppColors.ink,
                    ),
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}
