class JewelleryOrder {
  const JewelleryOrder({
    required this.id,
    required this.totalPaise,
    required this.itemCount,
    required this.status,
    this.createdAt,
  });

  final String id;
  final int totalPaise;
  final int itemCount;
  final String status;
  final DateTime? createdAt;

  int get totalRupees => totalPaise ~/ 100;

  factory JewelleryOrder.fromJson(Map<String, dynamic> json) {
    final lines = json['lines'];
    var itemCount = 0;
    if (lines is List) {
      for (final line in lines) {
        if (line is Map) {
          itemCount += (line['quantity'] as num?)?.toInt() ?? 1;
        }
      }
    }
    itemCount = itemCount == 0
        ? (json['itemCount'] as num?)?.toInt() ?? 1
        : itemCount;

    final total = (json['totalPaise'] as num?)?.toInt() ??
        (json['payablePaise'] as num?)?.toInt() ??
        (json['amountPaise'] as num?)?.toInt() ??
        ((json['total'] as num?)?.toInt() ?? 0) * 100;

    return JewelleryOrder(
      id: json['orderNumber']?.toString() ??
          json['id']?.toString() ??
          json['_id']?.toString() ??
          json['orderId']?.toString() ??
          '',
      totalPaise: total,
      itemCount: itemCount,
      status: json['status']?.toString() ?? 'Confirmed',
      createdAt: json['createdAt'] is String
          ? DateTime.tryParse(json['createdAt'] as String)
          : null,
    );
  }
}
