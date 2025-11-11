import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import '../models/activity_model.dart';
import '../models/user_model.dart';
import '../models/disciple_model.dart';
import '../models/disciple_request_model.dart';
import 'package:intl/intl.dart';

class FirestoreService extends GetxService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Collections
  CollectionReference get _dailyActivities => _firestore.collection('daily_activities');
  CollectionReference get _users => _firestore.collection('users');
  CollectionReference get _discipleRequests => _firestore.collection('disciple_requests');

  // Generate consistent docId from userId and date
  String _generateDocId(String userId, String date) {
    return '${userId}_$date';
  }

  // Create or Update Daily Activity
  Future<void> saveDailyActivity(DailyActivity activity) async {
    try {
      // Always use consistent docId format: userId_date
      final docId = _generateDocId(activity.uid, activity.dateString);
      
      await _dailyActivities.doc(docId).set(
        activity.toFirestore(),
        SetOptions(merge: true),
      );
    } catch (e) {
      throw Exception('Failed to save activity: $e');
    }
  }

  // Get activity for a specific date
  Future<DailyActivity?> getActivityByDate(String userId, String date) async {
    try {
      // Use consistent docId to fetch directly
      final docId = _generateDocId(userId, date);
      final docSnapshot = await _dailyActivities.doc(docId).get();

      if (docSnapshot.exists) {
        return DailyActivity.fromFirestore(docSnapshot);
      }
      return null;
    } catch (e) {
      print('Error getting activity: $e');
      return null;
    }
  }
  
  // Create default activity with all parameters set to 0/empty
  Future<void> createDefaultActivity(String userId, String date) async {
    try {
      final docId = _generateDocId(userId, date);
      
      // Check if activity already exists
      final existing = await getActivityByDate(userId, date);
      if (existing != null) {
        print('Activity for $date already exists');
        return;
      }
      
      // Create empty activities map - no activities tracked by default
      final activity = DailyActivity(
        docId: docId,
        uid: userId,
        date: date,
        activities: {}, // Empty - user will add activities
        analytics: DailyAnalytics(
          totalPointsAchieved: 0,
          totalMaxAchievablePoints: 230,
        ),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      
      await _dailyActivities.doc(docId).set(activity.toFirestore());
      print('✅ Created default activity for $date');
    } catch (e) {
      print('Error creating default activity: $e');
    }
  }
  
  // Remove specific activity from a date (for turning off tracking)
  Future<void> removeActivityForDate(String userId, String date, String activityKey) async {
    try {
      final docId = _generateDocId(userId, date);
      final docSnapshot = await _dailyActivities.doc(docId).get();
      
      if (!docSnapshot.exists) {
        print('No activity document found for $date');
        return;
      }
      
      // Get current data
      final data = docSnapshot.data() as Map<String, dynamic>;
      final activities = Map<String, dynamic>.from(data['activities'] ?? {});
      
      // Remove the specific activity
      activities.remove(activityKey);
      
      // Update document
      await _dailyActivities.doc(docId).update({
        'activities': activities,
        'updatedAt': Timestamp.now(),
      });
      
      print('✅ Removed $activityKey from $date');
    } catch (e) {
      print('Error removing activity: $e');
    }
  }

  // Get activities for date range
  Future<List<DailyActivity>> getActivitiesInRange(
    String userId,
    DateTime startDate,
    DateTime endDate,
  ) async {
    try {
      final start = DateFormat('yyyy-MM-dd').format(startDate);
      final end = DateFormat('yyyy-MM-dd').format(endDate);

      print('🔍 Querying activities: userId=$userId, start=$start, end=$end');

      // Query all user activities (no composite index needed)
      final querySnapshot = await _dailyActivities
          .where('uid', isEqualTo: userId)
          .get();

      // Filter by date range in app code
      final activities = querySnapshot.docs
          .map((doc) => DailyActivity.fromFirestore(doc))
          .where((activity) {
            final activityDate = activity.dateString;
            return activityDate.compareTo(start) >= 0 && 
                   activityDate.compareTo(end) <= 0;
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
  Stream<List<DailyActivity>> getUserActivitiesStream(String userId) {
    return _dailyActivities
        .where('uid', isEqualTo: userId)
        .orderBy('date', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => DailyActivity.fromFirestore(doc))
            .toList());
  }

  // Get activities for mentor's disciples
  Future<List<DailyActivity>> getDiscipleActivities(
    List<String> discipleIds,
    DateTime startDate,
    DateTime endDate,
  ) async {
    if (discipleIds.isEmpty) return [];

    try {
      final start = DateFormat('yyyy-MM-dd').format(startDate);
      final end = DateFormat('yyyy-MM-dd').format(endDate);

      final querySnapshot = await _dailyActivities
          .where('uid', whereIn: discipleIds)
          .where('date', isGreaterThanOrEqualTo: start)
          .where('date', isLessThanOrEqualTo: end)
          .get();

      return querySnapshot.docs
          .map((doc) => DailyActivity.fromFirestore(doc))
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
      final activities = await _dailyActivities
          .where('uid', isEqualTo: uid)
          .get();
      
      for (var doc in activities.docs) {
        await doc.reference.delete();
      }
    } catch (e) {
      throw Exception('Failed to delete user: $e');
    }
  }

  // Request mentor (using new disciple_requests collection)
  Future<void> requestMentor(
    String discipleUid,
    String discipleName,
    String discipleEmail,
    String masterUid,
    String masterName,
    String masterEmail,
  ) async {
    try {
      final request = DiscipleRequestModel(
        requestId: '',
        disciple: DiscipleInfo(
          uid: discipleUid,
          name: discipleName,
          email: discipleEmail,
        ),
        master: MasterRequestInfo(
          uid: masterUid,
          name: masterName,
          email: masterEmail,
        ),
        status: 'pending',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      
      await _discipleRequests.add(request.toFirestore());
    } catch (e) {
      throw Exception('Failed to request mentor: $e');
    }
  }

  // Approve/Reject mentor request (using new schema)
  Future<void> handleMentorRequest(
    String requestId,
    bool approve,
  ) async {
    try {
      final requestDoc = await _discipleRequests.doc(requestId).get();
      if (!requestDoc.exists) {
        throw Exception('Request not found');
      }
      
      final request = DiscipleRequestModel.fromFirestore(requestDoc);
      
      if (approve) {
        // Update disciple's master field
        await _users.doc(request.disciple.uid).update({
          'master': {
            'uid': request.master.uid,
            'name': request.master.name,
            'email': request.master.email,
          },
          'updatedAt': Timestamp.now(),
        });
        
        // Add disciple to master's disciples subcollection
        final discipleModel = DiscipleModel(
          uid: request.disciple.uid,
          name: request.disciple.name,
          email: request.disciple.email,
          joinedAt: DateTime.now(),
          status: 'active',
        );
        
        await _users
            .doc(request.master.uid)
            .collection('disciples')
            .doc(request.disciple.uid)
            .set(discipleModel.toFirestore());
      }
      
      // Update request status
      await _discipleRequests.doc(requestId).update({
        'status': approve ? 'approved' : 'rejected',
        'updatedAt': Timestamp.now(),
      });
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

  // Get disciples for a master (from subcollection)
  Future<List<DiscipleModel>> getDisciples(String masterUid) async {
    try {
      final querySnapshot = await _users
          .doc(masterUid)
          .collection('disciples')
          .where('status', isEqualTo: 'active')
          .get();

      return querySnapshot.docs
          .map((doc) => DiscipleModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      print('Error getting disciples: $e');
      return [];
    }
  }

  // Get disciple UIDs for a master
  Future<List<String>> getDiscipleUids(String masterUid) async {
    try {
      final disciples = await getDisciples(masterUid);
      return disciples.map((d) => d.uid).toList();
    } catch (e) {
      print('Error getting disciple UIDs: $e');
      return [];
    }
  }

  // Get pending disciple requests for a master
  Future<List<DiscipleRequestModel>> getPendingRequests(String masterUid) async {
    try {
      final querySnapshot = await _discipleRequests
          .where('master.uid', isEqualTo: masterUid)
          .where('status', isEqualTo: 'pending')
          .get();

      return querySnapshot.docs
          .map((doc) => DiscipleRequestModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      print('Error getting pending requests: $e');
      return [];
    }
  }

  // Get all disciple requests for a master
  Stream<List<DiscipleRequestModel>> getDiscipleRequestsStream(String masterUid) {
    return _discipleRequests
        .where('master.uid', isEqualTo: masterUid)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => DiscipleRequestModel.fromFirestore(doc))
            .toList());
  }
}
