import 'package:cloud_firestore/cloud_firestore.dart';

// Parameter model for scoring rules
class ParameterModel {
  final String key; // unique key (e.g., 'japa', 'wake_up')
  final String name;
  final String type; // duration, count, time
  final bool enabled;
  final double maxPoints;
  final Map<String, double> scoring; // bucket -> points mapping
  final String? description;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  ParameterModel({
    required this.key,
    required this.name,
    required this.type,
    this.enabled = true,
    required this.maxPoints,
    required this.scoring,
    this.description,
    this.createdAt,
    this.updatedAt,
  });

  factory ParameterModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return ParameterModel(
      key: data['key'] ?? doc.id,
      name: data['name'] ?? '',
      type: data['type'] ?? 'duration',
      enabled: data['enabled'] ?? true,
      maxPoints: (data['maxPoints'] ?? 0).toDouble(),
      scoring: _parseScoringMap(data['scoring']),
      description: data['description'],
      createdAt: _parseTimestamp(data['createdAt']),
      updatedAt: _parseTimestamp(data['updatedAt']),
    );
  }

  static Map<String, double> _parseScoringMap(dynamic scoring) {
    if (scoring == null) return {};
    if (scoring is Map) {
      return scoring.map((key, value) => 
        MapEntry(key.toString(), (value as num).toDouble())
      );
    }
    return {};
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
      'key': key,
      'name': name,
      'type': type,
      'enabled': enabled,
      'maxPoints': maxPoints,
      'scoring': scoring,
      if (description != null) 'description': description,
      if (createdAt != null) 'createdAt': Timestamp.fromDate(createdAt!),
      if (updatedAt != null) 'updatedAt': Timestamp.fromDate(updatedAt!),
    };
  }

  // Calculate score for a given value
  double calculateScore(dynamic value) {
    if (type == 'duration' || type == 'count') {
      // Value should be numeric
      final numValue = value is num ? value.toDouble() : 0.0;
      return _calculateNumericScore(numValue);
    } else if (type == 'time') {
      // Value should be a time string (HH:mm)
      final timeValue = value.toString();
      return _calculateTimeScore(timeValue);
    }
    return 0;
  }

  double _calculateNumericScore(double value) {
    // scoring map format: "0": 0, "1-15": 5, "16-30": 10, "31-9999": 25
    for (var entry in scoring.entries) {
      final bucket = entry.key;
      final points = entry.value;

      if (bucket.contains('-')) {
        final parts = bucket.split('-');
        final min = double.tryParse(parts[0]) ?? 0;
        final max = double.tryParse(parts[1]) ?? double.infinity;
        if (value >= min && value <= max) {
          return points;
        }
      } else {
        // Exact match
        final exactValue = double.tryParse(bucket) ?? -1;
        if (value == exactValue) {
          return points;
        }
      }
    }
    return 0;
  }

  double _calculateTimeScore(String timeValue) {
    // scoring map format: "before:05:30": 10, "05:31-06:30": 5, "06:31-23:59": 0
    try {
      final parts = timeValue.split(':');
      final hour = int.parse(parts[0]);
      final minute = int.parse(parts[1]);
      final totalMinutes = hour * 60 + minute;

      for (var entry in scoring.entries) {
        final bucket = entry.key;
        final points = entry.value;

        if (bucket.startsWith('before:')) {
          final beforeTime = bucket.substring(7);
          final beforeParts = beforeTime.split(':');
          final beforeHour = int.parse(beforeParts[0]);
          final beforeMinute = int.parse(beforeParts[1]);
          final beforeTotalMinutes = beforeHour * 60 + beforeMinute;
          
          if (totalMinutes < beforeTotalMinutes) {
            return points;
          }
        } else if (bucket.contains('-')) {
          final timeParts = bucket.split('-');
          final startTime = timeParts[0];
          final endTime = timeParts[1];
          
          final startParts = startTime.split(':');
          final startHour = int.parse(startParts[0]);
          final startMinute = int.parse(startParts[1]);
          final startTotalMinutes = startHour * 60 + startMinute;
          
          final endParts = endTime.split(':');
          final endHour = int.parse(endParts[0]);
          final endMinute = int.parse(endParts[1]);
          final endTotalMinutes = endHour * 60 + endMinute;
          
          if (totalMinutes >= startTotalMinutes && totalMinutes <= endTotalMinutes) {
            return points;
          }
        }
      }
    } catch (e) {
      return 0;
    }
    return 0;
  }
}
