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
  });

  final String id;
  final String? name;
  final String? phone;
  final String? passbookNumber;
  final String? status;
  final String? kycStatus;
  final bool hasKycSubmission;
  final Map<String, dynamic>? address;

  factory CustomerProfile.fromJson(Map<String, dynamic> json) => CustomerProfile(
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
      );

  String get displayName => (name ?? '').trim().isEmpty ? 'Guest' : name!.trim();

  String get initials {
    final parts = displayName.split(RegExp(r'\s+'));
    if (parts.isEmpty || parts.first.isEmpty) return 'W';
    if (parts.length == 1) return parts.first[0].toUpperCase();
    return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
  }
}
