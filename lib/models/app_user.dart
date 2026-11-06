import '../utils/parse.dart';

/// Customer account stored at `users/{uid}` in Firebase Realtime Database.
/// Passwords never appear here — they are managed exclusively by Firebase Auth.
class AppUser {
  const AppUser({
    required this.uid,
    required this.fullName,
    required this.email,
    this.phone = '',
    this.address = '',
    this.barangay = '',
    this.city = '',
    this.province = '',
    this.postalCode = '',
    this.profileImage = '',
    this.createdAt,
    this.updatedAt,
    this.lastLoginAt,
    this.status = statusActive,
  });

  static const String statusActive = 'active';
  static const String statusDisabled = 'disabled';

  final String uid;
  final String fullName;
  final String email;
  final String phone;
  final String address;
  final String barangay;
  final String city;
  final String province;
  final String postalCode;
  final String profileImage;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final DateTime? lastLoginAt;
  final String status;

  bool get isActive => status.trim().toLowerCase() == statusActive;
  bool get isDisabled => !isActive;

  String get displayName {
    if (fullName.trim().isNotEmpty) return fullName.trim();
    if (email.contains('@')) return email.split('@').first;
    return 'TRAPPED MEMBER';
  }

  bool get hasCompleteDeliveryInfo =>
      fullName.trim().isNotEmpty &&
      phone.trim().isNotEmpty &&
      address.trim().isNotEmpty &&
      city.trim().isNotEmpty &&
      province.trim().isNotEmpty &&
      postalCode.trim().isNotEmpty;

  factory AppUser.fromMap(String uid, Map<dynamic, dynamic> map) {
    final data = asStringMap(map);
    final status = asString(data['status'], statusActive).trim().toLowerCase();
    return AppUser(
      uid: uid,
      fullName: asString(data['fullName']),
      email: asString(data['email']),
      phone: asString(data['phone']),
      address: asString(data['address']),
      barangay: asString(data['barangay']),
      city: asString(data['city']),
      province: asString(data['province']),
      postalCode: asString(data['postalCode']),
      profileImage: asString(data['profileImage']),
      createdAt: asDate(data['createdAt']),
      updatedAt: asDate(data['updatedAt']),
      lastLoginAt: asDate(data['lastLoginAt']),
      status: status.isEmpty ? statusActive : status,
    );
  }

  factory AppUser.empty(String uid, {String email = ''}) =>
      AppUser(uid: uid, fullName: '', email: email);

  AppUser copyWith({
    String? fullName,
    String? email,
    String? phone,
    String? address,
    String? barangay,
    String? city,
    String? province,
    String? postalCode,
    String? profileImage,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? lastLoginAt,
    String? status,
  }) {
    return AppUser(
      uid: uid,
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      address: address ?? this.address,
      barangay: barangay ?? this.barangay,
      city: city ?? this.city,
      province: province ?? this.province,
      postalCode: postalCode ?? this.postalCode,
      profileImage: profileImage ?? this.profileImage,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      lastLoginAt: lastLoginAt ?? this.lastLoginAt,
      status: status ?? this.status,
    );
  }

  Map<String, dynamic> toMap() {
    final now = DateTime.now().millisecondsSinceEpoch;
    return {
      'uid': uid,
      'fullName': fullName.trim(),
      'email': email.trim(),
      'phone': phone.trim(),
      'address': address.trim(),
      'barangay': barangay.trim(),
      'city': city.trim(),
      'province': province.trim(),
      'postalCode': postalCode.trim(),
      'profileImage': profileImage,
      'status': status.trim().toLowerCase().isEmpty ? statusActive : status,
      'updatedAt': now,
      if (createdAt != null) 'createdAt': createdAt!.millisecondsSinceEpoch,
      if (lastLoginAt != null)
        'lastLoginAt': lastLoginAt!.millisecondsSinceEpoch,
    };
  }
}
