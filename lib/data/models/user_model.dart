import 'package:cloud_firestore/cloud_firestore.dart';

class MasterInfo {
  final String uid;
  final String name;
  final String? email;

  MasterInfo({
    required this.uid,
    required this.name,
    this.email,
  });

  factory MasterInfo.fromMap(Map<String, dynamic> map) {
    return MasterInfo(
      uid: map['uid'] ?? '',
      name: map['name'] ?? '',
      email: map['email'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'name': name,
      if (email != null) 'email': email,
    };
  }
}

class ParentInfo {
  final String uid;
  final String name;

  ParentInfo({
    required this.uid,
    required this.name,
  });

  factory ParentInfo.fromMap(Map<String, dynamic> map) {
    return ParentInfo(
      uid: map['uid'] ?? '',
      name: map['name'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'name': name,
    };
  }
}

class Address {
  final String? addressLine1;
  final String? addressLine2;
  final String? city;
  final String? state;
  final String? country;
  final String? pinCode;

  Address({
    this.addressLine1,
    this.addressLine2,
    this.city,
    this.state,
    this.country,
    this.pinCode,
  });

  factory Address.fromMap(Map<String, dynamic> map) {
    return Address(
      addressLine1: map['addressLine1'],
      addressLine2: map['addressLine2'],
      city: map['city'],
      state: map['state'],
      country: map['country'],
      pinCode: map['pinCode'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (addressLine1 != null) 'addressLine1': addressLine1,
      if (addressLine2 != null) 'addressLine2': addressLine2,
      if (city != null) 'city': city,
      if (state != null) 'state': state,
      if (country != null) 'country': country,
      if (pinCode != null) 'pinCode': pinCode,
    };
  }
}

class UserModel {
  final String uid;
  final String name;
  final String? displayName;
  final String email;
  final String? phoneNumber;
  final String? gender; // male, female, other
  final String? occupation;
  final String? sadhanaName;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? dateOfBirth;
  final String emailVerificationStatus; // unverified, verified, pending
  final String role; // user, master, head, admin
  final MasterInfo? master;
  final ParentInfo? parent;
  final List<String> trackingActivities; // parameter keys user is tracking
  final Map<String, bool>? activityTracking; // parameter key -> enabled/disabled
  final bool? initiated;
  final String? initiatedName;
  final Address? address;
  final String status; // active, disabled, archived

  UserModel({
    required this.uid,
    required this.name,
    this.displayName,
    required this.email,
    this.phoneNumber,
    this.gender,
    this.occupation,
    this.sadhanaName,
    required this.createdAt,
    required this.updatedAt,
    this.dateOfBirth,
    this.emailVerificationStatus = 'unverified',
    this.role = 'user',
    this.master,
    this.parent,
    this.trackingActivities = const [],
    this.activityTracking,
    this.initiated,
    this.initiatedName,
    this.address,
    this.status = 'active',
  });

  // From Firestore
  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return UserModel(
      uid: data['uid'] ?? doc.id,
      name: data['name'] ?? '',
      displayName: data['displayName'],
      email: data['email'] ?? '',
      phoneNumber: data['phoneNumber'],
      gender: data['gender'],
      occupation: data['occupation'],
      sadhanaName: data['sadhanaName'],
      createdAt: _parseTimestamp(data['createdAt']),
      updatedAt: _parseTimestamp(data['updatedAt']),
      dateOfBirth: _parseTimestamp(data['dateOfBirth']),
      emailVerificationStatus: data['emailVerificationStatus'] ?? 'unverified',
      role: data['role'] ?? 'user',
      master: data['master'] != null ? MasterInfo.fromMap(data['master']) : null,
      parent: data['parent'] != null ? ParentInfo.fromMap(data['parent']) : null,
      trackingActivities: data['trackingActivities'] != null
          ? List<String>.from(data['trackingActivities'])
          : [],
      activityTracking: data['activityTracking'] != null
          ? Map<String, bool>.from(data['activityTracking'])
          : null,
      initiated: data['initiated'],
      initiatedName: data['initiatedName'],
      address: data['address'] != null ? Address.fromMap(data['address']) : null,
      status: data['status'] ?? 'active',
    );
  }

  static DateTime _parseTimestamp(dynamic timestamp) {
    if (timestamp == null) return DateTime.now();
    if (timestamp is Timestamp) return timestamp.toDate();
    if (timestamp is String) return DateTime.tryParse(timestamp) ?? DateTime.now();
    if (timestamp is int) return DateTime.fromMillisecondsSinceEpoch(timestamp);
    if (timestamp is Map) {
      // Handle {_seconds: xxx, _nanoseconds: xxx} format
      if (timestamp.containsKey('_seconds')) {
        return DateTime.fromMillisecondsSinceEpoch(
          (timestamp['_seconds'] as int) * 1000,
        );
      }
    }
    return DateTime.now();
  }

  // To Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'uid': uid,
      'name': name,
      if (displayName != null) 'displayName': displayName,
      'email': email,
      if (phoneNumber != null) 'phoneNumber': phoneNumber,
      if (gender != null) 'gender': gender,
      if (occupation != null) 'occupation': occupation,
      if (sadhanaName != null) 'sadhanaName': sadhanaName,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      if (dateOfBirth != null) 'dateOfBirth': Timestamp.fromDate(dateOfBirth!),
      'emailVerificationStatus': emailVerificationStatus,
      'role': role,
      if (master != null) 'master': master!.toMap(),
      if (parent != null) 'parent': parent!.toMap(),
      'trackingActivities': trackingActivities,
      if (activityTracking != null) 'activityTracking': activityTracking,
      if (initiated != null) 'initiated': initiated,
      if (initiatedName != null) 'initiatedName': initiatedName,
      if (address != null) 'address': address!.toMap(),
      'status': status,
    };
  }

  UserModel copyWith({
    String? uid,
    String? name,
    String? displayName,
    String? email,
    String? phoneNumber,
    String? gender,
    String? occupation,
    String? sadhanaName,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? dateOfBirth,
    String? emailVerificationStatus,
    String? role,
    MasterInfo? master,
    ParentInfo? parent,
    List<String>? trackingActivities,
    Map<String, bool>? activityTracking,
    bool? initiated,
    String? initiatedName,
    Address? address,
    String? status,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      name: name ?? this.name,
      displayName: displayName ?? this.displayName,
      email: email ?? this.email,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      gender: gender ?? this.gender,
      occupation: occupation ?? this.occupation,
      sadhanaName: sadhanaName ?? this.sadhanaName,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      emailVerificationStatus: emailVerificationStatus ?? this.emailVerificationStatus,
      role: role ?? this.role,
      master: master ?? this.master,
      parent: parent ?? this.parent,
      trackingActivities: trackingActivities ?? this.trackingActivities,
      activityTracking: activityTracking ?? this.activityTracking,
      initiated: initiated ?? this.initiated,
      initiatedName: initiatedName ?? this.initiatedName,
      address: address ?? this.address,
      status: status ?? this.status,
    );
  }
}
