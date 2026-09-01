import 'package:flutter/material.dart';
import 'package:yellowspotuser/core/theme/app_colors.dart';
import 'package:yellowspotuser/core/theme/app_text_styles.dart';
import 'package:yellowspotuser/core/widgets/app_card.dart';
import 'package:yellowspotuser/core/widgets/app_status_pill.dart';

class ServiceStep {
  final String title;
  final String description;
  final String time;
  final bool isCompleted;
  final bool isCurrent;

  const ServiceStep({
    required this.title,
    required this.description,
    required this.time,
    this.isCompleted = false,
    this.isCurrent = false,
  });
}

class ServiceTrackingScreen extends StatelessWidget {
  final String serviceName;
  final String vehicleName;

  const ServiceTrackingScreen({
    super.key,
    this.serviceName = 'Eco Foam Wash & Interior Detailing',
    this.vehicleName = 'Hyundai Creta (TS 09 EQ 4821)',
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final List<ServiceStep> steps = [
      const ServiceStep(
        title: 'Booking Confirmed',
        description: 'Order #YS-SRV-8829 received and slot reserved.',
        time: '10:00 AM',
        isCompleted: true,
      ),
      const ServiceStep(
        title: 'Technician Assigned',
        description: 'Assigned to Master Detailer Imran Khan (+91 98888 11223).',
        time: '10:15 AM',
        isCompleted: true,
      ),
      const ServiceStep(
        title: 'Vehicle Picked Up from Basement',
        description: 'Inspected and moved to YellowSpot On-Premise Service Bay.',
        time: '11:00 AM',
        isCompleted: true,
      ),
      const ServiceStep(
        title: 'Service in Progress',
        description: 'Foam wash, deep vacuuming & dashboard polishing ongoing.',
        time: '11:30 AM',
        isCurrent: true,
      ),
      const ServiceStep(
        title: 'Quality Check & Sanitization',
        description: 'Final inspection before handover.',
        time: 'Estimated 12:15 PM',
      ),
      const ServiceStep(
        title: 'Vehicle Parked & Ready',
        description: 'Returned to Basement 1 - Slot 42.',
        time: 'Estimated 12:30 PM',
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Live Service Tracker'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header summary card
            AppCard(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      AppStatusPill(label: 'IN PROGRESS', type: StatusType.warning),
                      Text('ETA: ~45 mins', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.primaryDark)),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    serviceName,
                    style: AppTextStyles.titleMedium.copyWith(fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    vehicleName,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            Text(
              'Service Lifecycle Timeline',
              style: AppTextStyles.titleSmall.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 12),

            // Stepper timeline
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: steps.length,
              itemBuilder: (context, index) {
                final step = steps[index];
                final isLast = index == steps.length - 1;

                Color circleColor = Colors.grey.shade300;
                IconData icon = Icons.circle_outlined;
                if (step.isCompleted) {
                  circleColor = AppColors.success;
                  icon = Icons.check_circle_rounded;
                } else if (step.isCurrent) {
                  circleColor = AppColors.primaryDark;
                  icon = Icons.pending_rounded;
                }

                return IntrinsicHeight(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Column(
                        children: [
                          Icon(icon, color: circleColor, size: 22),
                          if (!isLast)
                            Expanded(
                              child: Container(
                                width: 2,
                                color: step.isCompleted ? AppColors.success : Colors.grey.shade300,
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(bottom: 20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    step.title,
                                    style: AppTextStyles.titleSmall.copyWith(
                                      fontWeight: step.isCurrent ? FontWeight.w800 : FontWeight.w600,
                                      color: step.isCurrent ? AppColors.primaryDark : null,
                                    ),
                                  ),
                                  Text(
                                    step.time,
                                    style: const TextStyle(fontSize: 11, color: AppColors.textMutedLight),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(
                                step.description,
                                style: AppTextStyles.bodySmall.copyWith(
                                  color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
