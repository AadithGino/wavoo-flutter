import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';

import '../../controllers/scheme_controller.dart';
import '../../core/constants/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/utils/money.dart';
import '../../core/utils/transaction_invoice.dart';
import '../../data/models/activity.dart';
import '../../data/models/scheme.dart';
import '../../data/repositories/activity_repository.dart';
import '../../data/repositories/scheme_repository.dart';
import 'sheets.dart';
import 'shimmers.dart';

Future<T?> _openHistorySheet<T>(Widget child) {
  return Get.bottomSheet<T>(
    SafeArea(
      top: false,
      child: Container(
        constraints: BoxConstraints(maxHeight: Get.height * 0.88),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
        ),
        child: child,
      ),
    ),
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
  );
}

Widget _historyHeader(String title) => Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const SizedBox(height: 9),
        Container(
          width: 42,
          height: 4,
          decoration: BoxDecoration(
            color: AppColors.line,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(17, 8, 9, 8),
          child: Row(
            children: [
              Expanded(
                child: Text(title, style: AppTypography.serif(size: 22)),
              ),
              IconButton(
                onPressed: Get.back,
                icon: SvgPicture.asset(
                  'assets/svg/close.svg',
                  width: 20,
                  height: 20,
                ),
              ),
            ],
          ),
        ),
        const Divider(height: 1),
      ],
    );

String _dateLabel(DateTime? date) {
  if (date == null) return '—';
  const months = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];
  return '${date.day} ${months[date.month - 1]} ${date.year}';
}

String _monthLabel(DateTime date) {
  const months = [
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December',
  ];
  return '${months[date.month - 1]} ${date.year}';
}

Future<void> showTransactionsSheet() {
  return _openHistorySheet(const _TransactionsSheet());
}

Future<void> showPastSchemesSheet() {
  return _openHistorySheet(const _PastSchemesSheet());
}

Future<void> showRedemptionHistorySheet() {
  return _openHistorySheet(const _RedemptionHistorySheet());
}

class _TransactionsSheet extends StatefulWidget {
  const _TransactionsSheet();

  @override
  State<_TransactionsSheet> createState() => _TransactionsSheetState();
}

class _TransactionsSheetState extends State<_TransactionsSheet> {
  String _filter = 'all';
  bool _loading = true;
  String? _error;
  List<CustomerTransaction> _items = const [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final items = await Get.find<ActivityRepository>().fetchTransactions(
        type: _filter,
      );
      if (!mounted) return;
      setState(() {
        _items = items;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _historyHeader('All transactions'),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
          child: Row(
            children: [
              _chip('all', 'All'),
              const SizedBox(width: 7),
              _chip('scheme', 'Schemes'),
              const SizedBox(width: 7),
              _chip('shopping', 'Shopping'),
            ],
          ),
        ),
        Expanded(
          child: _loading
              ? const SheetListShimmer()
              : _error != null
                  ? Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Text(
                          _error!,
                          textAlign: TextAlign.center,
                          style: AppTypography.sans(
                            size: 12,
                            color: AppColors.muted,
                          ),
                        ),
                      ),
                    )
                  : _items.isEmpty
                      ? Center(
                          child: Text(
                            'No transactions in this category.',
                            style: AppTypography.sans(
                              size: 12,
                              color: AppColors.muted,
                            ),
                          ),
                        )
                      : ListView(
                          padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
                          children: [
                            for (final group in _grouped(_items).entries) ...[
                              Padding(
                                padding: const EdgeInsets.only(
                                  top: 13,
                                  bottom: 7,
                                ),
                                child: Text(
                                  group.key,
                                  style: AppTypography.sans(
                                    size: 9,
                                    weight: FontWeight.w800,
                                    color: AppColors.muted,
                                    letterSpacing: .11,
                                  ),
                                ),
                              ),
                              for (final item in group.value) ...[
                                _TransactionRow(item: item),
                                const SizedBox(height: 10),
                              ],
                            ],
                          ],
                        ),
        ),
      ],
    );
  }

  Widget _chip(String value, String label) {
    final active = _filter == value;
    return GestureDetector(
      onTap: () {
        if (_filter == value) return;
        _filter = value;
        _load();
      },
      child: Container(
        height: 31,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: active ? AppColors.cream : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: active ? AppColors.gold : AppColors.line,
          ),
        ),
        child: Text(
          label,
          style: AppTypography.sans(
            size: 9,
            weight: FontWeight.w800,
            color: active ? AppColors.goldDark : AppColors.muted,
          ),
        ),
      ),
    );
  }

  Map<String, List<CustomerTransaction>> _grouped(
    List<CustomerTransaction> items,
  ) {
    final grouped = <String, List<CustomerTransaction>>{};
    for (final item in items) {
      final date = item.date ?? DateTime.now();
      final key = _monthLabel(date);
      grouped.putIfAbsent(key, () => []).add(item);
    }
    return grouped;
  }
}

