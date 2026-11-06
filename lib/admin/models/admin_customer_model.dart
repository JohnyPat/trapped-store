import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:trapped_store/shared/constants/admin_constants.dart';

/// Model for an admin-registered customer.
@immutable
class AdminCustomer {
  final String id;
  final String uid;
  final String fullName;
  final String email;
  final String phone;
  final String? address;
  final String barangay;
  final String city;
  final String province;
  final String postalCode;
  final String profileImage;
  final String status;
  final DateTime createdAt;
  final DateTime? lastLoginAt;
  final DateTime? updatedAt;

  const AdminCustomer({
    required this.id,
    required this.uid,
    required this.fullName,
    required this.email,
    required this.phone,
    this.address,
    this.barangay = '',
    this.city = '',
    this.province = '',
    this.postalCode = '',
    this.profileImage = '',
    this.status = 'active',
    required this.createdAt,
    this.lastLoginAt,
    this.updatedAt,
  });

  factory AdminCustomer.empty(String uid) => AdminCustomer(
        id: '',
        uid: uid,
        fullName: '',
        email: '',
        phone: '',
        address: '',
        profileImage: '',
        status: 'active',
        createdAt: DateTime.now(),
      );

  AdminCustomer copyWith({
    String? id,
    String? uid,
    String? fullName,
    String? email,
    String? phone,
    String? address,
    String? barangay,
    String? city,
    String? province,
    String? postalCode,
    String? profileImage,
    String? status,
    DateTime? createdAt,
    DateTime? lastLoginAt,
    DateTime? updatedAt,
  }) {
    return AdminCustomer(
      id: id ?? this.id,
      uid: uid ?? this.uid,
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      address: address ?? this.address,
      barangay: barangay ?? this.barangay,
      city: city ?? this.city,
      province: province ?? this.province,
      postalCode: postalCode ?? this.postalCode,
      profileImage: profileImage ?? this.profileImage,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      lastLoginAt: lastLoginAt ?? this.lastLoginAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'uid': uid,
      'fullName': fullName,
      'email': email,
      'phone': phone,
      'address': address,
      'barangay': barangay,
      'city': city,
      'province': province,
      'postalCode': postalCode,
      'profileImage': profileImage,
      'status': status,
      'createdAt': createdAt.millisecondsSinceEpoch,
      if (lastLoginAt != null) 'lastLoginAt': lastLoginAt!.millisecondsSinceEpoch,
      'updatedAt': updatedAt?.millisecondsSinceEpoch,
    };
  }

  factory AdminCustomer.fromMap(String id, Map<String, dynamic> data) {
    final now = DateTime.now();
    final DateTime? lastLogin = data['lastLoginAt'] != null
        ? DateTime.fromMillisecondsSinceEpoch(data['lastLoginAt'])
        : null;
    final DateTime? updated = data['updatedAt'] != null
        ? DateTime.fromMillisecondsSinceEpoch(data['updatedAt'])
        : null;
    return AdminCustomer(
      id: id,
      uid: data['uid'] ?? '',
      fullName: data['fullName'] ?? '',
      email: data['email'] ?? '',
      phone: data['phone'] ?? '',
      address: data['address'],
      barangay: data['barangay'] ?? '',
      city: data['city'] ?? '',
      province: data['province'] ?? '',
      postalCode: data['postalCode'] ?? '',
      profileImage: data['profileImage'] ?? '',
      status: data['status'] ?? 'active',
      createdAt: data['createdAt'] != null
          ? DateTime.fromMillisecondsSinceEpoch(data['createdAt'])
          : now,
      lastLoginAt: lastLogin,
      updatedAt: updated,
    );
  }

  String get statusLabel =>
      status.toLowerCase() == 'active' ? 'Active' : 'Disabled';

  /// Street, barangay, city, province and postal code combined for display.
  String get fullAddress => [
        address ?? '',
        barangay,
        city,
        province,
        postalCode,
      ].map((part) => part.trim()).where((part) => part.isNotEmpty).join(', ');

  Color get statusColor =>
      status.toLowerCase() == 'active' ? AdminColors.success : AdminColors.warning;

  String get formattedCreatedAt =>
      DateFormat('MMM dd, yyyy').format(createdAt);
}