import 'package:cloud_firestore/cloud_firestore.dart';

// Analytics data for each activity
class ActivityAnalytics {
  final double? duration;  // For duration-based activities (in minutes)
  final DateTime? timestamp;  // For timestamp-based activities
  final double? pointsAchieved;
  final double? maxAchievablePoints;
  final double? defaultValue;
  final String status;  // active, inactive, etc.

  ActivityAnalytics({
    this.duration,
    this.timestamp,
    this.pointsAchieved,
    this.maxAchievablePoints,
    this.defaultValue,
    this.status = 'active',
  });

  factory ActivityAnalytics.fromMap(Map<String, dynamic> map) {
    return ActivityAnalytics(
      duration: map['duration']?.toDouble(),
      timestamp: _parseTimestamp(map['timestamp']),
      pointsAchieved: map['pointsAchieved']?.toDouble(),
      maxAchievablePoints: map['maxAchievablePoints']?.toDouble(),
      defaultValue: map['default']?.toDouble(),
      status: map['status'] ?? 'active',
    );
  }

  static DateTime? _parseTimestamp(dynamic timestamp) {
    if (timestamp == null) return null;
    if (timestamp is Timestamp) return timestamp.toDate();
    if (timestamp is String) return DateTime.tryParse(timestamp);
    if (timestamp is int) return DateTime.fromMillisecondsSinceEpoch(timestamp);
    return null;
  }

  Map<String, dynamic> toMap() {
    return {
      if (duration != null) 'duration': duration,
      if (timestamp != null) 'timestamp': Timestamp.fromDate(timestamp!),
      if (pointsAchieved != null) 'pointsAchieved': pointsAchieved,
      if (maxAchievablePoints != null) 'maxAchievablePoints': maxAchievablePoints,
      if (defaultValue != null) 'default': defaultValue,
      'status': status,
    };
  }
}

// Individual activity item
class ActivityItem {
  final String id; // sadhana key or unique id
  final String name;
  final String type; // timestamp/duration | time | count
  final Map<String, dynamic> extras; // rounds, timestamp, duration, value, etc.
  final ActivityAnalytics? analytics;
  final DateTime? createdAt;

  ActivityItem({
    required this.id,
    required this.name,
    required this.type,
    this.extras = const {},
    this.analytics,
    this.createdAt,
  });

