import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'parameter_tracking_controller.dart';
import '../../core/theme/app_colors.dart';
import '../../core/constants/app_constants.dart';

class ParameterTrackingPage extends StatelessWidget {
  const ParameterTrackingPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(ParameterTrackingController());

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        title: const Text('Activity Tracking Config'),
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        return Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(AppConstants.kDefaultPadding),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildInfoCard(),
                    const SizedBox(height: AppConstants.kSpacingL),
                    _buildParameterToggles(controller),
                  ],
                ),
              ),
            ),
            _buildSaveButton(controller),
          ],
        );
      }),
    );
  }

  Widget _buildInfoCard() {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppConstants.kRadiusL),
        side: const BorderSide(color: AppColors.sageLight, width: 1),
      ),
      color: AppColors.sageLight,
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.kSpacingL),
        child: Row(
          children: [
            const Icon(
              Icons.info_outline,
              color: AppColors.deepTeal,
              size: 28,
            ),
            const SizedBox(width: AppConstants.kSpacingM),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Configure Your Activities',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.deepTeal,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Enable or disable activities you want to track. Changes will apply to all future entries.',
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey[700],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildParameterToggles(ParameterTrackingController controller) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppConstants.kRadiusL),
        side: const BorderSide(color: AppColors.lightBorder, width: 1),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.kSpacingM),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Activity Parameters',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 4),
            Text(
              'Toggle activities you want to track',
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
            const SizedBox(height: AppConstants.kSpacingL),
            _buildParameterToggle(
              controller,
              '🌙 Nindra (To Bed)',
              'nindra',
              'Track your night sleep time',
            ),
            const Divider(),
            _buildParameterToggle(
              controller,
              '🌅 Wake Up Time',
              'wake_up',
              'Track your morning wake up time',
            ),
            const Divider(),
            _buildParameterToggle(
              controller,
              '😴 Day Sleep',
              'day_sleep',
              'Track daytime sleep duration',
            ),
            const Divider(),
            _buildParameterToggle(
              controller,
              '📿 Japa (Chanting)',
              'japa',
              'Track japa rounds and completion time',
            ),
            const Divider(),
            _buildParameterToggle(
              controller,
              '📖 Pathan (Reading)',
              'pathan',
              'Track spiritual reading duration',
            ),
            const Divider(),
            _buildParameterToggle(
              controller,
              '👂 Sravan (Listening)',
              'sravan',
              'Track spiritual listening duration',
            ),
            const Divider(),
            _buildParameterToggle(
              controller,
              '🙏 Seva (Service)',
              'seva',
              'Track service/volunteer time',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildParameterToggle(
    ParameterTrackingController controller,
    String label,
    String parameterKey,
    String description,
  ) {
    return Obx(() {
      final isEnabled = controller.trackedParameters[parameterKey] ?? true;

      return InkWell(
        onTap: () => controller.toggleParameter(parameterKey),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12.0),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              Switch(
                value: isEnabled,
                onChanged: (_) => controller.toggleParameter(parameterKey),
                activeColor: AppColors.primaryOrange,
              ),
            ],
          ),
        ),
      );
    });
  }

  Widget _buildSaveButton(ParameterTrackingController controller) {
    return Container(
      padding: const EdgeInsets.all(AppConstants.kDefaultPadding),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Obx(() => SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: controller.isSaving.value
                ? null
                : () => controller.saveConfiguration(),
            icon: controller.isSaving.value
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Icon(Icons.save),
            label: Text(
              controller.isSaving.value ? 'Saving...' : 'Save Configuration',
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryOrange,
              padding: const EdgeInsets.symmetric(vertical: 16),
              textStyle: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        )),
      ),
    );
  }
}