class _TransactionRow extends StatefulWidget {
  const _TransactionRow({required this.item});

  final CustomerTransaction item;

  @override
  State<_TransactionRow> createState() => _TransactionRowState();
}

class _TransactionRowState extends State<_TransactionRow> {
  bool _busy = false;

  Future<void> _downloadInvoice() async {
    if (_busy) return;
    setState(() => _busy = true);
    try {
      await TransactionInvoice.download(widget.item);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final item = widget.item;
    final shopping = item.isShopping;
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(13),
      child: InkWell(
        onTap: _busy ? null : _downloadInvoice,
        borderRadius: BorderRadius.circular(13),
        child: Container(
          padding: const EdgeInsets.fromLTRB(12, 13, 10, 13),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(13),
            border: Border.all(color: AppColors.line),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 36,
                height: 36,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: shopping ? const Color(0xFFEEF3F7) : AppColors.cream,
                  shape: BoxShape.circle,
                ),
                child: Text(
                  shopping ? '◇' : '₹',
                  style: AppTypography.sans(
                    size: 13,
                    weight: FontWeight.w800,
                    color: shopping
                        ? const Color(0xFF476277)
                        : AppColors.goldDark,
                  ),
                ),
              ),
              const SizedBox(width: 11),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: AppTypography.sans(
                        size: 12,
                        weight: FontWeight.w700,
                        height: 1.25,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      [
                        _dateLabel(item.date),
                        if (item.detail.trim().isNotEmpty) item.detail.trim(),
                      ].join(' · '),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTypography.sans(
                        size: 10,
                        color: AppColors.muted,
                        height: 1.35,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Text(
                          Money.fromPaise(item.amountPaise),
                          style: AppTypography.sans(
                            size: 13,
                            weight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 7,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.successSoft,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            item.status.toUpperCase(),
                            style: AppTypography.sans(
                              size: 8,
                              weight: FontWeight.w800,
                              color: AppColors.successDark,
                              letterSpacing: .3,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              _DownloadAffordance(busy: _busy),
            ],
          ),
        ),
      ),
    );
  }
}

class _DownloadAffordance extends StatelessWidget {
  const _DownloadAffordance({required this.busy});

  final bool busy;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: AppColors.cream,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.goldBorder),
      ),
      alignment: Alignment.center,
      child: busy
          ? const SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(
                strokeWidth: 1.8,
                color: AppColors.goldDark,
              ),
            )
          : const Icon(
              Icons.download_outlined,
              size: 18,
              color: AppColors.goldDark,
            ),
    );
  }
}

class _PastSchemesSheet extends StatefulWidget {
  const _PastSchemesSheet();

  @override
  State<_PastSchemesSheet> createState() => _PastSchemesSheetState();
}

