import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yellowspotuser/core/theme/app_colors.dart';
import 'package:yellowspotuser/core/theme/app_text_styles.dart';
import 'package:yellowspotuser/core/widgets/app_card.dart';
import 'package:yellowspotuser/core/widgets/app_status_pill.dart';
import 'package:yellowspotuser/core/widgets/section_header.dart';
import 'package:yellowspotuser/features/emergency/screens/emergency_sos_sheet.dart';

class CarServicesScreen extends ConsumerWidget {
  const CarServicesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Car Services'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildOngoingServiceCard(context),
            const SizedBox(height: 20),
            _buildEmergencyServices(context),
            const SizedBox(height: 20),
            _buildAllServices(context),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildOngoingServiceCard(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AppCard(
      color: isDark ? AppColors.surfaceElevatedDark : AppColors.primaryContainer,
      borderColor: AppColors.primary,
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.primaryDark : Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.settings_outlined, color: AppColors.primaryDark, size: 26),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Regular Service',
                      style: AppTextStyles.titleSmall.copyWith(fontWeight: FontWeight.w800),
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      'TS 09 AB 1234 • Tata Nexon EV',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              const AppStatusPill(label: 'In Progress', type: StatusType.success),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'AutoZone Service Center',
                style: AppTextStyles.bodySmall.copyWith(
                  color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                  fontSize: 11,
                ),
              ),
              const Text(
                'Est. 2 hours remaining',
                style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.successDark),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: const LinearProgressIndicator(
              value: 0.6,
              backgroundColor: Colors.black12,
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.success),
              minHeight: 6,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmergencyServices(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AppCard(
      color: isDark ? AppColors.surfaceElevatedDark : AppColors.errorContainer.withValues(alpha: 0.35),
      borderColor: AppColors.error.withValues(alpha: 0.3),
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '🚨 24/7 Emergency Assistance',
                style: AppTextStyles.titleSmall.copyWith(color: AppColors.errorDark, fontWeight: FontWeight.w800),
              ),
              const AppStatusPill(label: 'PRIORITY', type: StatusType.error),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            'Immediate doorstep response when you need it most',
            style: AppTextStyles.bodySmall.copyWith(
              color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildEmergencyServiceIcon(context, Icons.support_agent_outlined, 'Roadside\nAssist'),
              _buildEmergencyServiceIcon(context, Icons.car_crash_outlined, 'Towing\nService'),
              _buildEmergencyServiceIcon(context, Icons.vpn_key_outlined, 'Key\nLockout'),
              _buildEmergencyServiceIcon(context, Icons.local_gas_station_outlined, 'Fuel / EV\nBoost'),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 44,
            child: ElevatedButton.icon(
              onPressed: () => EmergencySosSheet.show(context),
              icon: const Icon(Icons.call_rounded, size: 18),
              label: const Text('Call SOS Helpline', style: TextStyle(fontWeight: FontWeight.bold)),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.error,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildEmergencyServiceIcon(BuildContext context, IconData icon, String label) {
    return Expanded(
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.errorContainer,
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.error.withValues(alpha: 0.2)),
            ),
            child: Icon(icon, color: AppColors.errorDark, size: 22),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 10, height: 1.1, fontWeight: FontWeight.w600),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildAllServices(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeader(title: 'All Available Services'),
        _buildServiceListItem(
          icon: Icons.settings_outlined,
          title: 'Regular Service & Inspection',
          subtitle: 'Oil change, filter replacement, 40-point safety checkup',
          price: '₹2,000 - ₹5,000',
        ),
        const SizedBox(height: 8),
        _buildServiceListItem(
          icon: Icons.wash_outlined,
          title: 'Eco Car Foam Wash',
          subtitle: 'Society bay pressure wash & interior vacuuming',
          price: '₹500 - ₹1,200',
        ),
        const SizedBox(height: 8),
        _buildServiceListItem(
          icon: Icons.tire_repair_outlined,
          title: 'Tyre & Wheel Alignment',
          subtitle: 'Laser balancing, nitrogen inflation & puncture patch',
          price: '₹350 - ₹1,800',
        ),
        const SizedBox(height: 8),
        _buildServiceListItem(
          icon: Icons.ac_unit_outlined,
          title: 'AC Disinfection & Gas Top-up',
          subtitle: 'Antibacterial duct cleaning & cooling test',
          price: '₹1,500 - ₹3,500',
        ),
        const SizedBox(height: 8),
        _buildServiceListItem(
          icon: Icons.battery_charging_full_outlined,
          title: 'Battery Health & Jumpstart',
          subtitle: 'Diagnostic test, terminal cleaning & doorstep replacement',
          price: '₹400 - ₹8,000',
        ),
      ],
    );
  }

  Widget _buildServiceListItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required String price,
  }) {
    return AppCard(
      padding: const EdgeInsets.all(14),
      onTap: () {},
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.primaryContainer,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: AppColors.primaryDark, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTextStyles.titleSmall.copyWith(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: const TextStyle(fontSize: 11, color: AppColors.textSecondaryLight),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  price,
                  style: const TextStyle(color: AppColors.successDark, fontWeight: FontWeight.bold, fontSize: 12),
                ),
              ],
            ),
          ),
          const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: AppColors.textMutedLight),
        ],
      ),
    );
  }
}
