class SchemeCatalogueItem {
  const SchemeCatalogueItem({
    required this.templateId,
    required this.versionId,
    required this.code,
    required this.slug,
    required this.name,
    required this.shortDescription,
    required this.description,
    required this.termsText,
    required this.amountPaise,
    required this.totalInstallments,
    required this.isFeatured,
    required this.displayOrder,
    this.kycRequired = false,
  });

  final String templateId;
  final String versionId;
  final String code;
  final String slug;
  final String name;
  final String shortDescription;
  final String description;
  final String termsText;
  final int amountPaise;
  final int totalInstallments;
  final bool isFeatured;
  final int displayOrder;
  final bool kycRequired;

  int get amountRupees => amountPaise ~/ 100;
  int get goalPaise => amountPaise * totalInstallments;

  factory SchemeCatalogueItem.fromJson(Map<String, dynamic> json) {
    final template = json['template'] is Map
        ? Map<String, dynamic>.from(json['template'] as Map)
        : <String, dynamic>{};
    final version = json['version'] is Map
        ? Map<String, dynamic>.from(json['version'] as Map)
        : json['publishedVersion'] is Map
            ? Map<String, dynamic>.from(json['publishedVersion'] as Map)
            : <String, dynamic>{};
    final content = json['content'] is Map
        ? Map<String, dynamic>.from(json['content'] as Map)
        : template['content'] is Map
            ? Map<String, dynamic>.from(template['content'] as Map)
            : <String, dynamic>{};
    final rules = json['rules'] is Map
        ? Map<String, dynamic>.from(json['rules'] as Map)
        : version['rules'] is Map
            ? Map<String, dynamic>.from(version['rules'] as Map)
            : template['rules'] is Map
                ? Map<String, dynamic>.from(template['rules'] as Map)
                : <String, dynamic>{};
    final installment = rules['installment'] is Map
        ? Map<String, dynamic>.from(rules['installment'] as Map)
        : <String, dynamic>{};
    final kyc = rules['kyc'] is Map
        ? Map<String, dynamic>.from(rules['kyc'] as Map)
        : <String, dynamic>{};

    final amount = (installment['amountPaise'] as num?)?.toInt() ??
        (json['amountPaise'] as num?)?.toInt() ??
        (json['installmentAmountPaise'] as num?)?.toInt();
    final total = (installment['totalInstallments'] as num?)?.toInt() ??
        (json['totalInstallments'] as num?)?.toInt() ??
        (json['tenureMonths'] as num?)?.toInt();

    return SchemeCatalogueItem(
      templateId: json['templateId']?.toString() ??
          json['id']?.toString() ??
          template['templateId']?.toString() ??
          template['id']?.toString() ??
          '',
      versionId: json['versionId']?.toString() ??
          json['publishedVersionId']?.toString() ??
          version['versionId']?.toString() ??
          version['id']?.toString() ??
          '',
      code: json['code']?.toString() ?? template['code']?.toString() ?? '',
      slug: json['slug']?.toString() ?? template['slug']?.toString() ?? '',
      name: (content['name'] as String?)?.trim() ?? 'Gold Scheme',
      shortDescription: (content['shortDescription'] as String?)?.trim() ?? '',
      description: (content['description'] as String?)?.trim() ?? '',
      termsText: (content['termsText'] as String?)?.trim() ?? '',
      amountPaise: amount != null && amount > 0 ? amount : 0,
      totalInstallments: total != null && total > 0 ? total : 0,
      isFeatured: json['isFeatured'] == true,
      displayOrder: (json['displayOrder'] as num?)?.toInt() ?? 0,
      kycRequired: kyc['requiredForEnrollment'] == true,
    );
  }
}

class SchemeEnrollment {
  const SchemeEnrollment({
    required this.enrollmentId,
    required this.enrollmentNumber,
    required this.passbookNumber,
    required this.status,
    required this.joinedAt,
    required this.planName,
    required this.amountPaise,
    required this.totalInstallments,
    required this.paidInstallments,
    this.templateId,
    this.versionId,
    this.slug,
    this.nextDueDate,
    this.maturityDate,
    this.uiState,
    this.canRequestRedemption = false,
    this.redeemableBalancePaise = 0,
    this.blockingReason,
    this.closedAt,
    this.installments = const [],
  });

