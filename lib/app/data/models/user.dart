import 'activity.dart';
import 'address.dart';

class AppUser {
  const AppUser({
    required this.id,
    required this.name,
    required this.phone,
    this.role = 'CUSTOMER',
  });

  final String id;
  final String name;
  final String phone;
  final String role;

  factory AppUser.fromJson(Map<String, dynamic> json) => AppUser(
        id: (json['id'] ?? json['userId'] ?? json['sub'] ?? '').toString(),
        name: (json['name'] as String?)?.trim() ?? '',
        phone: (json['phone'] as String?)?.trim() ?? '',
        role: (json['role'] as String?) ?? 'CUSTOMER',
      );

  String get initials {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty || parts.first.isEmpty) return 'W';
    if (parts.length == 1) return parts.first[0].toUpperCase();
    return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
  }
}

class OtpChallenge {
  const OtpChallenge({
    required this.challengeId,
    required this.expiresInSeconds,
    required this.resendAfterSeconds,
    this.message,
  });

  final String challengeId;
  final int expiresInSeconds;
  final int resendAfterSeconds;
  final String? message;

  factory OtpChallenge.fromJson(Map<String, dynamic> json) => OtpChallenge(
        challengeId: json['challengeId']?.toString() ?? '',
        expiresInSeconds: (json['expiresInSeconds'] as num?)?.toInt() ?? 300,
        resendAfterSeconds: (json['resendAfterSeconds'] as num?)?.toInt() ?? 30,
        message: json['message'] as String?,
      );
}

class OtpVerifyResult {
  const OtpVerifyResult({
    required this.registrationRequired,
    this.registrationToken,
    this.user,
  });

  final bool registrationRequired;
  final String? registrationToken;
  final AppUser? user;

  factory OtpVerifyResult.fromJson(Map<String, dynamic> json) {
    final required = json['registrationRequired'] == true;
    AppUser? user;
    final rawUser = json['user'];
    if (rawUser is Map<String, dynamic>) {
      user = AppUser.fromJson(rawUser);
    } else if (rawUser is Map) {
      user = AppUser.fromJson(Map<String, dynamic>.from(rawUser));
    }
    return OtpVerifyResult(
      registrationRequired: required,
      registrationToken: json['registrationToken'] as String?,
      user: user,
    );
  }
}

class CustomerProfile {
  const CustomerProfile({
    required this.id,
    this.name,
    this.phone,
    this.passbookNumber,
    this.status,
    this.kycStatus,
    this.hasKycSubmission = false,
    this.address,
    this.defaultAddress,
    this.addresses = const [],
    this.historySummary,
  });

  final String id;
  final String? name;
  final String? phone;
  final String? passbookNumber;
  final String? status;
  final String? kycStatus;
  final bool hasKycSubmission;
  final Map<String, dynamic>? address;
  final Address? defaultAddress;
  final List<Address> addresses;
  final HistorySummary? historySummary;

  factory CustomerProfile.fromJson(Map<String, dynamic> json) {
    Address? parseAddress(dynamic raw) {
      if (raw is Map) return Address.fromJson(Map<String, dynamic>.from(raw));
      return null;
    }

    final list = <Address>[];
    final rawList = json['addresses'];
    if (rawList is List) {
      for (final item in rawList) {
        final address = parseAddress(item);
        if (address != null &&
            (address.line1.isNotEmpty || address.city.isNotEmpty)) {
          list.add(address);
        }
      }
    }

    return CustomerProfile(
      id: json['id']?.toString() ?? '',
      name: json['name'] as String?,
      phone: json['phone'] as String?,
      passbookNumber: json['passbookNumber'] as String?,
      status: json['status'] as String?,
      kycStatus: json['kycStatus'] as String?,
      hasKycSubmission: json['hasKycSubmission'] == true,
      address: json['address'] is Map
          ? Map<String, dynamic>.from(json['address'] as Map)
          : null,
      defaultAddress: parseAddress(json['defaultAddress']),
      addresses: list,
      historySummary: json['historySummary'] is Map
          ? HistorySummary.fromJson(
              Map<String, dynamic>.from(json['historySummary'] as Map),
            )
          : null,
    );
  }

  List<Address> get savedAddresses {
    if (addresses.isNotEmpty) return addresses;
    if (defaultAddress != null) return [defaultAddress!];
    final legacy = address;
    if (legacy == null) return const [];
    final parsed = Address.fromJson({
      'id': 'profile',
      'label': 'Profile',
      'name': displayName,
      'phone': phone ?? '',
      ...legacy,
      'stateName': legacy['stateName'] ?? legacy['state'],
      'pincode': legacy['pincode'] ?? legacy['postalCode'],
      'isDefault': true,
    });
    if (parsed.line1.isEmpty && parsed.city.isEmpty && parsed.pincode.isEmpty) {
      return const [];
    }
    return [parsed];
  }

  String get displayName => (name ?? '').trim().isEmpty ? 'Guest' : name!.trim();

  String get initials {
    final parts = displayName.split(RegExp(r'\s+'));
    if (parts.isEmpty || parts.first.isEmpty) return 'W';
    if (parts.length == 1) return parts.first[0].toUpperCase();
    return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
  }
}
