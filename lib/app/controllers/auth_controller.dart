import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../core/network/api_exception.dart';
import '../core/utils/phone.dart';
import '../data/models/user.dart';
import '../data/repositories/auth_repository.dart';
import '../data/repositories/profile_repository.dart';
import '../views/app_shell_view.dart';
import '../views/screens/login_view.dart';
import 'home_controller.dart';
import 'scheme_controller.dart';
import 'shop_controller.dart';

class AuthController extends GetxController {
  AuthController({
    required AuthRepository authRepository,
    required ProfileRepository profileRepository,
  })  : _auth = authRepository,
        _profile = profileRepository;

  final AuthRepository _auth;
  final ProfileRepository _profile;

  final isBootstrapping = true.obs;
  final isLoading = false.obs;
  final isAuthenticated = false.obs;
  final user = Rxn<AppUser>();
  final profile = Rxn<CustomerProfile>();
  final errorMessage = RxnString();

  final mobile = ''.obs;
  final challengeId = ''.obs;
  final registrationToken = ''.obs;
  final otpStep = 0.obs; // 0 phone, 1 otp, 2 register
  final resendSecondsLeft = 0.obs;

  Timer? _resendTimer;

  @override
  void onClose() {
    _resendTimer?.cancel();
    super.onClose();
  }

  Future<bool> bootstrap() async {
    isBootstrapping.value = true;
    try {
      final session = await _auth.currentSession();
      if (session == null) {
        isAuthenticated.value = false;
        return false;
      }
      user.value = session;
      isAuthenticated.value = true;
      await refreshProfile();
      return true;
    } catch (_) {
      isAuthenticated.value = false;
      return false;
    } finally {
      isBootstrapping.value = false;
    }
  }

  Future<void> refreshProfile() async {
    try {
      profile.value = await _profile.fetchProfile();
      final p = profile.value;
      if (p != null && (user.value?.name.isEmpty ?? true)) {
        user.value = AppUser(
          id: user.value?.id ?? p.id,
          name: p.displayName,
          phone: p.phone ?? user.value?.phone ?? '',
        );
      }
      if (p != null && Get.isRegistered<ShopController>()) {
        Get.find<ShopController>().applyProfileAddress(p);
      }
    } catch (_) {
      // Profile may fail if customer record missing; keep session.
    }
  }

  Future<bool> requestOtp(String rawMobile) async {
    errorMessage.value = null;
    final normalized = PhoneUtils.normalizeIndian(rawMobile);
    if (normalized == null) {
      errorMessage.value = 'Enter a valid 10-digit Indian mobile number';
      return false;
    }
    if (resendSecondsLeft.value > 0 && mobile.value == normalized) {
      errorMessage.value =
          'Please wait ${resendSecondsLeft.value}s before requesting another OTP';
      return false;
    }
    isLoading.value = true;
    try {
      final challenge = await _auth.requestOtp(normalized);
      if (challenge.challengeId.isEmpty) {
        errorMessage.value = 'Could not start OTP verification. Try again.';
        return false;
      }
      mobile.value = normalized;
      challengeId.value = challenge.challengeId;
      otpStep.value = 1;
      _startResendCooldown(challenge.resendAfterSeconds);
      return true;
    } on ApiException catch (e) {
      errorMessage.value = e.message;
      return false;
    } catch (e) {
      errorMessage.value = e.toString();
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> verifyOtp(String otp) async {
    errorMessage.value = null;
    final code = otp.trim();
    if (!RegExp(r'^\d{4,8}$').hasMatch(code)) {
      errorMessage.value = 'Enter the 4–8 digit OTP from SMS';
      return false;
    }
    if (challengeId.value.isEmpty || mobile.value.isEmpty) {
      errorMessage.value = 'Request a new OTP first';
      otpStep.value = 0;
      return false;
    }
    isLoading.value = true;
    try {
      final result = await _auth.verifyOtp(
        mobileRaw: mobile.value,
        challengeId: challengeId.value,
        otp: code,
      );
      if (result.registrationRequired) {
        final token = result.registrationToken?.trim() ?? '';
        if (token.isEmpty) {
          errorMessage.value =
              'Registration session missing. Please request OTP again.';
          otpStep.value = 0;
          return false;
        }
        registrationToken.value = token;
        otpStep.value = 2;
        return true;
      }
      final sessionUser = result.user;
      if (sessionUser == null || sessionUser.id.isEmpty) {
        errorMessage.value = 'Login succeeded but user data was empty.';
        return false;
      }
      user.value = sessionUser;
      isAuthenticated.value = true;
      await refreshProfile();
      _goHome();
      return true;
    } on ApiException catch (e) {
      errorMessage.value = e.message;
      return false;
    } catch (e) {
      errorMessage.value = e.toString();
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> register(String name) async {
    errorMessage.value = null;
    final trimmed = name.trim();
    if (trimmed.length < 2) {
      errorMessage.value = 'Please enter your full name';
      return false;
    }
    if (registrationToken.value.isEmpty) {
      errorMessage.value = 'Registration session expired. Verify OTP again.';
      otpStep.value = 0;
      return false;
    }
    isLoading.value = true;
    try {
      final registered = await _auth.register(
        registrationToken: registrationToken.value,
        name: trimmed,
      );
      user.value = registered;
      isAuthenticated.value = true;
      await refreshProfile();
      _goHome();
      return true;
    } on ApiException catch (e) {
      errorMessage.value = e.message;
      if (e.code == 'REGISTRATION_TOKEN_INVALID' || e.statusCode == 401) {
        registrationToken.value = '';
        otpStep.value = 0;
      }
      return false;
    } catch (e) {
      errorMessage.value = e.toString();
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> logout() async {
    await _auth.logout();
    user.value = null;
    profile.value = null;
    isAuthenticated.value = false;
    otpStep.value = 0;
    mobile.value = '';
    challengeId.value = '';
    registrationToken.value = '';
    resendSecondsLeft.value = 0;
    _resendTimer?.cancel();
    Get.offAll(() => const LoginView());
  }

  void handleSessionExpired() {
    user.value = null;
    profile.value = null;
    isAuthenticated.value = false;
    if (Get.currentRoute.contains('Login')) return;
    Get.offAll(() => const LoginView());
    Get.showSnackbar(
      const GetSnackBar(
        message: 'Session expired. Please sign in again.',
        duration: Duration(seconds: 3),
        margin: EdgeInsets.all(16),
        borderRadius: 12,
      ),
    );
  }

  void resetToPhone() {
    otpStep.value = 0;
    challengeId.value = '';
    registrationToken.value = '';
    errorMessage.value = null;
    resendSecondsLeft.value = 0;
    _resendTimer?.cancel();
  }

  void _startResendCooldown(int seconds) {
    _resendTimer?.cancel();
    resendSecondsLeft.value = seconds <= 0 ? 30 : seconds;
    _resendTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (resendSecondsLeft.value <= 1) {
        resendSecondsLeft.value = 0;
        timer.cancel();
        return;
      }
      resendSecondsLeft.value = resendSecondsLeft.value - 1;
    });
  }

  void _goHome() {
    unawaited(Get.find<ShopController>().loadProducts());
    unawaited(Get.find<ShopController>().loadOrders());
    unawaited(Get.find<SchemeController>().load());
    if (Get.isRegistered<HomeController>()) {
      unawaited(Get.find<HomeController>().load());
    }
    Get.offAll(() => const AppShellView());
  }
}