  final String enrollmentId;
  final String enrollmentNumber;
  final String passbookNumber;
  final String status;
  final DateTime? joinedAt;
  final String planName;
  final int amountPaise;
  final int totalInstallments;
  final int paidInstallments;
  final String? templateId;
  final String? versionId;
  final String? slug;
  final DateTime? nextDueDate;
  final DateTime? maturityDate;
  final String? uiState;
  final bool canRequestRedemption;
  final int redeemableBalancePaise;
  final String? blockingReason;
  final DateTime? closedAt;
  final List<SchemeInstallment> installments;

  String get _status => status.toUpperCase();
  String get _ui => (uiState ?? '').toUpperCase();

  bool get isActive => _status == 'ACTIVE' || _ui == 'IN_PROGRESS';
  bool get isMatured =>
      _status == 'MATURED' ||
      _status == 'PARTIALLY_REDEEMED' ||
      (totalInstallments > 0 && paidInstallments >= totalInstallments);
  bool get isPast =>
      _ui == 'PAST' ||
      _status == 'REDEEMED' ||
      _status == 'PREMATURELY_CLOSED' ||
      _status == 'CLOSED' ||
      _status == 'COMPLETED';
  bool get isRedeemable =>
      !isPast &&
      (canRequestRedemption ||
          _ui == 'REDEEMABLE' ||
          _status == 'MATURED' ||
          _status == 'PARTIALLY_REDEEMED');
  bool get isRedeemed => _status == 'REDEEMED' || _status == 'COMPLETED';
  double get progress => totalInstallments <= 0
      ? 0
      : (paidInstallments / totalInstallments).clamp(0, 1).toDouble();
  int get savedPaise => amountPaise * paidInstallments;
  int get goalPaise => amountPaise * totalInstallments;

  factory SchemeEnrollment.fromJson(Map<String, dynamic> json) {
    final template = json['template'] is Map
        ? Map<String, dynamic>.from(json['template'] as Map)
        : <String, dynamic>{};
    final content = template['content'] is Map
        ? Map<String, dynamic>.from(template['content'] as Map)
        : <String, dynamic>{};
    final rules = json['rules'] is Map
        ? Map<String, dynamic>.from(json['rules'] as Map)
        : <String, dynamic>{};
    final installment = rules['installment'] is Map
        ? Map<String, dynamic>.from(rules['installment'] as Map)
        : <String, dynamic>{};
    final summary = json['scheduleSummary'] is Map
        ? Map<String, dynamic>.from(json['scheduleSummary'] as Map)
        : <String, dynamic>{};

    final amount = (installment['amountPaise'] as num?)?.toInt() ??
        (summary['installmentAmountPaise'] as num?)?.toInt() ??
        0;
    final total = (installment['totalInstallments'] as num?)?.toInt() ??
        (summary['totalInstallments'] as num?)?.toInt() ??
        0;
    final paid = (summary['paidInstallments'] as num?)?.toInt() ??
        (summary['paidCount'] as num?)?.toInt() ??
        (((summary['paid'] as num?)?.toInt() ?? 0) +
            ((summary['paidLate'] as num?)?.toInt() ?? 0));

    DateTime? parseDate(dynamic value) {
      if (value is String && value.isNotEmpty) return DateTime.tryParse(value);
      if (value is Map) {
        return parseDate(value['dueAt'] ?? value['dueDate']);
      }
      return null;
    }

    final rawInstallments = json['installments'] ?? summary['installments'];
    final list = <SchemeInstallment>[];
    if (rawInstallments is List) {
      for (final item in rawInstallments) {
        if (item is Map) {
          list.add(SchemeInstallment.fromJson(Map<String, dynamic>.from(item)));
        }
      }
    }

    final next = summary['nextInstallment'];
    final nextDue = parseDate(summary['nextDueDate'] ?? summary['nextDueAt'] ?? next);

    return SchemeEnrollment(
      enrollmentId: json['enrollmentId']?.toString() ?? json['id']?.toString() ?? '',
      enrollmentNumber: json['enrollmentNumber']?.toString() ?? '',
      passbookNumber: json['passbookNumber']?.toString() ??
          template['passbookNumber']?.toString() ??
          '',
      status: json['status']?.toString() ?? 'ACTIVE',
      joinedAt: parseDate(json['joinedAt']),
      planName: (content['name'] as String?)?.trim() ??
          (json['planName'] as String?)?.trim() ??
          'Gold Savings Plan',
      amountPaise: amount > 0 ? amount : 0,
      totalInstallments: total > 0 ? total : list.length,
      paidInstallments: paid,
      templateId: template['templateId']?.toString(),
      versionId: template['versionId']?.toString(),
      slug: template['slug']?.toString(),
      nextDueDate: nextDue,
      maturityDate: parseDate(summary['maturityDate'] ?? summary['maturityAt']),
      uiState: json['uiState']?.toString(),
      canRequestRedemption: json['canRequestRedemption'] == true,
      redeemableBalancePaise:
          (json['redeemableBalancePaise'] as num?)?.toInt() ?? 0,
      blockingReason: json['blockingReason']?.toString(),
      closedAt: parseDate(json['closedAt']),
      installments: list,
    );
  }

