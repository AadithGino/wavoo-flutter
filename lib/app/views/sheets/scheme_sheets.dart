import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../controllers/scheme_controller.dart';
import '../../core/constants/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/utils/money.dart';
import '../../data/models/scheme.dart';
import '../widgets/primary_button.dart';
import 'sheet_scaffold.dart';

Future<void> showSchemeDetailsSheet() async {
  final scheme = Get.find<SchemeController>();
  final enrollment = scheme.activeEnrollment;
  await openAppSheet(
    Column(
      children: [
        sheetHeader('Scheme details'),
        Expanded(
          child: enrollment == null
              ? const Center(child: Text('No active scheme yet'))
              : ListView(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                  children: [
                    Text(enrollment.planName, style: AppTypography.serif(size: 24)),
                    const SizedBox(height: 8),
                    Text(
                      '${enrollment.paidInstallments}/${enrollment.totalInstallments} instalments · ${enrollment.status}',
                      style: AppTypography.sans(size: 13, color: AppColors.muted),
                    ),
                    const SizedBox(height: 16),
                    _kv('Monthly', Money.fromPaise(enrollment.amountPaise)),
                    _kv('Saved', Money.fromPaise(enrollment.savedPaise)),
                    _kv('Passbook', enrollment.passbookNumber.isEmpty ? '—' : enrollment.passbookNumber),
                    _kv('Joined', scheme.dateLabel(enrollment.joinedAt)),
                    const SizedBox(height: 16),
                    Text('Schedule', style: AppTypography.serif(size: 18)),
                    const SizedBox(height: 8),
                    if (enrollment.installments.isEmpty)
                      const Text('Installment schedule will appear after enrollment sync.')
                    else
                      ...enrollment.installments.map(
                        (item) => ListTile(
                          contentPadding: EdgeInsets.zero,
                          title: Text('Instalment ${item.sequenceNumber}'),
                          subtitle: Text(
                            '${scheme.dateLabel(item.dueDate)} · ${item.status}',
                          ),
                          trailing: Text(Money.fromPaise(item.amountPaise)),
                        ),
                      ),
                  ],
                ),
        ),
      ],
    ),
  );
}

Widget _kv(String label, String value) => Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Expanded(child: Text(label, style: AppTypography.sans(color: AppColors.muted))),
          Text(value, style: AppTypography.sans(weight: FontWeight.w700)),
        ],
      ),
    );

Future<void> showSchemeEnrollmentSheet() async {
  final scheme = Get.find<SchemeController>();
  if (scheme.catalogue.isEmpty) {
    await scheme.load();
  }
  await openAppSheet(
    Obx(() {
      final items = scheme.catalogue;
      final selected = scheme.selectedCatalogueItem.value;
      return Column(
        children: [
          sheetHeader('Enroll in a scheme'),
          Expanded(
            child: items.isEmpty
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Text(
                        scheme.loadError.value ??
                            'No published schemes are available right now.',
                        textAlign: TextAlign.center,
                      ),
                    ),
                  )
                : ListView(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                    children: [
                      Text(
                        'Choose a published Wavoo gold plan. Monthly amount and tenure come from the scheme rules.',
                        style: AppTypography.sans(size: 13, color: AppColors.muted, height: 1.45),
                      ),
                      const SizedBox(height: 14),
                      for (final item in items) ...[
                        InkWell(
                          onTap: () => scheme.selectCatalogueItem(item),
                          borderRadius: BorderRadius.circular(12),
                          child: Container(
                            margin: const EdgeInsets.only(bottom: 10),
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: selected?.templateId == item.templateId
                                  ? AppColors.cream
                                  : Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: selected?.templateId == item.templateId
                                    ? AppColors.gold
                                    : AppColors.line,
                                width: selected?.templateId == item.templateId ? 2 : 1,
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        item.name,
                                        style: AppTypography.serif(size: 18),
                                      ),
                                    ),
                                    if (item.isFeatured)
                                      const Text(
                                        'Featured',
                                        style: TextStyle(
                                          color: AppColors.goldDark,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                  ],
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  item.shortDescription.isEmpty
                                      ? item.description
                                      : item.shortDescription,
                                  style: AppTypography.sans(
                                    size: 13,
                                    color: AppColors.muted,
                                  ),
                                ),
                                const SizedBox(height: 10),
                                Text(
                                  item.amountPaise > 0 && item.totalInstallments > 0
                                      ? '${Money.fromPaise(item.amountPaise)} / month · ${item.totalInstallments} months · Goal ${Money.fromPaise(item.goalPaise)}'
                                      : 'Scheme rules unavailable',
                                  style: AppTypography.sans(
                                    size: 13,
                                    weight: FontWeight.w700,
                                    color: AppColors.goldDark,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                      const SizedBox(height: 8),
                      SizedBox(
                        height: 48,
                        child: FilledButton(
                          onPressed: scheme.paymentBusy.value
                              ? null
                              : scheme.joinSelectedScheme,
                          child: scheme.paymentBusy.value
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : const Text('START MY GOLD SAVINGS'),
                        ),
                      ),
                    ],
                  ),
          ),
        ],
      );
    }),
  );
}

Future<void> showSchemePaymentSheet() async {
  final scheme = Get.find<SchemeController>();
  final enrollment = scheme.activeEnrollment;
  PaymentPreview? preview;
  try {
    preview = await scheme.loadPaymentPreview();
  } catch (_) {}

  await openAppSheet(
    Obx(() {
      final busy = scheme.paymentBusy.value;
      final status = scheme.paymentStatus.value;
      final intent = scheme.lastIntent.value;
      final amount = preview?.amountPaise ?? enrollment?.amountPaise ?? 0;
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          sheetHeader('Pay Monthly Instalment'),
          Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              children: [
                const Icon(
                  Icons.verified_user_outlined,
                  size: 44,
                  color: AppColors.gold,
                ),
                const SizedBox(height: 12),
                Text(
                  amount > 0 ? Money.fromPaise(amount) : '—',
                  style: AppTypography.serif(size: 32),
                ),
                const SizedBox(height: 6),
                Text(
                  preview?.paymentAllowed == false
                      ? (preview?.validationMessage ?? 'Payment not allowed')
                      : 'Secure PhonePe checkout for your Wavoo Gold Scheme',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: AppColors.muted),
                ),
                if (status != null) ...[
                  const SizedBox(height: 12),
                  Text(
                    status,
                    textAlign: TextAlign.center,
                    style: AppTypography.sans(
                      size: 13,
                      color: intent?.isSuccess == true
                          ? AppColors.successDark
                          : AppColors.muted,
                    ),
                  ),
                ],
                if (intent?.receiptNumber != null) ...[
                  const SizedBox(height: 8),
                  Text('Receipt ${intent!.receiptNumber}'),
                ],
                const SizedBox(height: 20),
                PrimaryButton(
                  label: busy
                      ? 'PROCESSING…'
                      : intent?.isSuccess == true
                          ? 'DONE'
                          : 'PAY SECURELY',
                  onPressed: () {
                    if (busy || preview?.paymentAllowed == false) return;
                    unawaited(() async {
                      if (intent?.isSuccess == true) {
                        Get.back<void>();
                        return;
                      }
                      final result = await scheme.payInstallment();
                      if (result?.isSuccess == true &&
                          (enrollment?.isMatured == true ||
                              (enrollment != null &&
                                  enrollment.paidInstallments + 1 >=
                                      enrollment.totalInstallments))) {
                        await Future<void>.delayed(
                          const Duration(milliseconds: 350),
                        );
                        await showRedemptionSheet();
                      }
                    }());
                  },
                ),
              ],
            ),
          ),
        ],
      );
    }),
  );
}

