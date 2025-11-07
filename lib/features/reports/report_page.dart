import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/theme/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../../data/services/auth_service.dart';
import '../../data/services/firestore_service.dart';
import '../../data/services/report_service.dart';
import '../../data/models/activity_model.dart';
import '../../data/models/user_model.dart';

class ReportPage extends StatefulWidget {
  final DateTime? initialStartDate;
  final DateTime? initialEndDate;
  
  const ReportPage({
    super.key,
    this.initialStartDate,
    this.initialEndDate,
  });

  @override
  State<ReportPage> createState() => _ReportPageState();
}

class _ReportPageState extends State<ReportPage> {
  final FirestoreService _firestoreService = Get.find<FirestoreService>();
  final AuthService _authService = Get.find<AuthService>();
  
  bool isLoading = false;
  List<ActivityModel> activities = [];
  UserModel? currentUser;
  
  late DateTime startDate;
  late DateTime endDate;

  @override
  void initState() {
    super.initState();
    // Use passed dates or default to last 30 days
    startDate = widget.initialStartDate ?? DateTime.now().subtract(const Duration(days: 30));
    endDate = widget.initialEndDate ?? DateTime.now();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => isLoading = true);
    
    try {
      final userId = _authService.currentUserId;
      print('📄 Report Page: Loading data for user: $userId');
      
      if (userId == null) {
        throw Exception('User not logged in');
      }

      // Load current user from Firestore if not already loaded
      if (_authService.currentUser.value == null) {
        print('📄 Loading user data from Firestore...');
        await _authService.loadCurrentUser(userId);
      }
      
      currentUser = _authService.currentUser.value;
      print('📄 Current user: ${currentUser?.name ?? "null"}');
      
      // Load activities from database
      print('📄 Report Page: Fetching activities from $startDate to $endDate');
      activities = await _firestoreService.getActivitiesInRange(
        userId,
        startDate,
        endDate,
      );
      
      activities.sort((a, b) => b.date.compareTo(a.date));
      
      print('✅ Report Page: Loaded ${activities.length} activities');
      
    } catch (e) {
      print('❌ Report Page Error: $e');
      Get.snackbar(
        'Error',
        'Failed to load activities: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      setState(() => isLoading = false);
    }
  }