  factory SchemeEnrollment.fromRedemption(SchemeRedemption redemption) {
    final completed = redemption.isCompleted;
    return SchemeEnrollment(
      enrollmentId: redemption.enrollmentId ?? redemption.redemptionId,
      enrollmentNumber: redemption.enrollmentNumber ?? redemption.redemptionNumber,
      passbookNumber: '',
      status: completed ? 'REDEEMED' : 'MATURED',
      joinedAt: redemption.requestedAt,
      planName: (redemption.planName ?? '').trim().isEmpty
          ? 'Gold Savings Plan'
          : redemption.planName!,
      amountPaise: 0,
      totalInstallments: 0,
      paidInstallments: 0,
      uiState: completed ? 'PAST' : 'REDEEMABLE',
      canRequestRedemption: false,
      redeemableBalancePaise: redemption.requestedAmountPaise,
      closedAt: completed ? (redemption.completedAt ?? redemption.requestedAt) : null,
    );
  }

  SchemeEnrollment copyWith({
    List<SchemeInstallment>? installments,
    int? totalInstallments,
    int? paidInstallments,
    DateTime? nextDueDate,
    DateTime? maturityDate,
    String? status,
    String? uiState,
    DateTime? closedAt,
    int? redeemableBalancePaise,
  }) {
    return SchemeEnrollment(
      enrollmentId: enrollmentId,
      enrollmentNumber: enrollmentNumber,
      passbookNumber: passbookNumber,
      status: status ?? this.status,
      joinedAt: joinedAt,
      planName: planName,
      amountPaise: amountPaise,
      totalInstallments: totalInstallments ?? this.totalInstallments,
      paidInstallments: paidInstallments ?? this.paidInstallments,
      templateId: templateId,
      versionId: versionId,
      slug: slug,
      nextDueDate: nextDueDate ?? this.nextDueDate,
      maturityDate: maturityDate ?? this.maturityDate,
      uiState: uiState ?? this.uiState,
      canRequestRedemption: canRequestRedemption,
      redeemableBalancePaise:
          redeemableBalancePaise ?? this.redeemableBalancePaise,
      blockingReason: blockingReason,
      closedAt: closedAt ?? this.closedAt,
      installments: installments ?? this.installments,
    );
  }
}

class SchemeInstallment {
  const SchemeInstallment({
    required this.sequenceNumber,
    required this.amountPaise,
    required this.status,
    this.dueDate,
    this.paidAt,
    this.receiptNumber,
  });

  final int sequenceNumber;
  final int amountPaise;
  final String status;
  final DateTime? dueDate;
  final DateTime? paidAt;
  final String? receiptNumber;

