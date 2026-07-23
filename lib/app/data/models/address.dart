class Address {
  const Address({
    required this.id,
    required this.label,
    required this.lines,
    this.isDefault = false,
  });

  final String id;
  final String label;
  final String lines;
  final bool isDefault;

  Address copyWith({bool? isDefault}) => Address(
        id: id,
        label: label,
        lines: lines,
        isDefault: isDefault ?? this.isDefault,
      );
}

