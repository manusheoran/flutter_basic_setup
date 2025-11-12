import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import '../models/parameter_model.dart';

class ParameterService extends GetxService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Parameters collection
  CollectionReference get _parameters => _firestore.collection('parameters');

  // Cache parameters
  final RxMap<String, ParameterModel> _cachedParameters = <String, ParameterModel>{}.obs;
  final RxBool _isLoaded = false.obs;
  Future<void>? _loadingFuture;

  // Getters
  bool get isLoaded => _isLoaded.value;
  Map<String, ParameterModel> get parameters => _cachedParameters;

  // Load all parameters
  Future<void> loadParameters({bool force = false}) async {
    if (force) {
      _isLoaded.value = false;
    }

    if (_isLoaded.value && !force) {
      return;
    }

    if (_loadingFuture != null) {
      return _loadingFuture!;
    }

    _loadingFuture = _loadParametersFromFirestore();

    try {
      await _loadingFuture;
    } finally {
      _loadingFuture = null;
    }
  }

  Future<void> ensureLoaded() => loadParameters();

  Future<void> _loadParametersFromFirestore() async {
    try {
      final querySnapshot = await _parameters
          .where('enabled', isEqualTo: true)
          .get();

      _cachedParameters.clear();
      for (var doc in querySnapshot.docs) {
        final parameter = ParameterModel.fromFirestore(doc);
        _cachedParameters[parameter.key] = parameter;
      }

      // If no parameters found in Firestore, initialize them from defaults
      if (_cachedParameters.isEmpty) {
        print('📦 No parameters in Firestore, initializing from defaults...');
        await initializeDefaultParameters();
        // Reload after initialization
        final newSnapshot = await _parameters
            .where('enabled', isEqualTo: true)
            .get();
        _cachedParameters.clear();
        for (var doc in newSnapshot.docs) {
          final parameter = ParameterModel.fromFirestore(doc);
          _cachedParameters[parameter.key] = parameter;
        }
      }

      _isLoaded.value = true;
      print('✅ Loaded ${_cachedParameters.length} parameters from Firestore');
    } catch (e) {
      print('❌ Error loading parameters: $e');
      _isLoaded.value = false;
      rethrow;
    }
  }
  

  // Get parameter by key
  ParameterModel? getParameter(String key) {
    return _cachedParameters[key];
  }

  // Get all enabled parameters
  List<ParameterModel> getAllParameters() {
    return _cachedParameters.values.toList();
  }

  // Get parameters stream (for admin)
  Stream<List<ParameterModel>> getParametersStream() {
    return _parameters
        .orderBy('key')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => ParameterModel.fromFirestore(doc))
            .toList());
  }

  // Create or update parameter (admin only)
  Future<void> saveParameter(ParameterModel parameter) async {
    try {
      final doc = _parameters.doc(parameter.key);
      await doc.set(parameter.toFirestore(), SetOptions(merge: true));
      
      // Update cache
      if (parameter.enabled) {
        _cachedParameters[parameter.key] = parameter;
      } else {
        _cachedParameters.remove(parameter.key);
      }
    } catch (e) {
      throw Exception('Failed to save parameter: $e');
    }
  }

  // Delete parameter (admin only)
  Future<void> deleteParameter(String key) async {
    try {
      await _parameters.doc(key).delete();
      _cachedParameters.remove(key);
    } catch (e) {
      throw Exception('Failed to delete parameter: $e');
    }
  }

  // Calculate score for a given parameter and value
  double calculateScore(String parameterKey, dynamic value) {
    final parameter = getParameter(parameterKey);
    if (parameter == null) return 0;
    return parameter.calculateScore(value);
  }

  // Get max points for a parameter
  double getMaxPoints(String parameterKey) {
    final parameter = getParameter(parameterKey);
    return parameter?.maxPoints ?? 0;
  }

  // Get total max points for all active parameters
  double getTotalMaxPoints() {
    return _cachedParameters.values.fold(0, (sum, param) => sum + param.maxPoints);
  }

  // Get total max points for specific parameters
  double getTotalMaxPointsFor(List<String> keys) {
    double total = 0;
    for (var key in keys) {
      total += getMaxPoints(key);
    }
    return total;
  }

  // Get default parameters list
  List<ParameterModel> _getDefaultParametersList() {
    final now = DateTime.now();
    return [
        // NINDRA (To Bed) - Evening time scoring
        ParameterModel(
          key: 'nindra',
          name: 'Nindra (To Bed)',
          type: 'time',
          maxPoints: 25,
          scoring: {
            '21:45-22:00': 25,
            '22:00-22:15': 20,
            '22:15-22:30': 15,
            '22:30-22:45': 10,
            '22:45-23:00': 5,
            '23:00-23:15': 0,
            '23:15-23:59': -5,
            '00:00-21:44': -5,
          },
          description: 'Night sleep time (PM)',
          enabled: true,
          createdAt: now,
          updatedAt: now,
        ),
        // WAKE UP - Morning time scoring
        ParameterModel(
          key: 'wake_up',
          name: 'Wake Up Time',
          type: 'time',
          maxPoints: 25,
          scoring: {
            '03:45-04:00': 25,
            '04:00-04:15': 20,
            '04:15-04:30': 15,
            '04:30-04:45': 10,
            '04:45-05:00': 5,
            '05:00-05:15': 0,
            '05:15-23:59': -5,
            '00:00-03:44': -5,
          },
          description: 'Morning wake up time',
          enabled: true,
          createdAt: now,
          updatedAt: now,
        ),
        // DAY SLEEP - Duration scoring
        ParameterModel(
          key: 'day_sleep',
          name: 'Day Sleep',
          type: 'duration',
          maxPoints: 25,
          scoring: {
            '0': 0,           // No data entered = 0 points
            '1-60': 25,       // 1-60 minutes = 25 points (good, minimal sleep)
            '61-75': 20,
            '76-90': 15,
            '91-105': 10,
            '106-120': 5,
            '121-135': 0,
            '136-9999': -5,
          },
          description: 'Day sleep in minutes',
          enabled: true,
          createdAt: now,
          updatedAt: now,
        ),
        // JAPA - Time when completed
        ParameterModel(
          key: 'japa',
          name: 'Japa (Chanting)',
          type: 'time',
          maxPoints: 25,
          scoring: {
            '00:00-07:15': 25,
            '07:15-09:30': 20,
            '09:30-13:00': 15,
            '13:00-19:00': 10,
            '19:00-21:00': 5,
            '21:00-23:00': 0,
            '23:00-23:59': -5,
          },
          description: 'Japa completion time',
          enabled: true,
          createdAt: now,
          updatedAt: now,
        ),
        // PATHAN (Reading) - Duration
        ParameterModel(
          key: 'pathan',
          name: 'Pathan (Reading)',
          type: 'duration',
          maxPoints: 30,
          scoring: {
            '0-4': 0,
            '5-14': 5,
            '15-24': 10,
            '25-34': 15,
            '35-44': 20,
            '45-60': 25,
            '61-9999': 30,  // Above 1 hour
          },
          description: 'Reading in minutes',
          enabled: true,
          createdAt: now,
          updatedAt: now,
        ),
        // SRAVAN (Listening) - Duration
        ParameterModel(
          key: 'sravan',
          name: 'Sravan (Listening)',
          type: 'duration',
          maxPoints: 30,
          scoring: {
            '0-4': 0,
            '5-14': 5,
            '15-24': 10,
            '25-34': 15,
            '35-44': 20,
            '45-60': 25,
            '61-9999': 30,  // Above 1 hour
          },
          description: 'Listening in minutes',
          enabled: true,
          createdAt: now,
          updatedAt: now,
        ),
        // SEVA (Service) - Duration in intervals
        ParameterModel(
          key: 'seva',
          name: 'Seva (Service)',
          type: 'duration',
          maxPoints: 100,
          scoring: {
            '0-90': 0,
            '91-120': 20,
            '121-150': 40,
            '151-180': 60,
            '181-210': 80,
            '211-9999': 100,
          },
          description: 'Service in minutes',
          enabled: true,
          createdAt: now,
          updatedAt: now,
        ),
    ];
  }

  // Initialize default parameters in Firestore (one-time operation)
  Future<void> initializeDefaultParameters() async {
    try {
      // Check if parameters already exist
      final snapshot = await _parameters.limit(1).get();
      if (snapshot.docs.isNotEmpty) {
        print('✅ Parameters already exist in Firestore, skipping initialization');
        return;
      }

      print('🚀 Initializing default parameters in Firestore...');
      final defaultParameters = _getDefaultParametersList();
      
      // Batch write for better performance
      final batch = _firestore.batch();
      for (var param in defaultParameters) {
        final docRef = _parameters.doc(param.key);
        batch.set(docRef, param.toFirestore());
      }
      await batch.commit();

      print('✅ Successfully initialized ${defaultParameters.length} parameters in Firestore');
      print('   Parameters: ${defaultParameters.map((p) => p.key).join(", ")}');
    } catch (e) {
      print('❌ Error initializing default parameters: $e');
      rethrow;
    }
  }
}
