import 'package:cloud_firestore/cloud_firestore.dart';

// Export job filters
class ExportFilters {
  final List<String>? userIds;
  final String? dateFrom;
  final String? dateTo;
  final List<String>? parameters;

  ExportFilters({
    this.userIds,
    this.dateFrom,
    this.dateTo,
    this.parameters,
  });

  factory ExportFilters.fromMap(Map<String, dynamic> map) {
    return ExportFilters(
      userIds: map['userIds'] != null ? List<String>.from(map['userIds']) : null,
      dateFrom: map['dateFrom'],
      dateTo: map['dateTo'],
      parameters: map['parameters'] != null ? List<String>.from(map['parameters']) : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (userIds != null) 'userIds': userIds,
      if (dateFrom != null) 'dateFrom': dateFrom,
      if (dateTo != null) 'dateTo': dateTo,
      if (parameters != null) 'parameters': parameters,
    };
  }
}

// Export job model (optional - for future export jobs)
class ExportJobModel {
  final String jobId;
  final String requestedBy;
  final String status; // pending, processing, done, failed
  final DateTime createdAt;
  final DateTime? completedAt;
  final ExportFilters? filters;
  final String? fileUrl;
  final String fileType; // csv, xlsx, pdf
  final String? error;

  ExportJobModel({
    required this.jobId,
    required this.requestedBy,
    required this.status,
    required this.createdAt,
    this.completedAt,
    this.filters,
    this.fileUrl,
    this.fileType = 'xlsx',
    this.error,
  });

  factory ExportJobModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return ExportJobModel(
      jobId: data['jobId'] ?? doc.id,
      requestedBy: data['requestedBy'] ?? '',
      status: data['status'] ?? 'pending',
      createdAt: _parseTimestamp(data['createdAt']),
      completedAt: _parseTimestamp(data['completedAt']),
      filters: data['filters'] != null ? ExportFilters.fromMap(data['filters']) : null,
      fileUrl: data['fileUrl'],
      fileType: data['fileType'] ?? 'xlsx',
      error: data['error'],
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
      'jobId': jobId,
      'requestedBy': requestedBy,
      'status': status,
      'createdAt': Timestamp.fromDate(createdAt),
      if (completedAt != null) 'completedAt': Timestamp.fromDate(completedAt!),
      if (filters != null) 'filters': filters!.toMap(),
      if (fileUrl != null) 'fileUrl': fileUrl,
      'fileType': fileType,
      if (error != null) 'error': error,
    };
  }
}
