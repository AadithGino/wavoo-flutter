import '../../core/utils/phone.dart';

class Address {
  const Address({
    required this.id,
    required this.label,
    required this.lines,
    required this.user,
    this.name = '',
    this.phone = '',
    this.line1 = '',
    this.line2,
    this.city = '',
    this.stateName = '',
    this.pincode = '',
    this.isDefault = false,
  });

  final String id;
  final String label;
  final String user;
  final String lines;
  final String name;
  final String phone;
  final String line1;
  final String? line2;
  final String city;
  final String stateName;
  final String pincode;
  final bool isDefault;

  bool get isComplete =>
      name.trim().length >= 2 &&
      PhoneUtils.normalizeIndian(phone) != null &&
      line1.trim().isNotEmpty &&
      city.trim().isNotEmpty &&
      stateName.trim().isNotEmpty &&
      RegExp(r'^\d{6}$').hasMatch(pincode.trim());

  Address copyWith({
    String? id,
    String? label,
    String? lines,
    String? user,
    String? name,
    String? phone,
    String? line1,
    String? line2,
    bool clearLine2 = false,
    String? city,
    String? stateName,
    String? pincode,
    bool? isDefault,
  }) =>
      Address(
        id: id ?? this.id,
        label: label ?? this.label,
        lines: lines ?? this.lines,
        user: user ?? this.user,
        name: name ?? this.name,
        phone: phone ?? this.phone,
        line1: line1 ?? this.line1,
        line2: clearLine2 ? null : (line2 ?? this.line2),
        city: city ?? this.city,
        stateName: stateName ?? this.stateName,
        pincode: pincode ?? this.pincode,
        isDefault: isDefault ?? this.isDefault,
      );

  Map<String, dynamic> toCheckoutJson() => {
        if (label.trim().isNotEmpty) 'label': label.trim(),
        'name': name.trim(),
        'phone': PhoneUtils.normalizeIndian(phone) ?? phone.trim(),
        'line1': line1.trim(),
        if (line2 != null && line2!.trim().isNotEmpty) 'line2': line2!.trim(),
        'city': city.trim(),
        'stateName': stateName.trim(),
        'pincode': pincode.trim(),
      };

  Map<String, dynamic> toApiJson({bool includeDefault = true}) => {
        ...toCheckoutJson(),
        if (includeDefault) 'isDefault': isDefault,
      };

  factory Address.fromJson(Map<String, dynamic> json) {
    final name = (json['name'] as String?)?.trim() ?? '';
    final phone = (json['phone'] as String?)?.trim() ?? '';
    final line1 = (json['line1'] as String?)?.trim() ?? '';
    final line2 = (json['line2'] as String?)?.trim();
    final city = (json['city'] as String?)?.trim() ?? '';
    final state = (json['stateName'] as String?)?.trim().isNotEmpty == true
        ? (json['stateName'] as String).trim()
        : (json['state'] as String?)?.trim() ?? '';
    final pincode = (json['pincode'] as String?)?.trim().isNotEmpty == true
        ? (json['pincode'] as String).trim()
        : (json['postalCode'] as String?)?.trim() ?? '';
    final parts = [line1, if (line2 != null && line2.isNotEmpty) line2, city, state, pincode]
        .where((part) => part.isNotEmpty)
        .toList();
    final label = (json['label'] as String?)?.trim();
    return Address(
      id: json['id']?.toString() ?? json['_id']?.toString() ?? '',
      label: (label == null || label.isEmpty) ? 'Address' : label,
      name: name,
      phone: phone,
      user: [name, PhoneUtils.display(phone)].where((part) => part.isNotEmpty).join(' · '),
      line1: line1,
      line2: line2 == null || line2.isEmpty ? null : line2,
      city: city,
      stateName: state,
      pincode: pincode,
      lines: parts.isEmpty ? 'No address on file' : parts.join('\n'),
      isDefault: json['isDefault'] == true,
    );
  }
}
