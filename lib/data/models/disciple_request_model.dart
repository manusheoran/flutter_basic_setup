import 'package:cloud_firestore/cloud_firestore.dart';

class DiscipleInfo {
  final String uid;
  final String name;
  final String? email;
  final String? occupation;
  final String? sadhanaName;

  DiscipleInfo({
    required this.uid,
    required this.name,
    this.email,
    this.occupation,
    this.sadhanaName,
  });

  factory DiscipleInfo.fromMap(Map<String, dynamic> map) {
    return DiscipleInfo(
      uid: map['uid'] ?? '',
      name: map['name'] ?? '',
      email: map['email'],
      occupation: map['occupation'],
      sadhanaName: map['sadhanaName'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'name': name,
      if (email != null) 'email': email,
      if (occupation != null) 'occupation': occupation,
      if (sadhanaName != null) 'sadhanaName': sadhanaName,
    };
  }
}

class MasterRequestInfo {
  final String uid;
  final String? name;
  final String? email;

  MasterRequestInfo({
    required this.uid,
    this.name,
    this.email,
  });

  factory MasterRequestInfo.fromMap(Map<String, dynamic> map) {
    return MasterRequestInfo(
      uid: map['uid'] ?? '',
      name: map['name'],
      email: map['email'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      if (name != null) 'name': name,
      if (email != null) 'email': email,
    };
  }
}

// Disciple request model (top-level collection)
class DiscipleRequestModel {
  final String requestId;
  final DiscipleInfo disciple;
  final MasterRequestInfo master;
  final String status; // pending, approved, rejected
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? note;

  DiscipleRequestModel({
    required this.requestId,
    required this.disciple,
    required this.master,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    this.note,
  });

  factory DiscipleRequestModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return DiscipleRequestModel(
      requestId: data['requestId'] ?? doc.id,
      disciple: DiscipleInfo.fromMap(data['disciple'] ?? {}),
      master: MasterRequestInfo.fromMap(data['master'] ?? {}),
      status: data['status'] ?? 'pending',
      createdAt: _parseTimestamp(data['createdAt']),
      updatedAt: _parseTimestamp(data['updatedAt']),
      note: data['note'],
    );
  }

  static DateTime _parseTimestamp(dynamic timestamp) {
    if (timestamp == null) return DateTime.now();
    if (timestamp is Timestamp) return timestamp.toDate();
    if (timestamp is String) return DateTime.tryParse(timestamp) ?? DateTime.now();
    if (timestamp is int) return DateTime.fromMillisecondsSinceEpoch(timestamp);
    if (timestamp is Map && timestamp.containsKey('_seconds')) {
      return DateTime.fromMillisecondsSinceEpoch(
        (timestamp['_seconds'] as int) * 1000,
      );
    }
    return DateTime.now();
  }

  Map<String, dynamic> toFirestore() {
    return {
      'requestId': requestId,
      'disciple': disciple.toMap(),
      'master': master.toMap(),
      'status': status,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      if (note != null) 'note': note,
    };
  }
}
