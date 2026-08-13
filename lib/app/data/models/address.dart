import '../../core/utils/phone.dart';
import 'user.dart';

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

  Address copyWith({bool? isDefault}) => Address(
        id: id,
        label: label,
        lines: lines,
        user: user,
        name: name,
        phone: phone,
        line1: line1,
        line2: line2,
        city: city,
        stateName: stateName,
        pincode: pincode,
        isDefault: isDefault ?? this.isDefault,
      );

  Map<String, dynamic> toCheckoutJson() => {
        'label': label,
        'name': name,
        'phone': phone,
        'line1': line1,
        if (line2 != null && line2!.trim().isNotEmpty) 'line2': line2,
        'city': city,
        'stateName': stateName,
        'pincode': pincode,
      };

  factory Address.fromProfile(CustomerProfile profile) {
    final raw = profile.address ?? const <String, dynamic>{};
    String read(String key, [String fallback = '']) {
      final value = raw[key]?.toString().trim();
      return (value == null || value.isEmpty) ? fallback : value;
    }

    final line1 = read('line1');
    final line2 = read('line2');
    final city = read('city');
    final state = read('state') != '' ? read('state') : read('stateName');
    final pincode = read('postalCode') != '' ? read('postalCode') : read('pincode');
    final parts = [
      line1,
      line2,
      city,
      read('district'),
      state,
      pincode,
    ].where((part) => part.isNotEmpty).toList();

    return Address(
      id: 'profile',
      label: 'Profile',
      name: profile.displayName,
      phone: profile.phone ?? '',
      user: '${profile.displayName} · ${profile.phone ?? ''}',
      line1: line1,
      line2: line2.isEmpty ? null : line2,
      city: city,
      stateName: state,
      pincode: pincode,
      lines: parts.isEmpty ? 'No address on file' : parts.join('\n'),
      isDefault: true,
    );
  }
}