class _PastSchemesSheetState extends State<_PastSchemesSheet> {
  bool _loading = true;
  String? _error;
  List<SchemeEnrollment> _items = const [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final repo = Get.find<SchemeRepository>();
      final results = await Future.wait([
        repo.fetchEnrollments(lifecycle: 'past', allPages: true),
        repo.fetchRedemptions(),
      ]);
      final enrollments = results[0] as List<SchemeEnrollment>;
      final redemptions = results[1] as List<SchemeRedemption>;
      final byId = {
        for (final item in enrollments)
          if (item.enrollmentId.isNotEmpty) item.enrollmentId: item,
      };
      for (final redemption in redemptions) {
        if (!redemption.isCompleted) continue;
        final id = (redemption.enrollmentId ?? '').trim();
        if (id.isEmpty) {
          final key = redemption.redemptionId;
          if (key.isNotEmpty) {
            byId.putIfAbsent(
                key, () => SchemeEnrollment.fromRedemption(redemption));
          }
          continue;
        }
        byId.putIfAbsent(id, () => SchemeEnrollment.fromRedemption(redemption));
      }
      final items = byId.values.toList()
        ..sort((a, b) {
          final aDate = a.closedAt ?? a.maturityDate;
          final bDate = b.closedAt ?? b.maturityDate;
          if (aDate == null && bDate == null) return 0;
          if (aDate == null) return 1;
          if (bDate == null) return -1;
          return bDate.compareTo(aDate);
        });
      if (!mounted) return;
      setState(() {
        _items = items;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _historyHeader('Past schemes'),
        Expanded(
          child: _loading
              ? const SheetListShimmer()
              : _error != null
                  ? Center(child: Text(_error!))
                  : _items.isEmpty
                      ? Center(
                          child: Text(
                            'No past schemes yet.',
                            style: AppTypography.sans(
                              size: 12,
                              color: AppColors.muted,
                            ),
                          ),
                        )
                      : ListView.separated(
                          padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                          itemCount: _items.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(height: 8),
                          itemBuilder: (_, index) {
                            final item = _items[index];
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
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              item.enrollmentNumber.isEmpty
                                                  ? item.passbookNumber
                                                  : item.enrollmentNumber,
                                              style: AppTypography.sans(
                                                size: 7,
                                                color: AppColors.muted,
                                              ),
                                            ),
                                            const SizedBox(height: 5),
                                            Text(
                                              item.planName,
                                              style: AppTypography.serif(
                                                size: 17,
                                                height: 1.1,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      _StatusBadge(
                                        label: item.isRedeemed
                                            ? 'Redeemed'
                                            : 'Completed',
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 12),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: _MetaBox(
                                          label: 'Total contribution',
                                          value: Money.fromPaise(
                                            item.savedPaise,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 7),
                                      Expanded(
                                        child: _MetaBox(
                                          label: 'Completed on',
                                          value: _dateLabel(
                                            item.closedAt ?? item.maturityDate,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 12),
                                  SizedBox(
                                    width: double.infinity,
                                    height: 36,
                                    child: OutlinedButton(
                                      onPressed: () {
                                        Get.find<SchemeController>()
                                            .selectEnrollment(item);
                                        Get.back<void>();
                                        AppSheets.showSchemeDetails();
                                      },
                                      style: OutlinedButton.styleFrom(
                                        foregroundColor: AppColors.goldDark,
                                        side: const BorderSide(
                                          color: AppColors.goldBorder,
                                        ),
                                      ),
                                      child: Text(
                                        'View payment record',
                                        style: AppTypography.sans(
                                          size: 10,
                                          weight: FontWeight.w700,
                                          color: AppColors.goldDark,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
        ),
      ],
    );
  }
}

class _RedemptionHistorySheet extends StatefulWidget {
  const _RedemptionHistorySheet();

  @override
  State<_RedemptionHistorySheet> createState() =>
      _RedemptionHistorySheetState();
}

class _RedemptionHistorySheetState extends State<_RedemptionHistorySheet> {
  bool _loading = true;
  String? _error;
  List<SchemeRedemption> _items = const [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final items = await Get.find<SchemeRepository>().fetchRedemptions();
      if (!mounted) return;
      setState(() {
        _items = items;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _historyHeader('Redemption history'),
        Expanded(
          child: _loading
              ? const SheetListShimmer()
              : _error != null
                  ? Center(child: Text(_error!))
                  : _items.isEmpty
                      ? Center(
                          child: Text(
                            'No redemptions completed yet.',
                            style: AppTypography.sans(
                              size: 12,
                              color: AppColors.muted,
                            ),
                          ),
                        )
                      : ListView.separated(
                          padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                          itemCount: _items.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(height: 8),
                          itemBuilder: (_, index) {
                            final item = _items[index];
                            return Container(
                              padding: const EdgeInsets.all(15),
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    Color(0xFFFFFDF9),
                                    Color(0xFFF8EDDD)
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(13),
                                border: Border.all(color: AppColors.goldBorder),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const _StatusBadge(label: 'Completed'),
                                  const SizedBox(height: 8),
                                  Text(
                                    item.planName ?? 'Wavoo Gold Saver',
                                    style: AppTypography.serif(size: 18),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    [
                                      if ((item.enrollmentNumber ?? '')
                                          .isNotEmpty)
                                        item.enrollmentNumber,
                                      _dateLabel(
                                        item.completedAt ?? item.requestedAt,
                                      ),
                                    ].join(' · '),
                                    style: AppTypography.sans(
                                      size: 8,
                                      color: AppColors.muted,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    Money.fromPaise(item.requestedAmountPaise),
                                    style: AppTypography.serif(
                                      size: 22,
                                      color: AppColors.goldDark,
                                    ),
                                  ),
                                  const SizedBox(height: 7),
                                  Text(
                                    '${item.mode} redemption\nReference ${item.redemptionNumber.isEmpty ? '—' : item.redemptionNumber}',
                                    style: AppTypography.sans(
                                      size: 9,
                                      color: AppColors.muted,
                                      height: 1.4,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
        ),
      ],
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        color: const Color(0xFFEEE9E0),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label.toUpperCase(),
        style: AppTypography.sans(
          size: 6,
          weight: FontWeight.w900,
          color: const Color(0xFF665C4C),
          letterSpacing: .48,
        ),
      ),
    );
  }
}

class _MetaBox extends StatelessWidget {
  const _MetaBox({required this.label, required this.value});

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
