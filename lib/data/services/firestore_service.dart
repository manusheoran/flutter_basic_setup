import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import '../models/activity_model.dart';
import '../models/user_model.dart';
import 'package:intl/intl.dart';

class FirestoreService extends GetxService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Activities Collection
  CollectionReference get _activities => _firestore.collection('activities');
  
  // Users Collection
  CollectionReference get _users => _firestore.collection('users');

  // Create or Update Activity
  Future<void> saveActivity(ActivityModel activity) async {
    try {
      if (activity.id.isEmpty) {
        // Create new with auto-generated ID
        await _activities.add(activity.toFirestore());
      } else {
        // Update existing or create new with specific ID
        // Use set with merge to create if doesn't exist or update if exists
        await _activities.doc(activity.id).set(
          activity.toFirestore(),
          SetOptions(merge: true),
        );
      }
    } catch (e) {
      throw Exception('Failed to save activity: $e');
    }
  }

  // Get activity for a specific date
  Future<ActivityModel?> getActivityByDate(String userId, String date) async {
    try {
      final querySnapshot = await _activities
          .where('userId', isEqualTo: userId)
          .where('date', isEqualTo: date)
          .limit(1)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        return ActivityModel.fromFirestore(querySnapshot.docs.first);
      }
      return null;
    } catch (e) {
      print('Error getting activity: $e');
      return null;
    }
  }

  // Get activities for date range
  Future<List<ActivityModel>> getActivitiesInRange(
    String userId,
    DateTime startDate,
    DateTime endDate,
  ) async {
    try {
      final start = DateFormat('yyyy-MM-dd').format(startDate);
      final end = DateFormat('yyyy-MM-dd').format(endDate);

      print('🔍 Querying activities: userId=$userId, start=$start, end=$end');

      // Query all user activities (no composite index needed)
      final querySnapshot = await _activities
          .where('userId', isEqualTo: userId)
          .get();

      // Filter by date range in app code
      final activities = querySnapshot.docs
          .map((doc) => ActivityModel.fromFirestore(doc))
          .where((activity) {
            return activity.date.compareTo(start) >= 0 && 
                   activity.date.compareTo(end) <= 0;
          })
          .toList();
      
      print('✅ Found ${activities.length} activities in date range');
      
      return activities;
    } catch (e) {
      print('❌ Error getting activities in range: $e');
      return [];
    }
  }

  // Get all activities for a user
  Stream<List<ActivityModel>> getUserActivitiesStream(String userId) {
    return _activities
        .where('userId', isEqualTo: userId)
        .orderBy('date', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => ActivityModel.fromFirestore(doc))
            .toList());
  }

  // Get activities for mentor's disciples
  Future<List<ActivityModel>> getDiscipleActivities(
    List<String> discipleIds,
    DateTime startDate,
    DateTime endDate,
  ) async {
    if (discipleIds.isEmpty) return [];

    try {
      final start = DateFormat('yyyy-MM-dd').format(startDate);
      final end = DateFormat('yyyy-MM-dd').format(endDate);

      final querySnapshot = await _activities
          .where('userId', whereIn: discipleIds)
          .where('date', isGreaterThanOrEqualTo: start)
          .where('date', isLessThanOrEqualTo: end)
          .get();

      return querySnapshot.docs
          .map((doc) => ActivityModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      print('Error getting disciple activities: $e');
      return [];
    }
  }

  // User Management (for admin)
  Future<List<UserModel>> getAllUsers() async {
    try {
      final querySnapshot = await _users.get();
      return querySnapshot.docs
          .map((doc) => UserModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      print('Error getting users: $e');
      return [];
    }
  }

  Future<UserModel?> getUserById(String uid) async {
    try {
      final doc = await _users.doc(uid).get();
      if (doc.exists) {
        return UserModel.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      print('Error getting user: $e');
      return null;
    }
  }

  Future<void> updateUser(UserModel user) async {
    try {
      await _users.doc(user.uid).update(user.toFirestore());
    } catch (e) {
      throw Exception('Failed to update user: $e');
    }
  }

  Future<void> deleteUser(String uid) async {
    try {
      // Delete user document
      await _users.doc(uid).delete();
      
      // Delete user's activities
      final activities = await _activities
          .where('userId', isEqualTo: uid)
          .get();
      
      for (var doc in activities.docs) {
        await doc.reference.delete();
      }
    } catch (e) {
      throw Exception('Failed to delete user: $e');
    }
  }

  // Request mentor
  Future<void> requestMentor(String userId, String mentorId, String mentorName) async {
    try {
      final userDoc = await _users.doc(userId).get();
      final userData = userDoc.data() as Map<String, dynamic>;
      
      List<dynamic> requests = userData['mentorRequests'] ?? [];
      requests.add({
        'mentorId': mentorId,
        'mentorName': mentorName,
        'status': 'pending',
        'requestedAt': Timestamp.now(),
      });
      
      await _users.doc(userId).update({'mentorRequests': requests});
    } catch (e) {
      throw Exception('Failed to request mentor: $e');
    }
  }

  // Approve/Reject mentor request
  Future<void> handleMentorRequest(
    String discipleId,
    String mentorId,
    bool approve,
  ) async {
    try {
      if (approve) {
        // Update disciple's mentorId
        await _users.doc(discipleId).update({'mentorId': mentorId});
        
        // Add disciple to mentor's disciples list
        final mentorDoc = await _users.doc(mentorId).get();
        final mentorData = mentorDoc.data() as Map<String, dynamic>;
        List<String> disciples = List<String>.from(mentorData['disciples'] ?? []);
        if (!disciples.contains(discipleId)) {
          disciples.add(discipleId);
          await _users.doc(mentorId).update({'disciples': disciples});
        }
      }
      
      // Update request status in disciple's document
      final discipleDoc = await _users.doc(discipleId).get();
      final discipleData = discipleDoc.data() as Map<String, dynamic>;
      List<dynamic> requests = discipleData['mentorRequests'] ?? [];
      
      for (var request in requests) {
        if (request['mentorId'] == mentorId) {
          request['status'] = approve ? 'approved' : 'rejected';
        }
      }
      
      await _users.doc(discipleId).update({'mentorRequests': requests});
    } catch (e) {
      throw Exception('Failed to handle mentor request: $e');
    }
  }

  // Search users by name or email
  Future<List<UserModel>> searchUsers(String query) async {
    try {
      final querySnapshot = await _users
          .where('name', isGreaterThanOrEqualTo: query)
          .where('name', isLessThanOrEqualTo: query + '\uf8ff')
          .get();

      return querySnapshot.docs
          .map((doc) => UserModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      print('Error searching users: $e');
      return [];
    }
  }
}
