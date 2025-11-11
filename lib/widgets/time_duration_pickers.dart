import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../core/theme/app_colors.dart';
import '../core/constants/app_constants.dart';

/// 12-Hour Time Picker with AM/PM for timestamp activities
class TimestampPicker extends StatelessWidget {
  final String title;
  final RxString selectedTime; // Stored as 24-hour HH:mm format
  final Function(String) onTimeChanged;
  final String? minTime; // Optional minimum time in 24-hour format (e.g., "21:45")
  final String? defaultTime; // Default time to show initially

  const TimestampPicker({
    super.key,
    required this.title,
    required this.selectedTime,
    required this.onTimeChanged,
    this.minTime,
    this.defaultTime,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppConstants.kRadiusS),
        side: const BorderSide(color: AppColors.lightBorder, width: 1),
      ),
      child: InkWell(
        onTap: () => _showTimePicker(context),
        borderRadius: BorderRadius.circular(AppConstants.kRadiusS),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.primaryOrange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(AppConstants.kRadiusS),
                ),
                child: const Icon(Icons.access_time, color: AppColors.primaryOrange, size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  title.isEmpty ? 'Time' : title,
                  style: TextStyle(
                    fontSize: title.isEmpty ? 12 : 16,
                    fontWeight: FontWeight.w600,
                    color: title.isEmpty ? Colors.grey[600] : null,
                  ),
                ),
              ),
              Obx(() => Text(
                selectedTime.value.isEmpty ? 'Set Time' : _format12Hour(selectedTime.value),
                style: TextStyle(
                  fontSize: 16,
                  color: selectedTime.value.isEmpty 
                      ? Colors.grey 
                      : AppColors.primaryOrange,
                  fontWeight: FontWeight.w600,
                ),
              )),
              const SizedBox(width: 8),
              const Icon(Icons.chevron_right, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }

  String _format12Hour(String time24) {
    if (time24.isEmpty) return '';
    try {
      final parts = time24.split(':');
      int hour = int.parse(parts[0]);
      int minute = int.parse(parts[1]);
      
      String period = hour >= 12 ? 'PM' : 'AM';
      int hour12 = hour == 0 ? 12 : (hour > 12 ? hour - 12 : hour);
      
      return '${hour12.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')} $period';
    } catch (e) {
      return time24;
    }
  }

  void _showTimePicker(BuildContext context) {
    // Parse current or default time
    int initialHour = 10;
    int initialMinute = 0;
    int initialPeriod = 0; // 0 = AM, 1 = PM
    
    if (selectedTime.value.isNotEmpty) {
      final parts = selectedTime.value.split(':');
      int hour24 = int.parse(parts[0]);
      initialMinute = int.parse(parts[1]);
      initialPeriod = hour24 >= 12 ? 1 : 0;
      initialHour = hour24 == 0 ? 12 : (hour24 > 12 ? hour24 - 12 : hour24);
    } else if (defaultTime != null && defaultTime!.isNotEmpty) {
      final parts = defaultTime!.split(':');
      int hour24 = int.parse(parts[0]);
      initialMinute = int.parse(parts[1]);
      initialPeriod = hour24 >= 12 ? 1 : 0;
      initialHour = hour24 == 0 ? 12 : (hour24 > 12 ? hour24 - 12 : hour24);
    }

    int selectedHour = initialHour;
    int selectedMinute = initialMinute;
    int selectedPeriod = initialPeriod;

    showDialog(
      context: context,
      builder: (BuildContext builder) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: Container(
            height: 380,
            decoration: BoxDecoration(
              color: Theme.of(context).scaffoldBackgroundColor,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.primaryOrange,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(20),
                      topRight: Radius.circular(20),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Cancel', style: TextStyle(color: Colors.white)),
                      ),
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          // Convert to 24-hour format
                          int hour24 = selectedHour == 12 
                              ? (selectedPeriod == 0 ? 0 : 12)
                              : (selectedPeriod == 0 ? selectedHour : selectedHour + 12);
                          
                          final timeString = '${hour24.toString().padLeft(2, '0')}:${selectedMinute.toString().padLeft(2, '0')}';
                          
                          // Check minimum time constraint
                          if (minTime != null && _isBeforeMinTime(hour24, selectedMinute, minTime!)) {
                            Get.snackbar(
                              'Invalid Time',
                              'Time cannot be before ${_format12Hour(minTime!)}',
                              snackPosition: SnackPosition.BOTTOM,
                              backgroundColor: Colors.red,
                              colorText: Colors.white,
                            );
                            return;
                          }
                          
                          // Only call callback - the parent will update the value
                          onTimeChanged(timeString);
                          Navigator.pop(context);
                        },
                        child: const Text('Done', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                ),
                if (minTime != null)
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      'Minimum: ${_format12Hour(minTime!)}',
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                  ),
                Expanded(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Hour picker (1-12)
                      Expanded(
                        child: CupertinoPicker(
                          scrollController: FixedExtentScrollController(
                            initialItem: selectedHour - 1,
                          ),
                          itemExtent: 40,
                          onSelectedItemChanged: (int index) {
                            selectedHour = index + 1;
                          },
                          children: List<Widget>.generate(12, (int index) {
                            return Center(
                              child: Text(
                                (index + 1).toString().padLeft(2, '0'),
                                style: const TextStyle(fontSize: 28),
                              ),
                            );
                          }),
                        ),
                      ),
                      const Text(':', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
                      // Minute picker (0-59)
                      Expanded(
                        child: CupertinoPicker(
                          scrollController: FixedExtentScrollController(
                            initialItem: selectedMinute,
                          ),
                          itemExtent: 40,
                          onSelectedItemChanged: (int index) {
                            selectedMinute = index;
                          },
                          children: List<Widget>.generate(60, (int index) {
                            return Center(
                              child: Text(
                                index.toString().padLeft(2, '0'),
                                style: const TextStyle(fontSize: 28),
                              ),
                            );
                          }),
                        ),
                      ),
                      const SizedBox(width: 10),
                      // AM/PM picker
                      Expanded(
                        child: CupertinoPicker(
                          scrollController: FixedExtentScrollController(
                            initialItem: selectedPeriod,
                          ),
                          itemExtent: 40,
                          onSelectedItemChanged: (int index) {
                            selectedPeriod = index;
                          },
                          children: const [
                            Center(child: Text('AM', style: TextStyle(fontSize: 28))),
                            Center(child: Text('PM', style: TextStyle(fontSize: 28))),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  bool _isBeforeMinTime(int hour, int minute, String minTime) {
    final parts = minTime.split(':');
    int minHour = int.parse(parts[0]);
    int minMinute = int.parse(parts[1]);
    
    int currentMinutes = hour * 60 + minute;
    int minimumMinutes = minHour * 60 + minMinute;
    
    return currentMinutes < minimumMinutes;
  }
}

/// Duration Picker with Hours and Minutes (no AM/PM) for duration activities
class DurationPicker extends StatelessWidget {
  final String title;
  final String subtitle;
  final RxInt value; // Total minutes
  final Function(int) onChanged;
  final int maxHours;

  const DurationPicker({
    super.key,
    required this.title,
    this.subtitle = '',
    required this.value,
    required this.onChanged,
    this.maxHours = 12,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppConstants.kRadiusS),
        side: const BorderSide(color: AppColors.lightBorder, width: 1),
      ),
      child: InkWell(
        onTap: () => _showDurationPicker(context),
        borderRadius: BorderRadius.circular(AppConstants.kRadiusS),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.primaryOrange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(AppConstants.kRadiusS),
                ),
                child: const Icon(Icons.timer, color: AppColors.primaryOrange, size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title.isEmpty ? 'Duration' : title,
                      style: TextStyle(
                        fontSize: title.isEmpty ? 12 : 16,
                        fontWeight: FontWeight.w600,
                        color: title.isEmpty ? Colors.grey[600] : null,
                      ),
                    ),
                    if (subtitle.isNotEmpty)
                      Text(
                        subtitle,
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                  ],
                ),
              ),
              Obx(() {
                int hours = value.value ~/ 60;
                int minutes = value.value % 60;
                return Text(
                  hours > 0 
                      ? '${hours}h ${minutes}m'
                      : '${minutes}m',
                  style: const TextStyle(
                    fontSize: 16,
                    color: AppColors.primaryOrange,
                    fontWeight: FontWeight.bold,
                  ),
                );
              }),
              const SizedBox(width: 8),
              const Icon(Icons.chevron_right, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }

  void _showDurationPicker(BuildContext context) {
    int selectedHours = value.value ~/ 60;
    int selectedMinutes = value.value % 60;

    showDialog(
      context: context,
      builder: (BuildContext builder) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: Container(
            height: 340,
            decoration: BoxDecoration(
              color: Theme.of(context).scaffoldBackgroundColor,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.primaryOrange,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(20),
                      topRight: Radius.circular(20),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Cancel', style: TextStyle(color: Colors.white)),
                      ),
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          int totalMinutes = (selectedHours * 60) + selectedMinutes;
                          onChanged(totalMinutes);
                          Navigator.pop(context);
                        },
                        child: const Text('Done', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Hours picker
                      Expanded(
                        child: CupertinoPicker(
                          scrollController: FixedExtentScrollController(
                            initialItem: selectedHours,
                          ),
                          itemExtent: 40,
                          onSelectedItemChanged: (int index) {
                            selectedHours = index;
                          },
                          children: List<Widget>.generate(maxHours + 1, (int index) {
                            return Center(
                              child: Text(
                                index.toString().padLeft(2, '0'),
                                style: const TextStyle(fontSize: 28),
                              ),
                            );
                          }),
                        ),
                      ),
                      const Text('h', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500)),
                      const SizedBox(width: 20),
                      // Minutes picker
                      Expanded(
                        child: CupertinoPicker(
                          scrollController: FixedExtentScrollController(
                            initialItem: selectedMinutes,
                          ),
                          itemExtent: 40,
                          onSelectedItemChanged: (int index) {
                            selectedMinutes = index;
                          },
                          children: List<Widget>.generate(60, (int index) {
                            return Center(
                              child: Text(
                                index.toString().padLeft(2, '0'),
                                style: const TextStyle(fontSize: 28),
                              ),
                            );
                          }),
                        ),
                      ),
                      const Padding(
                        padding: EdgeInsets.only(right: 20),
                        child: Text('m', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500)),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

/// Rounds Picker for Japa rounds (extra info, not used in scoring)
class RoundsPicker extends StatelessWidget {
  final String title;
  final RxInt value;
  final Function(int) onChanged;

  const RoundsPicker({
    super.key,
    required this.title,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppConstants.kRadiusS),
        side: const BorderSide(color: AppColors.lightBorder, width: 1),
      ),
      child: InkWell(
        onTap: () => _showRoundsPicker(context),
        borderRadius: BorderRadius.circular(AppConstants.kRadiusS),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.primaryOrange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(AppConstants.kRadiusS),
                ),
                child: const Icon(Icons.repeat, color: AppColors.primaryOrange, size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  title.isEmpty ? 'Rounds' : title,
                  style: TextStyle(
                    fontSize: title.isEmpty ? 12 : 16,
                    fontWeight: FontWeight.w600,
                    color: title.isEmpty ? Colors.grey[600] : null,
                  ),
                ),
              ),
              Obx(() => Text(
                '${value.value} rounds',
                style: const TextStyle(
                  fontSize: 16,
                  color: AppColors.primaryOrange,
                  fontWeight: FontWeight.bold,
                ),
              )),
              const SizedBox(width: 8),
              const Icon(Icons.chevron_right, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }

  void _showRoundsPicker(BuildContext context) {
    int selectedRounds = value.value;

    showDialog(
      context: context,
      builder: (BuildContext builder) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: Container(
            height: 340,
            decoration: BoxDecoration(
              color: Theme.of(context).scaffoldBackgroundColor,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.primaryOrange,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(20),
                      topRight: Radius.circular(20),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Cancel', style: TextStyle(color: Colors.white)),
                      ),
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          onChanged(selectedRounds);
                          Navigator.pop(context);
                        },
                        child: const Text('Done', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Expanded(
                        child: CupertinoPicker(
                          scrollController: FixedExtentScrollController(
                            initialItem: selectedRounds,
                          ),
                          itemExtent: 40,
                          onSelectedItemChanged: (int index) {
                            selectedRounds = index;
                          },
                          children: List<Widget>.generate(33, (int index) {
                            return Center(
                              child: Text(
                                index.toString(),
                                style: const TextStyle(fontSize: 28),
                              ),
                            );
                          }),
                        ),
                      ),
                      const Padding(
                        padding: EdgeInsets.only(right: 30),
                        child: Text(
                          'rounds',
                          style: TextStyle(fontSize: 22, fontWeight: FontWeight.w500),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
