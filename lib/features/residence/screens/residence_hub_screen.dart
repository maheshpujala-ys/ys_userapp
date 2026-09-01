import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yellowspotuser/core/theme/app_colors.dart';
import 'package:yellowspotuser/core/theme/app_text_styles.dart';
import 'package:yellowspotuser/core/widgets/app_card.dart';
import 'package:yellowspotuser/core/widgets/app_status_pill.dart';
import 'package:yellowspotuser/core/widgets/section_header.dart';
import 'package:yellowspotuser/features/residence/access_pass/screens/digital_access_pass_screen.dart';
import 'package:yellowspotuser/features/residence/amenities/screens/amenities_booking_screen.dart';
import 'package:yellowspotuser/features/residence/community/screens/community_feed_screen.dart';
import 'package:yellowspotuser/features/residence/deliveries/screens/delivery_management_screen.dart';
import 'package:yellowspotuser/features/residence/maintenance/screens/maintenance_requests_screen.dart';
import 'package:yellowspotuser/features/residence/staff/screens/domestic_staff_screen.dart';
import 'package:yellowspotuser/features/residence/visitors/screens/visitor_management_screen.dart';
import 'package:yellowspotuser/features/residential/application/residential_controller.dart';

class ResidenceHubScreen extends ConsumerWidget {
  const ResidenceHubScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final residentialState = ref.watch(ResidentialController.provider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final societyName = residentialState.asData?.value['society'] ?? 'Palm Meadows Luxury Towers';
    final unitNumber = residentialState.asData?.value['unit'] ?? 'Tower A - Flat 1204';

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Residence'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(vertical: 12),
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 1. Residence Banner Card
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: AppCard(
                color: isDark ? AppColors.surfaceElevatedDark : AppColors.primaryContainer,
                borderColor: AppColors.primaryLight,
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: const BoxDecoration(
                                color: AppColors.primaryDark,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.home_filled, color: Colors.white, size: 20),
                            ),
                            const SizedBox(width: 10),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  societyName,
                                  style: AppTextStyles.titleMedium.copyWith(fontWeight: FontWeight.w800),
                                ),
                                Text(
                                  unitNumber,
                                  style: AppTextStyles.bodySmall.copyWith(
                                    color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const AppStatusPill(label: 'OWNER', type: StatusType.success),
                      ],
                    ),
                    const SizedBox(height: 14),
                    const Divider(),
                    const SizedBox(height: 10),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Digital Gate & RFID Pass', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                        GestureDetector(
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(builder: (_) => const DigitalAccessPassScreen()),
                            );
                          },
                          child: Text(
                            'View Smart Pass →',
                            style: AppTextStyles.labelSmall.copyWith(color: AppColors.primaryDark, fontWeight: FontWeight.w800),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // 2. Residence Core Management Grid
            const SectionHeader(title: 'Community Services'),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 1.45,
                children: [
                  _buildHubCard(
                    context,
                    title: 'Visitors & Cabs',
                    subtitle: '2 active passes',
                    icon: Icons.person_pin_circle_rounded,
                    color: AppColors.info,
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const VisitorManagementScreen()),
                    ),
                  ),
                  _buildHubCard(
                    context,
                    title: 'Gate Deliveries',
                    subtitle: '1 waiting at gate',
                    icon: Icons.inventory_2_rounded,
                    color: AppColors.purple,
                    badgeCount: 1,
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const DeliveryManagementScreen()),
                    ),
                  ),
                  _buildHubCard(
                    context,
                    title: 'Domestic Staff',
                    subtitle: 'Maids, drivers & cooks',
                    icon: Icons.badge_outlined,
                    color: AppColors.teal,
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const DomesticStaffScreen()),
                    ),
                  ),
                  _buildHubCard(
                    context,
                    title: 'Book Amenities',
                    subtitle: 'Pool, Gym & Courts',
                    icon: Icons.pool_rounded,
                    color: AppColors.primaryDark,
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const AmenitiesBookingScreen()),
                    ),
                  ),
                  _buildHubCard(
                    context,
                    title: 'Maintenance Help',
                    subtitle: '1 ticket assigned',
                    icon: Icons.build_circle_outlined,
                    color: Colors.deepOrange,
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const MaintenanceRequestsScreen()),
                    ),
                  ),
                  _buildHubCard(
                    context,
                    title: 'Society Notices',
                    subtitle: 'News, events & polls',
                    icon: Icons.campaign_rounded,
                    color: AppColors.warningDark,
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const CommunityFeedScreen()),
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

  Widget _buildHubCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
    int? badgeCount,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AppCard(
      onTap: onTap,
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: color, size: 22),
              ),
              if (badgeCount != null && badgeCount > 0)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.error,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    '$badgeCount',
                    style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                  ),
                ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: AppTextStyles.titleSmall.copyWith(fontWeight: FontWeight.w800, fontSize: 13),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: AppTextStyles.bodySmall.copyWith(
                  color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                  fontSize: 11,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
