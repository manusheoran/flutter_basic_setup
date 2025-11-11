import 'package:cloud_firestore/cloud_firestore.dart';

// Disciple model (subcollection under users/{uid}/disciples)
class DiscipleModel {
  final String uid;
  final String name;
  final String? email;
  final DateTime? joinedAt;
  final String role; // user, master, head, admin
  final String status; // active, removed

  DiscipleModel({
    required this.uid,
    required this.name,
    this.email,
    this.joinedAt,
    this.role = 'user',
    this.status = 'active',
  });

  factory DiscipleModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return DiscipleModel(
      uid: data['uid'] ?? doc.id,
      name: data['name'] ?? '',
      email: data['email'],
      joinedAt: _parseTimestamp(data['joinedAt']),
      role: data['role'] ?? 'user',
      status: data['status'] ?? 'active',
    );
  }

  static DateTime? _parseTimestamp(dynamic timestamp) {
    if (timestamp == null) return null;
    if (timestamp is Timestamp) return timestamp.toDate();
    if (timestamp is String) return DateTime.tryParse(timestamp);
    if (timestamp is int) return DateTime.fromMillisecondsSinceEpoch(timestamp);
    if (timestamp is Map && timestamp.containsKey('_seconds')) {
      return DateTime.fromMillisecondsSinceEpoch(
        (timestamp['_seconds'] as int) * 1000,
      );
    }
    return null;
  }

  Map<String, dynamic> toFirestore() {
    return {
      'uid': uid,
      'name': name,
      if (email != null) 'email': email,
      if (joinedAt != null) 'joinedAt': Timestamp.fromDate(joinedAt!),
      'role': role,
      'status': status,
    };
  }
}