  factory ActivityItem.fromMap(String key, Map<String, dynamic> map) {
    return ActivityItem(
      id: map['id'] ?? map['sadhanaid'] ?? key,
      name: map['name'] ?? '',
      type: map['type'] ?? 'duration',
      extras: Map<String, dynamic>.from(map['extras'] ?? {}),
      analytics: map['analytics'] != null
          ? ActivityAnalytics.fromMap(map['analytics'])
          : null,
      createdAt: _parseTimestamp(map['createdAt']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'type': type,
      'extras': extras,
      if (analytics != null) 'analytics': analytics!.toMap(),
      if (createdAt != null) 'createdAt': Timestamp.fromDate(createdAt!),
    };
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
}

// Overall analytics for the day
class DailyAnalytics {
  final double? totalPointsAchieved;
  final double? totalMaxAchievablePoints;

  DailyAnalytics({
    this.totalPointsAchieved,
    this.totalMaxAchievablePoints,
  });

  factory DailyAnalytics.fromMap(Map<String, dynamic> map) {
    return DailyAnalytics(
      totalPointsAchieved: map['totalPointsAchieved']?.toDouble(),
      totalMaxAchievablePoints: map['totalMaxAchievablePoints']?.toDouble(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (totalPointsAchieved != null) 'totalPointsAchieved': totalPointsAchieved,
      if (totalMaxAchievablePoints != null)
        'totalMaxAchievablePoints': totalMaxAchievablePoints,
    };
  }

  double get percentage {
    if (totalMaxAchievablePoints == null || totalMaxAchievablePoints == 0) {
      return 0;
    }
    return ((totalPointsAchieved ?? 0) / totalMaxAchievablePoints!) * 100;
  }
}

// Main DailyActivity model
class DailyActivity {
  final String docId;
  final String uid;
  final dynamic date; // Can be Timestamp, String, or dateKey
  final DateTime createdAt;
  final DateTime updatedAt;
  final String status; // active, locked
  final String? notes;
  final Map<String, ActivityItem> activities; // key -> ActivityItem
  final DailyAnalytics? analytics;
  final DateTime? pointsComputedAt;

  DailyActivity({
    required this.docId,
    required this.uid,
    required this.date,
    required this.createdAt,
    required this.updatedAt,
    this.status = 'active',
    this.notes,
    this.activities = const {},
    this.analytics,
    this.pointsComputedAt,
  });

  // Parse date to DateTime
  DateTime get dateTime {
    if (date is Timestamp) return (date as Timestamp).toDate();
    if (date is String) return DateTime.tryParse(date) ?? DateTime.now();
    if (date is DateTime) return date;
    return DateTime.now();
  }

  // Get date as YYYY-MM-DD string
  String get dateString {
    final dt = dateTime;
    return '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}';
  }

  factory DailyActivity.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    Map<String, ActivityItem> activities = {};

    // Parse activities - handle both map and array shapes
    if (data['activities'] != null) {
      if (data['activities'] is Map) {
        // Map shape: key -> activity object
        final activitiesMap = data['activities'] as Map<String, dynamic>;
        activitiesMap.forEach((key, value) {
          if (value is Map<String, dynamic>) {
            activities[key] = ActivityItem.fromMap(key, value);
          }
        });
      } else if (data['activities'] is List) {
        // Array shape: list of activity objects
        final activitiesList = data['activities'] as List;
        for (var item in activitiesList) {
          if (item is Map<String, dynamic>) {
            final activityItem = ActivityItem.fromMap(
              item['id'] ?? item['sadhanaid'] ?? '',
              item,
            );
            activities[activityItem.id] = activityItem;
          }
        }
      }
    }

    return DailyActivity(
      docId: data['docId'] ?? doc.id,
      uid: data['uid'] ?? '',
      date: data['date'],
      createdAt: _parseTimestamp(data['createdAt']),
      updatedAt: _parseTimestamp(data['updatedAt']),
      status: data['status'] ?? 'active',
      notes: data['notes'],
      activities: activities,
      analytics: data['analytics'] != null
          ? DailyAnalytics.fromMap(data['analytics'])
          : null,
      pointsComputedAt: _parseTimestamp(data['pointsComputedAt']),
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
    // Convert activities map to map shape (preferred for Firestore)
    final activitiesMap = <String, dynamic>{};
    activities.forEach((key, item) {
      activitiesMap[key] = item.toMap();
    });

    return {
      'docId': docId,
      'uid': uid,
      'date': date is DateTime
          ? Timestamp.fromDate(date as DateTime)
          : (date is String ? date : Timestamp.fromDate(DateTime.now())),
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      'status': status,
      if (notes != null) 'notes': notes,
      'activities': activitiesMap,
      if (analytics != null) 'analytics': analytics!.toMap(),
      if (pointsComputedAt != null)
        'pointsComputedAt': Timestamp.fromDate(pointsComputedAt!),
    };
  }

  factory DailyActivity.empty(String uid, String date) {
    final now = DateTime.now();
    return DailyActivity(
      docId: '',
      uid: uid,
      date: date,
      createdAt: now,
      updatedAt: now,
      status: 'active',
      activities: {},
    );
  }

  // Helper to get total points
  double get totalPoints {
    return analytics?.totalPointsAchieved ?? 0;
  }

  // Helper to get max points
  double get maxPoints {
    return analytics?.totalMaxAchievablePoints ?? 0;
  }

  // Helper to get percentage
  double get percentage {
    return analytics?.percentage ?? 0;
  }

  // Get activity by key
  ActivityItem? getActivity(String key) {
    return activities[key];
  }

  // Update or add activity
  DailyActivity updateActivity(String key, ActivityItem item) {
    final newActivities = Map<String, ActivityItem>.from(activities);
    newActivities[key] = item;
    return DailyActivity(
      docId: docId,
      uid: uid,
      date: date,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
      status: status,
      notes: notes,
      activities: newActivities,
      analytics: analytics,
      pointsComputedAt: pointsComputedAt,
    );
  }
}
