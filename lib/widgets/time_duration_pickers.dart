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
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(AppConstants.kRadiusM),
      ),
      child: InkWell(
        onTap: () => _showTimePicker(context),
        borderRadius: BorderRadius.circular(AppConstants.kRadiusM),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              const Icon(Icons.access_time, color: Colors.grey, size: 22),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title.isEmpty ? 'Time' : title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: AppColors.lightTextSecondary,
                  ),
                ),
              ),
              Container(
                width: 1,
                height: 20,
                color: AppColors.lightBorder,
                margin: const EdgeInsets.symmetric(horizontal: 12),
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
              const Icon(Icons.chevron_right, color: Colors.grey, size: 20),
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
      
      return '$hour12:${minute.toString().padLeft(2, '0')} $period';
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
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  decoration: BoxDecoration(
                    color: Theme.of(context).scaffoldBackgroundColor,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(20),
                      topRight: Radius.circular(20),
                    ),
                    boxShadow: const [
                      BoxShadow(color: Colors.black12, blurRadius: 2, offset: Offset(0, 1)),
                    ],
                  ),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      const Text(
                        'Add time',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: Colors.black87,
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          TextButton(
                            style: TextButton.styleFrom(
                              foregroundColor: AppColors.primaryOrange,
                              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                              textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                            ),
                            onPressed: () => Navigator.pop(context),
                            child: const Text('Cancel'),
                          ),
                          TextButton(
                            style: TextButton.styleFrom(
                              foregroundColor: AppColors.primaryOrange,
                              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                              textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                            ),
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
                            child: const Text('Done'),
                          ),
                        ],
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
                  child: Stack(
                    children: [
                      // Full-width selection band
                      Positioned.fill(
                        child: Center(
                          child: Container(
                            height: 40,
                            margin: const EdgeInsets.symmetric(horizontal: 16),
                            decoration: BoxDecoration(
                              color: Colors.black54.withOpacity(0.03),
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Hour picker (1-12)
                          Expanded(
                            child: CupertinoPicker(
                              scrollController: FixedExtentScrollController(
                                initialItem: selectedHour - 1,
                              ),
                              itemExtent: 40,
                              looping: true,
                              useMagnifier: true,
                              magnification: 1.15,
                              squeeze: 1.2,
                              selectionOverlay: const SizedBox.shrink(),
                              onSelectedItemChanged: (int index) {
                                selectedHour = index + 1;
                              },
                              children: List<Widget>.generate(12, (int index) {
                                return Center(
                                  child: Text(
                                    (index + 1).toString(),
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
                              looping: true,
                              useMagnifier: true,
                              magnification: 1.15,
                              squeeze: 1.2,
                              selectionOverlay: const SizedBox.shrink(),
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
                              looping: false,
                              useMagnifier: true,
                              magnification: 1.15,
                              squeeze: 1.2,
                              selectionOverlay: const SizedBox.shrink(),
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
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(AppConstants.kRadiusM),
      ),
      child: InkWell(
        onTap: () => _showDurationPicker(context),
        borderRadius: BorderRadius.circular(AppConstants.kRadiusM),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              const Icon(Icons.timer, color: Colors.grey, size: 22),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      title.isEmpty ? 'Duration' : title,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: AppColors.lightTextSecondary,
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
              Container(
                width: 1,
                height: 20,
                color: AppColors.lightBorder,
                margin: const EdgeInsets.symmetric(horizontal: 12),
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
                    fontWeight: FontWeight.w600,
                  ),
                );
              }),
              const SizedBox(width: 8),
              const Icon(Icons.chevron_right, color: Colors.grey, size: 20),
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
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  decoration: BoxDecoration(
                    color: Theme.of(context).scaffoldBackgroundColor,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(20),
                      topRight: Radius.circular(20),
                    ),
                    boxShadow: const [
                      BoxShadow(color: Colors.black12, blurRadius: 2, offset: Offset(0, 1)),
                    ],
                  ),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      const Text(
                        'Add duration',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: Colors.black87,
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          TextButton(
                            style: TextButton.styleFrom(
                              foregroundColor: AppColors.primaryOrange,
                              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                              textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                            ),
                            onPressed: () => Navigator.pop(context),
                            child: const Text('Cancel'),
                          ),
                          TextButton(
                            style: TextButton.styleFrom(
                              foregroundColor: AppColors.primaryOrange,
                              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                              textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                            ),
                            onPressed: () {
                              final int appliedHours = selectedHours > maxHours ? maxHours : selectedHours;
                              if (appliedHours == 0 && selectedMinutes == 0) {
                                Get.snackbar(
                                  'Invalid Duration',
                                  'Duration cannot be 0 minutes',
                                  snackPosition: SnackPosition.BOTTOM,
                                  backgroundColor: Colors.red,
                                  colorText: Colors.white,
                                );
                                return;
                              }
                              final int totalMinutes = (appliedHours * 60) + selectedMinutes;
                              onChanged(totalMinutes);
                              Navigator.pop(context);
                            },
                            child: const Text('Done'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
                        child: Row(
                          children: const [
                            Expanded(
                              child: Center(
                                child: Text('Hours', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.black87)),
                              ),
                            ),
                            SizedBox(width: 20),
                            Expanded(
                              child: Center(
                                child: Text('Minutes', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.black87)),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: Stack(
                          children: [
                            // Full-width selection band
                            Positioned.fill(
                              child: Center(
                                child: Container(
                                  height: 40,
                                  margin: const EdgeInsets.symmetric(horizontal: 16),
                                  decoration: BoxDecoration(
                                    color: Colors.black54.withOpacity(0.03),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                              ),
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                // Hours picker
                                Expanded(
                                  child: CupertinoPicker(
                                    scrollController: FixedExtentScrollController(
                                      initialItem: selectedHours,
                                    ),
                                    itemExtent: 40,
                                    looping: true,
                                    useMagnifier: true,
                                    magnification: 1.15,
                                    squeeze: 1.2,
                                    selectionOverlay: const SizedBox.shrink(),
                                    onSelectedItemChanged: (int index) {
                                      selectedHours = index;
                                    },
                                    children: List<Widget>.generate(13, (int index) {
                                      return Center(
                                        child: Text(
                                          index.toString(),
                                          style: const TextStyle(fontSize: 28),
                                        ),
                                      );
                                    }),
                                  ),
                                ),
                                const SizedBox(width: 20),
                                // Minutes picker
                                Expanded(
                                  child: CupertinoPicker(
                                    scrollController: FixedExtentScrollController(
                                      initialItem: selectedMinutes,
                                    ),
                                    itemExtent: 40,
                                    looping: true,
                                    useMagnifier: true,
                                    magnification: 1.15,
                                    squeeze: 1.2,
                                    selectionOverlay: const SizedBox.shrink(),
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
                              ],
                            ),
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
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(AppConstants.kRadiusM),
      ),
      child: InkWell(
        onTap: () => _showRoundsPicker(context),
        borderRadius: BorderRadius.circular(AppConstants.kRadiusM),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              const Icon(Icons.repeat, color: Colors.grey, size: 22),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title.isEmpty ? 'Rounds' : title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: AppColors.lightTextSecondary,
                  ),
                ),
              ),
              Container(
                width: 1,
                height: 20,
                color: AppColors.lightBorder,
                margin: const EdgeInsets.symmetric(horizontal: 12),
              ),
              Obx(() => Text(
                '${value.value} rounds',
                style: const TextStyle(
                  fontSize: 16,
                  color: AppColors.primaryOrange,
                  fontWeight: FontWeight.w600,
                ),
              )),
              const SizedBox(width: 8),
              const Icon(Icons.chevron_right, color: Colors.grey, size: 20),
            ],
          ),
        ),
      ),
    );
  }

  void _showRoundsPicker(BuildContext context) {
    int selectedRounds = value.value;
    if (selectedRounds < 0) selectedRounds = 0;
    if (selectedRounds > 1000) selectedRounds = 1000;

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
                // Header
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  decoration: BoxDecoration(
                    color: Theme.of(context).scaffoldBackgroundColor,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(20),
                      topRight: Radius.circular(20),
                    ),
                    boxShadow: const [
                      BoxShadow(color: Colors.black12, blurRadius: 2, offset: Offset(0, 1)),
                    ],
                  ),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      const Text(
                        'Add rounds',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: Colors.black87,
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          TextButton(
                            style: TextButton.styleFrom(
                              foregroundColor: AppColors.primaryOrange,
                              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                              textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                            ),
                            onPressed: () => Navigator.pop(context),
                            child: const Text('Cancel'),
                          ),
                          TextButton(
                            style: TextButton.styleFrom(
                              foregroundColor: AppColors.primaryOrange,
                              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                              textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                            ),
                            onPressed: () {
                              onChanged(selectedRounds);
                              Navigator.pop(context);
                            },
                            child: const Text('Done'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                // Body
                Expanded(
                  child: Stack(
                    children: [
                      Positioned.fill(
                        child: Center(
                          child: Container(
                            height: 40,
                            margin: const EdgeInsets.symmetric(horizontal: 16),
                            decoration: BoxDecoration(
                              color: Colors.black54.withOpacity(0.03),
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Expanded(
                            child: CupertinoPicker(
                              scrollController: FixedExtentScrollController(
                                initialItem: selectedRounds,
                              ),
                              itemExtent: 40,
                              looping: true,
                              useMagnifier: true,
                              magnification: 1.15,
                              squeeze: 1.2,
                              selectionOverlay: const SizedBox.shrink(),
                              onSelectedItemChanged: (int index) {
                                selectedRounds = index;
                              },
                              children: List<Widget>.generate(1001, (int index) {
                                return Center(
                                  child: Text(
                                    index.toString(),
                                    style: const TextStyle(fontSize: 28),
                                  ),
                                );
                              }),
                            ),
                          ),
                        ],
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