  bool get isPaid {
    final s = status.toUpperCase();
    return s == 'PAID' || s == 'PAID_LATE' || s == 'SUCCESS';
  }
  bool get isDue =>
      status.toUpperCase() == 'DUE' ||
      status.toUpperCase() == 'PENDING' ||
      status.toUpperCase() == 'OPEN';

  factory SchemeInstallment.fromJson(Map<String, dynamic> json) {
    DateTime? parseDate(dynamic value) {
      if (value is String && value.isNotEmpty) return DateTime.tryParse(value);
      return null;
    }

    return SchemeInstallment(
      sequenceNumber: (json['sequenceNumber'] as num?)?.toInt() ??
          (json['installment'] as num?)?.toInt() ??
          0,
      amountPaise: (json['amountPaise'] as num?)?.toInt() ?? 0,
      status: json['status']?.toString() ?? 'PENDING',
      dueDate: parseDate(json['dueDate'] ?? json['dueAt']),
      paidAt: parseDate(json['paidAt'] ?? json['paymentDate']),
      receiptNumber: json['receiptNumber']?.toString() ?? json['receipt']?.toString(),
    );
  }
}

class PaymentPreview {
  const PaymentPreview({
    required this.amountPaise,
    this.sequenceNumber,
    this.planName,
    this.paymentAllowed = true,
    this.validationMessage,
  });

  final int amountPaise;
  final int? sequenceNumber;
  final String? planName;
  final bool paymentAllowed;
  final String? validationMessage;

  factory PaymentPreview.fromJson(Map<String, dynamic> json) {
    final installment = json['installment'] is Map
        ? Map<String, dynamic>.from(json['installment'] as Map)
        : <String, dynamic>{};
    final reason = json['reason']?.toString();
    final amount = (installment['amountPaise'] as num?)?.toInt() ??
        (json['amountPaise'] as num?)?.toInt() ??
        (json['minimumPaymentPaise'] as num?)?.toInt() ??
        0;
    return PaymentPreview(
      amountPaise: amount > 0 ? amount : 0,
      sequenceNumber: (installment['sequenceNumber'] as num?)?.toInt() ??
          (json['sequenceNumber'] as num?)?.toInt(),
      planName: json['schemeName'] as String? ?? json['planName'] as String?,
      paymentAllowed: json['paymentAllowed'] == true,
      validationMessage: json['validationMessage'] as String? ??
          _previewReasonLabel(reason),
    );
  }
}

String? _previewReasonLabel(String? reason) {
  if (reason == null || reason.isEmpty) return null;
  switch (reason) {
    case 'ENROLLMENT_NOT_ACTIVE':
      return 'This scheme is not active for payments';
    case 'PREMATURE_CLOSURE_OPEN':
      return 'A premature closure request is already open';
    case 'UNRESOLVED_FINANCIAL_EVENTS':
      return 'There are unresolved financial adjustments on this plan';
    case 'ALL_INSTALLMENTS_PAID':
      return 'All instalments are already paid';
    case 'PAYMENT_WINDOW_NOT_OPEN':
      return 'Payment window is not open yet for the next instalment';
    default:
      return reason.replaceAll('_', ' ').toLowerCase();
  }
}

class PaymentIntent {
  const PaymentIntent({
    required this.merchantOrderId,
    required this.status,
    required this.amountPaise,
    this.checkoutUrl,
    this.token,
    this.receiptNumber,
    this.paymentId,
    this.sequenceNumber,
  });

  final String merchantOrderId;
  final String status;
  final int amountPaise;
  final String? checkoutUrl;
  final String? token;
  final String? receiptNumber;
  final String? paymentId;
  final int? sequenceNumber;

  bool get isSuccess => status.toUpperCase() == 'SUCCESS';
  bool get isFailed =>
      status.toUpperCase() == 'FAILED' || status.toUpperCase() == 'REVIEW_REQUIRED';
  bool get isPending => !isSuccess && !isFailed;