Future<void> showRedemptionSheet() async {
  final scheme = Get.find<SchemeController>();
  await scheme.loadRedemptionEligibility();
  await openAppSheet(
    Obx(() {
      final enrollment = scheme.activeEnrollment;
      final eligibility = scheme.eligibility.value;
      final existing = scheme.lastRedemption.value;
      final busy = scheme.redemptionBusy.value;
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          sheetHeader('Redeem your savings'),
          Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              children: [
                Text(
                  eligibility?.canRequest == true
                      ? 'Your plan can be redeemed at the showroom. We will confirm the request with Wavoo.'
                      : (eligibility?.blockingReason ??
                          (enrollment == null
                              ? 'No active scheme to redeem.'
                              : 'Redemption is available once your plan matures.')),
                  style: AppTypography.sans(size: 14, color: AppColors.muted),
                  textAlign: TextAlign.center,
                ),
                if (eligibility != null && eligibility.totalRedeemablePaise > 0) ...[
                  const SizedBox(height: 12),
                  Text(
                    Money.fromPaise(eligibility.totalRedeemablePaise),
                    style: AppTypography.serif(size: 28),
                  ),
                  const Text('Redeemable value'),
                ],
                if (existing != null) ...[
                  const SizedBox(height: 12),
                  Text(
                    '${existing.redemptionNumber} · ${existing.status}',
                    style: AppTypography.sans(size: 13, color: AppColors.goldDark),
                  ),
                ],
                const SizedBox(height: 16),
                PrimaryButton(
                  label: busy
                      ? 'SUBMITTING…'
                      : existing?.isOpen == true
                          ? 'REQUEST SUBMITTED'
                          : 'REDEEM AT SHOWROOM',
                  onPressed: () {
                    if (busy || eligibility?.canRequest != true) return;
                    unawaited(() async {
                      final created = await scheme.requestRedemption();
                      if (created != null) Get.back<void>();
                    }());
                  },
                ),
              ],
            ),
          ),
        ],
      );
    }),
  );
}

Future<void> showContactSheet() async {
  await openAppSheet(
    Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        sheetHeader('Contact Wavoo'),
        ListTile(
          leading: const Icon(Icons.phone, color: AppColors.goldDark),
          title: const Text('Call us'),
          subtitle: const Text('+91 89251 62888'),
          onTap: () => launchUrl(Uri.parse('tel:+918925162888')),
        ),
        ListTile(
          leading: const Icon(Icons.chat_bubble_outline, color: AppColors.goldDark),
          title: const Text('WhatsApp'),
          onTap: () => launchUrl(Uri.parse('https://wa.me/918925162888')),
        ),
        const SizedBox(height: 12),
      ],
    ),
  );
}
