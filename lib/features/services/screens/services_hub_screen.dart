import 'package:flutter/material.dart';
import 'package:yellowspotuser/core/theme/app_colors.dart';
import 'package:yellowspotuser/core/theme/app_text_styles.dart';
import 'package:yellowspotuser/core/widgets/app_card.dart';
import 'package:yellowspotuser/core/widgets/app_status_pill.dart';
import 'package:yellowspotuser/core/widgets/section_header.dart';
import 'package:yellowspotuser/features/services/screens/book_a_car_screen.dart';
import 'package:yellowspotuser/features/services/screens/car_services_screen.dart';
import 'package:yellowspotuser/features/services/screens/quick_services_screen.dart';
import 'package:yellowspotuser/features/services/screens/service_tracking_screen.dart';

class ServicesHubScreen extends StatelessWidget {
  const ServicesHubScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Vehicle Services Marketplace'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(vertical: 12),
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 1. Ongoing Service Tracker Card (if active)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: AppCard(
                color: isDark ? AppColors.surfaceElevatedDark : const Color(0xFFF0FDF4),
                borderColor: AppColors.success,
                padding: const EdgeInsets.all(16),
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const ServiceTrackingScreen()),
                  );
                },
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: const BoxDecoration(
                        color: AppColors.successContainer,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.car_repair_rounded, color: AppColors.successDark, size: 24),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Row(
                            children: [
                              Text(
                                'Service In Progress',
                                style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13),
                              ),
                              SizedBox(width: 8),
                              AppStatusPill(label: 'ACTIVE', type: StatusType.success),
                            ],
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Eco Wash & Interior Detailing • Hyundai Creta',
                            style: AppTextStyles.bodySmall.copyWith(
                              color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    const Icon(Icons.chevron_right, color: AppColors.textMutedLight),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // 2. Service Categories Grid
            const SectionHeader(title: 'Service Marketplace'),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [
                  // A. Quick Assistance / Emergency Roadside
                  _buildServiceCategoryCard(
                    context,
                    title: '⚡ Quick Roadside Assistance',
                    subtitle: 'Flat Tyre, Jumpstart, Battery Boost & Towing with 15-min doorstep response.',
                    icon: Icons.flash_on_rounded,
                    color: Colors.deepOrange,
                    tag: '15-min ETA',
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const QuickServicesScreen()),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // B. Scheduled Car Care & Maintenance
                  _buildServiceCategoryCard(
                    context,
                    title: '🚿 Scheduled Car Care & Wash',
                    subtitle: 'Eco Foam Wash, Interior Detailing, Periodic Oil Service & AC check in society bay.',
                    icon: Icons.cleaning_services_rounded,
                    color: AppColors.primaryDark,
                    tag: 'YellowSpot Certified',
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const CarServicesScreen()),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // C. On-Demand Car Rental
                  _buildServiceCategoryCard(
                    context,
                    title: '🚗 On-Demand Car Rental',
                    subtitle: 'Self-drive Sedans, SUVs, and Electric Cars stationed right inside society parking.',
                    icon: Icons.car_rental_rounded,
                    color: AppColors.info,
                    tag: 'Zero Deposit',
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const BookACarScreen()),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildServiceCategoryCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required String tag,
    required VoidCallback onTap,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AppCard(
      padding: const EdgeInsets.all(16),
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: AppTextStyles.titleMedium.copyWith(fontWeight: FontWeight.w800),
              ),
              AppStatusPill(label: tag, type: StatusType.primary),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: AppTextStyles.bodySmall.copyWith(
              color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Explore options & book →',
                style: AppTextStyles.labelSmall.copyWith(
                  color: AppColors.primaryDark,
                  fontWeight: FontWeight.w800,
                ),
              ),
              Icon(Icons.arrow_forward_rounded, size: 16, color: color),
            ],
          ),
        ],
      ),
    );
  }
}
