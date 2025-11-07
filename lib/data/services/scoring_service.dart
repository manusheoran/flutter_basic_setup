class ScoringService {
  // Calculate Nindra (Sleep Time) score
  static double calculateNindraScore(String? sleepTime) {
    if (sleepTime == null || sleepTime.isEmpty) return 0;
    
    try {
      final parts = sleepTime.split(':');
      final hour = int.parse(parts[0]);
      final minute = int.parse(parts[1]);
      
      // Convert to total minutes from midnight
      final totalMinutes = hour * 60 + minute;
      
      // 21:45 - 22:00 = 25 pts
      if (totalMinutes >= 21 * 60 + 45 && totalMinutes <= 22 * 60) return 25;
      // 22:01 - 22:30 = 20 pts
      if (totalMinutes >= 22 * 60 + 1 && totalMinutes <= 22 * 60 + 30) return 20;
      // 22:31 - 23:00 = 15 pts
      if (totalMinutes >= 22 * 60 + 31 && totalMinutes <= 23 * 60) return 15;
      // 23:01 - 23:30 = 10 pts
      if (totalMinutes >= 23 * 60 + 1 && totalMinutes <= 23 * 60 + 30) return 10;
      // After 23:30 = 5 pts
      return 5;
    } catch (e) {
      return 0;
    }
  }

  // Calculate Wake Up score
  static double calculateWakeUpScore(String? wakeTime) {
    if (wakeTime == null || wakeTime.isEmpty) return 0;
    
    try {
      final parts = wakeTime.split(':');
      final hour = int.parse(parts[0]);
      final minute = int.parse(parts[1]);
      
      final totalMinutes = hour * 60 + minute;
      
      // Before 04:00 = 25 pts
      if (totalMinutes < 4 * 60) return 25;
      // 04:01 - 04:30 = 20 pts
      if (totalMinutes >= 4 * 60 + 1 && totalMinutes <= 4 * 60 + 30) return 20;
      // 04:31 - 05:00 = 15 pts
      if (totalMinutes >= 4 * 60 + 31 && totalMinutes <= 5 * 60) return 15;
      // 05:01 - 05:30 = 10 pts
      if (totalMinutes >= 5 * 60 + 1 && totalMinutes <= 5 * 60 + 30) return 10;
      // After 05:30 = 5 pts
      return 5;
    } catch (e) {
      return 0;
    }
  }

  // Calculate Day Sleep score
  static double calculateDaySleepScore(int? minutes) {
    if (minutes == null) return 0;
    
    if (minutes == 0) return 25;
    if (minutes >= 1 && minutes <= 30) return 15;
    if (minutes >= 31 && minutes <= 60) return 10;
    if (minutes >= 61 && minutes <= 90) return 5;
    return 0;
  }

  // Calculate Japa (Chanting Rounds) score
  static double calculateJapaScore(int? rounds) {
    if (rounds == null) return 0;
    
    if (rounds >= 16) return 25;
    if (rounds >= 14) return 20;
    if (rounds >= 12) return 15;
    if (rounds >= 10) return 10;
    return 5;
  }

  // Calculate Pathan (Reading) score
  static double calculatePathanScore(int? minutes) {
    if (minutes == null) return 0;
    
    if (minutes >= 60) return 25;
    if (minutes >= 45) return 20;
    if (minutes >= 30) return 15;
    if (minutes >= 15) return 10;
    return 5;
  }

  // Calculate Sravan (Listening) score
  static double calculateSravanScore(int? minutes) {
    if (minutes == null) return 0;
    
    if (minutes >= 60) return 25;
    if (minutes >= 45) return 20;
    if (minutes >= 30) return 15;
    if (minutes >= 15) return 10;
    return 5;
  }

  // Calculate Seva (Service) score
  static double calculateSevaScore(double? hours) {
    if (hours == null) return 0;
    
    if (hours >= 4) return 25;
    if (hours >= 3) return 20;
    if (hours >= 2) return 15;
    if (hours >= 1) return 10;
    return 5;
  }

  // Calculate total score and percentage
  static Map<String, double> calculateTotalScore({
    required double nindra,
    required double wakeUp,
    required double daySleep,
    required double japa,
    required double pathan,
    required double sravan,
    required double seva,
  }) {
    final total = nindra + wakeUp + daySleep + japa + pathan + sravan + seva;
    final percentage = (total / 175) * 100;
    
    return {
      'totalScore': total,
      'percentage': percentage,
    };
  }
}
