class JewelleryOrder {
  const JewelleryOrder({
    required this.id,
    required this.total,
    required this.itemCount,
    required this.status,
  });

  final String id;
  final int total;
  final int itemCount;
  final String status;
}

