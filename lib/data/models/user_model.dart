import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String uid;
  final String email;
  final String name;
  final String role;
  final String? mentorId;
  final List<String> disciples;
  final Map<String, bool> displayParameters;
  final String? phone;
  final String? occupation;
  final String? gender;
  final DateTime createdAt;
  final DateTime updatedAt;

  UserModel({
    required this.uid,
    required this.email,
    required this.name,
    required this.role,
    this.mentorId,
    required this.disciples,
    required this.displayParameters,
    this.phone,
    this.occupation,
    this.gender,
    required this.createdAt,
    required this.updatedAt,
  });

  // From Firestore
  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return UserModel(
      uid: doc.id,
      email: data['email'] ?? '',
      name: data['name'] ?? '',
      role: data['role'] ?? 'user',
      mentorId: data['mentorId'],
      disciples: List<String>.from(data['disciples'] ?? []),
      displayParameters: Map<String, bool>.from(data['displayParameters'] ?? {
        'nindra': true,
        'wakeUp': true,
        'daySleep': true,
        'japa': true,
        'pathan': true,
        'sravan': true,
        'seva': true,
      }),
      phone: data['phone'],
      occupation: data['occupation'],
      gender: data['gender'],
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  // To Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'email': email,
      'name': name,
      'role': role,
      'mentorId': mentorId,
      'disciples': disciples,
      'displayParameters': displayParameters,
      'phone': phone,
      'occupation': occupation,
      'gender': gender,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  UserModel copyWith({
    String? uid,
    String? email,
    String? name,
    String? role,
    String? mentorId,
    List<String>? disciples,
    Map<String, bool>? displayParameters,
    String? phone,
    String? occupation,
    String? gender,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      email: email ?? this.email,
      name: name ?? this.name,
      role: role ?? this.role,
      mentorId: mentorId ?? this.mentorId,
      disciples: disciples ?? this.disciples,
      displayParameters: displayParameters ?? this.displayParameters,
      phone: phone ?? this.phone,
      occupation: occupation ?? this.occupation,
      gender: gender ?? this.gender,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