  factory PaymentIntent.fromJson(Map<String, dynamic> json) => PaymentIntent(
        merchantOrderId: json['merchantOrderId']?.toString() ?? '',
        status: json['status']?.toString() ?? 'PENDING',
        amountPaise: (json['amountPaise'] as num?)?.toInt() ?? 0,
        checkoutUrl: json['checkoutUrl'] as String? ?? json['redirectUrl'] as String?,
        token: json['token'] as String?,
        receiptNumber: json['receiptNumber']?.toString(),
        paymentId: json['paymentId']?.toString(),
        sequenceNumber: (json['sequenceNumber'] as num?)?.toInt(),
      );
}

class RedemptionEligibility {
  const RedemptionEligibility({
    required this.enrollmentId,
    required this.canRequest,
    required this.hasOpenRedemption,
    required this.totalRedeemablePaise,
    required this.allowPartial,
    this.blockingReason,
    this.settlementMode,
  });

  final String enrollmentId;
  final bool canRequest;
  final bool hasOpenRedemption;
  final int totalRedeemablePaise;
  final bool allowPartial;
  final String? blockingReason;
  final String? settlementMode;

  factory RedemptionEligibility.fromJson(Map<String, dynamic> json) =>
      RedemptionEligibility(
        enrollmentId: json['enrollmentId']?.toString() ?? '',
        canRequest: json['canRequestRedemption'] == true,
        hasOpenRedemption: json['hasOpenRedemption'] == true,
        totalRedeemablePaise:
            (json['totalRedeemablePaise'] as num?)?.toInt() ?? 0,
        allowPartial: json['allowPartial'] == true,
        blockingReason: json['blockingReason'] as String?,
        settlementMode: json['settlementMode'] as String?,
      );
}

class SchemeRedemption {
  const SchemeRedemption({
    required this.redemptionId,
    required this.redemptionNumber,
    required this.status,
    required this.mode,
    required this.requestedAmountPaise,
    this.requestedAt,
    this.completedAt,
    this.enrollmentId,
    this.enrollmentNumber,
    this.planName,
  });

  final String redemptionId;
  final String redemptionNumber;
  final String status;
  final String mode;
  final int requestedAmountPaise;
  final DateTime? requestedAt;
  final DateTime? completedAt;
  final String? enrollmentId;
  final String? enrollmentNumber;
  final String? planName;

  bool get isOpen {
    const open = {
      'REQUESTED',
      'UNDER_REVIEW',
      'APPROVED',
      'READY_FOR_REDEMPTION',
    };
    return open.contains(status.toUpperCase());
  }

  bool get isCompleted {
    const done = {'COMPLETED', 'SETTLED', 'FULFILLED', 'CLOSED', 'REDEEMED'};
    return done.contains(status.toUpperCase());
  }

  factory SchemeRedemption.fromJson(Map<String, dynamic> json) {
    final nested = json['redemption'];
    final map = nested is Map
        ? Map<String, dynamic>.from(nested)
        : json;
    DateTime? parseDate(dynamic value) {
      if (value is String && value.isNotEmpty) return DateTime.tryParse(value);
      return null;
    }

    String? planName = map['planName']?.toString();
    if (planName == null || planName.isEmpty) {
      final template = map['template'];
      if (template is Map && template['content'] is Map) {
        planName = Map<String, dynamic>.from(template['content'] as Map)['name']
            ?.toString();
      }
    }

    return SchemeRedemption(
      redemptionId: map['redemptionId']?.toString() ?? map['id']?.toString() ?? '',
      redemptionNumber: map['redemptionNumber']?.toString() ?? '',
      status: map['status']?.toString() ?? 'REQUESTED',
      mode: map['mode']?.toString() ?? 'FULL',
      requestedAmountPaise: (map['requestedAmountPaise'] as num?)?.toInt() ??
          (map['amountPaise'] as num?)?.toInt() ??
          0,
      requestedAt: parseDate(map['requestedAt']),
      completedAt: parseDate(map['completedAt']),
      enrollmentId: map['enrollmentId']?.toString(),
      enrollmentNumber: map['enrollmentNumber']?.toString(),
      planName: planName,
    );
  }
}