  Future<void> _selectDateRange() async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      initialDateRange: DateTimeRange(start: startDate, end: endDate),
    );
    
    if (picked != null) {
      setState(() {
        startDate = picked.start;
        endDate = picked.end;
      });
      _loadData();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        title: const Text('Export Reports'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadData,
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(AppConstants.kDefaultPadding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildUserCard(),
                  const SizedBox(height: AppConstants.kSpacingL),
                  _buildDateRangeCard(),
                  const SizedBox(height: AppConstants.kSpacingL),
                  _buildStatsCard(),
                  const SizedBox(height: AppConstants.kSpacingL),
                  _buildExportButtons(),
                  const SizedBox(height: AppConstants.kSpacingL),
                  _buildActivityList(),
                ],
              ),
            ),
    );
  }

  Widget _buildUserCard() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.kSpacingL),
        child: Row(
          children: [
            CircleAvatar(
              radius: 30,
              backgroundColor: AppColors.primaryOrange,
              child: Text(
                currentUser?.name.substring(0, 1).toUpperCase() ?? 'U',
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(width: AppConstants.kSpacingM),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    currentUser?.name ?? 'User',
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    currentUser?.email ?? '',
                    style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDateRangeCard() {
    return Card(
      child: InkWell(
        onTap: _selectDateRange,
        child: Padding(
          padding: const EdgeInsets.all(AppConstants.kSpacingL),
          child: Row(
            children: [
              const Icon(Icons.date_range, color: AppColors.primaryOrange),
              const SizedBox(width: AppConstants.kSpacingM),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Report Period',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                    ),
                    Text(
                      '${startDate.day}/${startDate.month}/${startDate.year} - ${endDate.day}/${endDate.month}/${endDate.year}',
                      style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatsCard() {
    if (activities.isEmpty) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(AppConstants.kSpacingL),
          child: Center(
            child: Text(
              'No activities found in this period',
              style: TextStyle(color: Colors.grey[600]),
            ),
          ),
        ),
      );
    }

    double totalScore = activities.fold(0.0, (sum, a) => sum + a.totalScore);
    double avgScore = totalScore / activities.length;
    double avgPercentage = activities.fold(0.0, (sum, a) => sum + a.percentage) / activities.length;

    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.kSpacingL),
        child: Column(
          children: [
            const Text(
              'Statistics',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: AppConstants.kSpacingM),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatItem('Total Days', '${activities.length}', Icons.calendar_today),
                _buildStatItem('Avg Score', avgScore.toStringAsFixed(1), Icons.star),
                _buildStatItem('Avg %', '${avgPercentage.toStringAsFixed(1)}%', Icons.trending_up),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: AppColors.primaryOrange, size: 32),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: AppColors.primaryOrange,
          ),
        ),
        Text(label, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
      ],
    );
  }

  Widget _buildExportButtons() {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton.icon(
            onPressed: activities.isEmpty ? null : () => _exportExcel(),
            icon: const Icon(Icons.table_chart),
            label: const Text('Download Excel Report'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.greenSuccess,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppConstants.kRadiusM),
              ),
            ),
          ),
        ),
        const SizedBox(height: AppConstants.kSpacingM),
        SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton.icon(
            onPressed: activities.isEmpty ? null : () => _exportPdf(),
            icon: const Icon(Icons.picture_as_pdf),
            label: const Text('Download PDF Report'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppConstants.kRadiusM),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActivityList() {
    if (activities.isEmpty) {
      return const SizedBox.shrink();
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.kSpacingM),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Recent Activities',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: AppConstants.kSpacingM),
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: activities.length > 10 ? 10 : activities.length,
              separatorBuilder: (context, index) => const Divider(),
              itemBuilder: (context, index) {
                final activity = activities[index];
                return ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(
                    activity.date,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  subtitle: Text(
                    'Nindra: ${activity.nindra.score.toStringAsFixed(1)} | '
                    'Japa: ${activity.japa.score.toStringAsFixed(1)} | '
                    'Total: ${activity.totalScore.toStringAsFixed(1)}',
                  ),
                  trailing: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.getScoreColor(activity.percentage).withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${activity.percentage.toStringAsFixed(1)}%',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: AppColors.getScoreColor(activity.percentage),
                      ),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _exportExcel() async {
    print('📊 Excel export button clicked');
    
    if (currentUser == null) {
      print('❌ No current user');
      Get.snackbar('Error', 'User not found', backgroundColor: Colors.red, colorText: Colors.white);
      return;
    }
    
    if (activities.isEmpty) {
      print('❌ No activities to export');
      Get.snackbar('Error', 'No activities to export', backgroundColor: Colors.red, colorText: Colors.white);
      return;
    }
    
    print('📊 Exporting ${activities.length} activities for ${currentUser!.name}');
    setState(() => isLoading = true);
    
    try {
      await ReportService.exportToExcel(currentUser!, activities, context);
    } catch (e) {
      print('❌ Export error: $e');
    } finally {
      setState(() => isLoading = false);
    }
  }

  Future<void> _exportPdf() async {
    print('📄 PDF export button clicked');
    
    if (currentUser == null) {
      print('❌ No current user');
      Get.snackbar('Error', 'User not found', backgroundColor: Colors.red, colorText: Colors.white);
      return;
    }
    
    if (activities.isEmpty) {
      print('❌ No activities to export');
      Get.snackbar('Error', 'No activities to export', backgroundColor: Colors.red, colorText: Colors.white);
      return;
    }
    
    print('📄 Exporting ${activities.length} activities for ${currentUser!.name}');
    setState(() => isLoading = true);
    
    try {
      await ReportService.exportToPdf(currentUser!, activities, context);
    } catch (e) {
      print('❌ Export error: $e');
    } finally {
      setState(() => isLoading = false);
    }
  }
}
