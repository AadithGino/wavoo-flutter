import 'address.dart';

class OrderLine {
  const OrderLine({
    required this.productId,
    required this.name,
    required this.quantity,
    required this.lineTotalPaise,
    this.image,
    this.purityLabel,
    this.fulfillmentType,
    this.lineStatus,
  });

  final String productId;
  final String name;
  final int quantity;
  final int lineTotalPaise;
  final String? image;
  final String? purityLabel;
  final String? fulfillmentType;
  final String? lineStatus;

  factory OrderLine.fromJson(Map<String, dynamic> json) => OrderLine(
        productId: json['productId']?.toString() ?? '',
        name: (json['productName'] as String?)?.trim() ??
            (json['name'] as String?)?.trim() ??
            'Jewellery',
        quantity: (json['quantity'] as num?)?.toInt() ?? 1,
        lineTotalPaise: (json['lineTotalPaise'] as num?)?.toInt() ??
            (json['unitTotalPaise'] as num?)?.toInt() ??
            0,
        image: json['productImage'] as String?,
        purityLabel: json['purityLabel'] as String?,
        fulfillmentType: json['fulfillmentType'] as String?,
        lineStatus: json['lineStatus'] as String?,
      );
}

class JewelleryOrder {
  const JewelleryOrder({
    required this.id,
    required this.orderNumber,
    required this.totalPaise,
    required this.itemCount,
    required this.status,
    this.subtotalPaise,
    this.gstPaise,
    this.paymentMethod,
    this.createdAt,
    this.lines = const [],
    this.address,
    this.cancelReason,
  });

  final String id;
  final String orderNumber;
  final int totalPaise;
  final int itemCount;
  final String status;
  final int? subtotalPaise;
  final int? gstPaise;
  final String? paymentMethod;
  final DateTime? createdAt;
  final List<OrderLine> lines;
  final Address? address;
  final String? cancelReason;

  int get totalRupees => totalPaise ~/ 100;

  /// Rupees, matching the f2501df order list contract.
  int get total => totalRupees;

  bool get isPendingPayment => status.toUpperCase() == 'PENDING_PAYMENT';
  bool get isConfirmed =>
      status.toUpperCase() == 'CONFIRMED' || status.toUpperCase() == 'COMPLETED';
  bool get isFailed =>
      status.toUpperCase() == 'PAYMENT_FAILED' ||
      status.toUpperCase() == 'FAILED';
  bool get isCancelled => status.toUpperCase() == 'CANCELLED';
  bool get canCancel {
    if (status.toUpperCase() != 'CONFIRMED') return false;
    if (createdAt == null) return true;
    return DateTime.now().difference(createdAt!).inHours < 48;
  }

  String get statusLabel {
    switch (status.toUpperCase()) {
      case 'PENDING_PAYMENT':
        return 'Awaiting payment';
      case 'CONFIRMED':
        return 'Confirmed';
      case 'CANCELLED':
        return 'Cancelled';
      case 'PAYMENT_FAILED':
        return 'Payment failed';
      case 'REVIEW_REQUIRED':
        return 'Under review';
      case 'COMPLETED':
        return 'Completed';
      default:
        return status;
    }
  }

  factory JewelleryOrder.fromJson(Map<String, dynamic> json) {
    final rawLines = json['lines'];
    final lines = <OrderLine>[];
    var itemCount = 0;
    if (rawLines is List) {
      for (final line in rawLines) {
        if (line is Map) {
          final parsed = OrderLine.fromJson(Map<String, dynamic>.from(line));
          lines.add(parsed);
          itemCount += parsed.quantity;
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

    Address? address;
    if (json['address'] is Map) {
      address = Address.fromJson(Map<String, dynamic>.from(json['address'] as Map));
    }

    final id = json['id']?.toString() ??
        json['_id']?.toString() ??
        json['orderId']?.toString() ??
        '';

    return JewelleryOrder(
      id: id,
      orderNumber: json['orderNumber']?.toString() ?? id,
      totalPaise: total,
      itemCount: itemCount,
      status: json['status']?.toString() ?? 'Confirmed',
      subtotalPaise: (json['subtotalPaise'] as num?)?.toInt(),
      gstPaise: (json['gstPaise'] as num?)?.toInt(),
      paymentMethod: json['paymentMethod']?.toString(),
      createdAt: json['createdAt'] is String
          ? DateTime.tryParse(json['createdAt'] as String)
          : null,
      lines: lines,
      address: address,
      cancelReason: json['cancelReason'] as String?,
    );
  }
}

class CheckoutResult {
  const CheckoutResult({required this.order, this.redirectUrl});

  final JewelleryOrder order;
  final String? redirectUrl;
}
