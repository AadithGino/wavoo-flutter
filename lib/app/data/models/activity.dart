class HistorySummary {
  const HistorySummary({
    this.schemesInProgress = 0,
    this.schemesRedeemable = 0,
    this.schemesPast = 0,
    this.schemesTotal = 0,
    this.redemptionsCount = 0,
    this.ecommerceOrdersCount = 0,
    this.lifetimeSchemeContributionsPaise = 0,
  });

  final int schemesInProgress;
  final int schemesRedeemable;
  final int schemesPast;
  final int schemesTotal;
  final int redemptionsCount;
  final int ecommerceOrdersCount;
  final int lifetimeSchemeContributionsPaise;

  factory HistorySummary.fromJson(Map<String, dynamic> json) {
    int n(String key) => (json[key] as num?)?.toInt() ?? 0;
    return HistorySummary(
      schemesInProgress: n('schemesInProgress'),
      schemesRedeemable: n('schemesRedeemable'),
      schemesPast: n('schemesPast'),
      schemesTotal: n('schemesTotal'),
      redemptionsCount: n('redemptionsCount'),
      ecommerceOrdersCount: n('ecommerceOrdersCount'),
      lifetimeSchemeContributionsPaise: n('lifetimeSchemeContributionsPaise'),
    );
  }
}

class CustomerTransaction {
  const CustomerTransaction({
    required this.id,
    required this.type,
    required this.date,
    required this.title,
    required this.detail,
    required this.amountPaise,
    required this.status,
    this.enrollmentId,
    this.enrollmentNumber,
    this.receiptNumber,
    this.sequenceNumber,
    this.orderId,
    this.orderNumber,
    this.itemCount,
  });

  final String id;
  final String type;
  final DateTime? date;
  final String title;
  final String detail;
  final int amountPaise;
  final String status;
  final String? enrollmentId;
  final String? enrollmentNumber;
  final String? receiptNumber;
  final int? sequenceNumber;
  final String? orderId;
  final String? orderNumber;
  final int? itemCount;

  bool get isShopping => type == 'shopping' || type == 'ecommerce';

  factory CustomerTransaction.fromJson(Map<String, dynamic> json) {
    DateTime? parseDate(dynamic value) {
      if (value is String && value.isNotEmpty) return DateTime.tryParse(value);
      return null;
    }

    return CustomerTransaction(
      id: json['id']?.toString() ?? '',
      type: json['type']?.toString() ?? 'scheme',
      date: parseDate(json['date'] ?? json['occurredAt']),
      title: json['title']?.toString() ?? 'Transaction',
      detail: json['detail']?.toString() ?? json['subtitle']?.toString() ?? '',
      amountPaise: (json['amountPaise'] as num?)?.toInt() ?? 0,
      status: json['status']?.toString() ?? '',
      enrollmentId: json['enrollmentId']?.toString(),
      enrollmentNumber: json['enrollmentNumber']?.toString(),
      receiptNumber: json['receiptNumber']?.toString(),
      sequenceNumber: (json['sequenceNumber'] as num?)?.toInt(),
      orderId: json['orderId']?.toString(),
      orderNumber: json['orderNumber']?.toString(),
      itemCount: (json['itemCount'] as num?)?.toInt(),
    );
  }
}

class CustomerActivity {
  const CustomerActivity({
    required this.id,
    required this.source,
    required this.title,
    required this.subtitle,
    required this.amountPaise,
    required this.direction,
    required this.status,
    this.occurredAt,
    this.enrollmentId,
    this.orderId,
  });

  final String id;
  final String source;
  final String title;
  final String subtitle;
  final int amountPaise;
  final String direction;
  final String status;
  final DateTime? occurredAt;
  final String? enrollmentId;
  final String? orderId;

  factory CustomerActivity.fromJson(Map<String, dynamic> json) {
    final refs = json['refs'] is Map
        ? Map<String, dynamic>.from(json['refs'] as Map)
        : <String, dynamic>{};
    DateTime? parseDate(dynamic value) {
      if (value is String && value.isNotEmpty) return DateTime.tryParse(value);
      return null;
    }

    return CustomerActivity(
      id: json['id']?.toString() ?? '',
      source: json['source']?.toString() ?? '',
      title: json['title']?.toString() ?? 'Activity',
      subtitle: json['subtitle']?.toString() ?? '',
      amountPaise: (json['amountPaise'] as num?)?.toInt() ?? 0,
      direction: json['direction']?.toString() ?? 'OUT',
      status: json['status']?.toString() ?? '',
      occurredAt: parseDate(json['occurredAt']),
      enrollmentId: refs['enrollmentId']?.toString(),
      orderId: refs['orderId']?.toString(),
    );
  }
}
