import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yellowspotuser/core/theme/app_colors.dart';
import 'package:yellowspotuser/core/theme/app_text_styles.dart';
import 'package:yellowspotuser/core/widgets/app_card.dart';
import 'package:yellowspotuser/core/widgets/app_status_pill.dart';
import 'package:yellowspotuser/features/auth/application/auth_controller.dart';

class DigitalAccessPassScreen extends ConsumerWidget {
  const DigitalAccessPassScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(AuthController.provider);
    final user = authState.asData?.value;
    final userName = user?.name.isNotEmpty == true ? user!.name : 'Alex Morgan';
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Digital Resident ID'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Smart Access Card Card Container
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                gradient: LinearGradient(
                  colors: isDark
                      ? [const Color(0xFF1E293B), const Color(0xFF0F172A)]
                      : [const Color(0xFFFFFBEB), const Color(0xFFFEF3C7)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                border: Border.all(
                  color: isDark ? AppColors.primary.withValues(alpha: 0.4) : AppColors.primary,
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: isDark ? Colors.black.withValues(alpha: 0.3) : AppColors.primary.withValues(alpha: 0.15),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: AppColors.primary,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(Icons.flash_on_rounded, color: Colors.black87, size: 20),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'YELLOWSPOT PASS',
                            style: TextStyle(
                              color: isDark ? Colors.white : AppColors.textPrimaryLight,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 1.5,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                      const AppStatusPill(label: 'ACTIVE', type: StatusType.success),
                    ],
                  ),
                  const SizedBox(height: 24),

                  Text(
                    userName,
                    style: TextStyle(
                      color: isDark ? Colors.white : AppColors.textPrimaryLight,
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.2,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Unit A-1204 • Palm Meadows Luxury Society',
                    style: TextStyle(
                      color: isDark ? Colors.white70 : AppColors.textSecondaryLight,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // QR Code box
                  Center(
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Icon(Icons.qr_code_2_rounded, size: 160, color: Colors.black),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Center(
                    child: Text(
                      'CARD ID: YS-RES-2026-99218',
                      style: TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.2,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Authorized Access Zones
            AppCard(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Authorized Access Points',
                    style: AppTextStyles.titleSmall.copyWith(fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 12),
                  _buildZoneItem(Icons.security, 'Main Gate 1 & 2 (Boom Barrier)', 'RFID & QR Enabled'),
                  _buildZoneItem(Icons.local_parking_rounded, 'Basement 1 & 2 Parking Gates', 'Automated Plate / QR'),
                  _buildZoneItem(Icons.pool_rounded, 'Clubhouse & Swimming Pool', 'Access 06:00 AM - 10:00 PM'),
                  _buildZoneItem(Icons.fitness_center_rounded, 'Gymnasium & Squash Courts', 'Access 05:30 AM - 11:00 PM'),
                  _buildZoneItem(Icons.ev_station_rounded, 'EV Charging Hub B2', 'Smart Payment Verified'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildZoneItem(IconData icon, String title, String subtitle) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, size: 20, color: AppColors.primaryDark),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                Text(subtitle, style: const TextStyle(fontSize: 11, color: AppColors.textMutedLight)),
              ],
            ),
          ),
          const Icon(Icons.check_circle_rounded, size: 18, color: AppColors.success),
        ],
      ),
    );
  }
}
