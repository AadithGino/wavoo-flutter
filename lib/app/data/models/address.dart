class Address {
  const Address({
    required this.id,
    required this.label,
    required this.lines,
    this.isDefault = false,
    required this.user,
  });

  final String id;
  final String label;
  final String user;
  final String lines;
  final bool isDefault;

  Address copyWith({bool? isDefault}) => Address(
    id: id,
    label: label,
    lines: lines,
    user: user,
    isDefault: isDefault ?? this.isDefault,
  );
}
