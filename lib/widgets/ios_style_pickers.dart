import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../core/theme/app_colors.dart';
import '../core/constants/app_constants.dart';

class IOSTimePicker extends StatelessWidget {
  final String title;
  final RxString selectedTime;
  final Function(String) onTimeChanged;

  const IOSTimePicker({
    super.key,
    required this.title,
    required this.selectedTime,
    required this.onTimeChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: () => _showTimePicker(context),
        child: Padding(
          padding: const EdgeInsets.all(AppConstants.kSpacingM),
          child: Row(
            children: [
              Text(
                title,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              const Spacer(),
              Obx(() => Text(
                selectedTime.value.isEmpty ? 'Set Time' : selectedTime.value,
                style: TextStyle(
                  fontSize: 16,
                  color: selectedTime.value.isEmpty 
                      ? Colors.grey 
                      : AppColors.primaryOrange,
                  fontWeight: FontWeight.w500,
                ),
              )),
              const SizedBox(width: 8),
              const Icon(Icons.access_time, size: 20, color: AppColors.primaryOrange),
            ],
          ),
        ),
      ),
    );
  }

  void _showTimePicker(BuildContext context) {
    DateTime initialTime = DateTime.now();
    
    // Parse existing time if available
    if (selectedTime.value.isNotEmpty) {
      try {
        final parts = selectedTime.value.split(':');
        if (parts.length == 2) {
          initialTime = DateTime(
            DateTime.now().year,
            DateTime.now().month,
            DateTime.now().day,
            int.parse(parts[0]),
            int.parse(parts[1]),
          );
        }
      } catch (e) {
        // Use current time if parsing fails
      }
    }

    showDialog(
      context: context,
      builder: (BuildContext builder) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Container(
            height: 320,
            decoration: BoxDecoration(
              color: Theme.of(context).scaffoldBackgroundColor,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: AppColors.primaryOrange.withOpacity(0.1),
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
                        child: const Text('Cancel'),
                      ),
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: const Text('Done'),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: CupertinoDatePicker(
                    mode: CupertinoDatePickerMode.time,
                    use24hFormat: true,
                    initialDateTime: initialTime,
                    onDateTimeChanged: (DateTime newTime) {
                      final timeString = 
                          '${newTime.hour.toString().padLeft(2, '0')}:${newTime.minute.toString().padLeft(2, '0')}';
                      selectedTime.value = timeString;
                      onTimeChanged(timeString);
                    },
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

class IOSDurationPicker extends StatelessWidget {
  final String title;
  final String subtitle;
  final dynamic value; // Can be RxInt or RxDouble
  final Function(int) onChanged;
  final int maxValue;
  final String unit;

  const IOSDurationPicker({
    super.key,
    required this.title,
    this.subtitle = '',
    required this.value,
    required this.onChanged,
    this.maxValue = 300,
    this.unit = 'min',
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: () => _showDurationPicker(context),
        child: Padding(
          padding: const EdgeInsets.all(AppConstants.kSpacingM),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
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
                final val = value.value;
                return Text(
                  '$val $unit',
                  style: const TextStyle(
                    fontSize: 16,
                    color: AppColors.primaryOrange,
                    fontWeight: FontWeight.w600,
                  ),
                );
              }),
              const SizedBox(width: 8),
              const Icon(Icons.tune, size: 20, color: AppColors.primaryOrange),
            ],
          ),
        ),
      ),
    );
  }

  void _showDurationPicker(BuildContext context) {
    int selectedValue = value.value is double 
        ? (value.value as double).toInt() 
        : value.value as int;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (BuildContext builder) {
        return Container(
          height: 300,
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
          ),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: AppColors.primaryOrange.withOpacity(0.1),
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
                      child: const Text('Cancel'),
                    ),
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        onChanged(selectedValue);
                        Navigator.pop(context);
                      },
                      child: const Text('Done'),
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
                          initialItem: selectedValue,
                        ),
                        itemExtent: 40,
                        onSelectedItemChanged: (int index) {
                          selectedValue = index;
                        },
                        children: List<Widget>.generate(
                          maxValue + 1,
                          (int index) {
                            return Center(
                              child: Text(
                                index.toString(),
                                style: const TextStyle(fontSize: 24),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(right: 40),
                      child: Text(
                        unit,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class IOSRoundsPicker extends StatelessWidget {
  final String title;
  final RxInt value;
  final Function(int) onChanged;

  const IOSRoundsPicker({
    super.key,
    required this.title,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: () => _showRoundsPicker(context),
        child: Padding(
          padding: const EdgeInsets.all(AppConstants.kSpacingM),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
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
              const Icon(Icons.repeat, size: 20, color: AppColors.primaryOrange),
            ],
          ),
        ),
      ),
    );
  }

  void _showRoundsPicker(BuildContext context) {
    int selectedRounds = value.value;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (BuildContext builder) {
        return Container(
          height: 300,
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
          ),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: AppColors.primaryOrange.withOpacity(0.1),
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
                      child: const Text('Cancel'),
                    ),
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        onChanged(selectedRounds);
                        Navigator.pop(context);
                      },
                      child: const Text('Done'),
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
                        children: List<Widget>.generate(
                          33, // 0-32 rounds
                          (int index) {
                            return Center(
                              child: Text(
                                index.toString(),
                                style: const TextStyle(fontSize: 24),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                    const Padding(
                      padding: EdgeInsets.only(right: 40),
                      child: Text(
                        'rounds',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class IOSHoursPicker extends StatelessWidget {
  final String title;
  final RxDouble value;
  final Function(double) onChanged;

  const IOSHoursPicker({
    super.key,
    required this.title,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: () => _showHoursPicker(context),
        child: Padding(
          padding: const EdgeInsets.all(AppConstants.kSpacingM),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ),
              Obx(() => Text(
                '${value.value.toStringAsFixed(1)} hrs',
                style: const TextStyle(
                  fontSize: 16,
                  color: AppColors.primaryOrange,
                  fontWeight: FontWeight.w600,
                ),
              )),
              const SizedBox(width: 8),
              const Icon(Icons.schedule, size: 20, color: AppColors.primaryOrange),
            ],
          ),
        ),
      ),
    );
  }

  void _showHoursPicker(BuildContext context) {
    int hours = value.value.floor();
    int minutes = ((value.value - hours) * 60).round();

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (BuildContext builder) {
        return Container(
          height: 300,
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
          ),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: AppColors.primaryOrange.withOpacity(0.1),
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
                      child: const Text('Cancel'),
                    ),
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        final totalHours = hours + (minutes / 60);
                        onChanged(totalHours);
                        Navigator.pop(context);
                      },
                      child: const Text('Done'),
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
                          initialItem: hours,
                        ),
                        itemExtent: 40,
                        onSelectedItemChanged: (int index) {
                          hours = index;
                        },
                        children: List<Widget>.generate(
                          24,
                          (int index) {
                            return Center(
                              child: Text(
                                index.toString(),
                                style: const TextStyle(fontSize: 24),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                    const Text(
                      'hrs',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(width: 20),
                    Expanded(
                      child: CupertinoPicker(
                        scrollController: FixedExtentScrollController(
                          initialItem: minutes,
                        ),
                        itemExtent: 40,
                        onSelectedItemChanged: (int index) {
                          minutes = index;
                        },
                        children: List<Widget>.generate(
                          60,
                          (int index) {
                            return Center(
                              child: Text(
                                index.toString().padLeft(2, '0'),
                                style: const TextStyle(fontSize: 24),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                    const Padding(
                      padding: EdgeInsets.only(right: 20),
                      child: Text(
                        'min',
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
