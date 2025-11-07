import 'package:cloud_firestore/cloud_firestore.dart';

class ActivityData {
  final String? time;
  final int? minutes;
  final int? rounds;
  final double? hours;
  final double score;

  ActivityData({
    this.time,
    this.minutes,
    this.rounds,
    this.hours,
    required this.score,
  });

  Map<String, dynamic> toMap() {
    return {
      if (time != null) 'time': time,
      if (minutes != null) 'minutes': minutes,
      if (rounds != null) 'rounds': rounds,
      if (hours != null) 'hours': hours,
      'score': score,
    };
  }

  factory ActivityData.fromMap(Map<String, dynamic> map) {
    return ActivityData(
      time: map['time'],
      minutes: map['minutes'],
      rounds: map['rounds'],
      hours: map['hours']?.toDouble(),
      score: (map['score'] ?? 0.0).toDouble(),
    );
  }
}

class ActivityModel {
  final String id;
  final String userId;
  final String date; // YYYY-MM-DD
  final ActivityData nindra;
  final ActivityData wakeUp;
  final ActivityData daySleep;
  final ActivityData japa;
  final ActivityData pathan;
  final ActivityData sravan;
  final ActivityData seva;
  final double totalScore;
  final double percentage;
  final DateTime createdAt;
  final DateTime updatedAt;

  ActivityModel({
    required this.id,
    required this.userId,
    required this.date,
    required this.nindra,
    required this.wakeUp,
    required this.daySleep,
    required this.japa,
    required this.pathan,
    required this.sravan,
    required this.seva,
    required this.totalScore,
    required this.percentage,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ActivityModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return ActivityModel(
      id: doc.id,
      userId: data['userId'] ?? '',
      date: data['date'] ?? '',
      nindra: ActivityData.fromMap(data['nindra'] ?? {}),
      wakeUp: ActivityData.fromMap(data['wakeUp'] ?? {}),
      daySleep: ActivityData.fromMap(data['daySleep'] ?? {}),
      japa: ActivityData.fromMap(data['japa'] ?? {}),
      pathan: ActivityData.fromMap(data['pathan'] ?? {}),
      sravan: ActivityData.fromMap(data['sravan'] ?? {}),
      seva: ActivityData.fromMap(data['seva'] ?? {}),
      totalScore: (data['totalScore'] ?? 0.0).toDouble(),
      percentage: (data['percentage'] ?? 0.0).toDouble(),
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'date': date,
      'nindra': nindra.toMap(),
      'wakeUp': wakeUp.toMap(),
      'daySleep': daySleep.toMap(),
      'japa': japa.toMap(),
      'pathan': pathan.toMap(),
      'sravan': sravan.toMap(),
      'seva': seva.toMap(),
      'totalScore': totalScore,
      'percentage': percentage,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  factory ActivityModel.empty(String userId, String date) {
    final now = DateTime.now();
    return ActivityModel(
      id: '',
      userId: userId,
      date: date,
      nindra: ActivityData(score: 0),
      wakeUp: ActivityData(score: 0),
      daySleep: ActivityData(score: 0),
      japa: ActivityData(score: 0),
      pathan: ActivityData(score: 0),
      sravan: ActivityData(score: 0),
      seva: ActivityData(score: 0),
      totalScore: 0,
      percentage: 0,
      createdAt: now,
      updatedAt: now,
    );
  }
}
