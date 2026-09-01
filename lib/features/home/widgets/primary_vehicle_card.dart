import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yellowspotuser/core/theme/app_colors.dart';
import 'package:yellowspotuser/core/theme/app_text_styles.dart';
import 'package:yellowspotuser/core/widgets/app_card.dart';
import 'package:yellowspotuser/core/widgets/app_status_pill.dart';
import 'package:yellowspotuser/core/widgets/section_header.dart';
import 'package:yellowspotuser/features/home/application/home_controller.dart';

class PrimaryVehicleCard extends ConsumerWidget {
  final VoidCallback? onManageGarage;
  final VoidCallback? onBookService;
  final VoidCallback? onParkingSlot;

  const PrimaryVehicleCard({
    super.key,
    this.onManageGarage,
    this.onBookService,
    this.onParkingSlot,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final vehicleAsync = ref.watch(primaryVehicleProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(
          title: 'My Primary Vehicle',
          actionLabel: 'Garage (3)',
          onAction: onManageGarage,
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: vehicleAsync.when(
            data: (vehicle) {
              if (vehicle == null) {
                return AppCard(
                  onTap: onManageGarage,
                  child: Center(
                    child: Text(
                      '+ Add Vehicle to My Garage',
                      style: AppTextStyles.labelMedium.copyWith(color: AppColors.primaryDark),
                    ),
                  ),
                );
              }

              return AppCard(
                padding: const EdgeInsets.all(16),
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
                              decoration: BoxDecoration(
                                color: AppColors.primaryContainer,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Icon(
                                Icons.directions_car_filled_rounded,
                                color: AppColors.primaryDark,
                                size: 22,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '${vehicle.make} ${vehicle.model}',
                                  style: AppTextStyles.titleSmall.copyWith(
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                                Text(
                                  vehicle.registrationNumber,
                                  style: AppTextStyles.bodySmall.copyWith(
                                    color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                                    fontWeight: FontWeight.w600,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const AppStatusPill(
                          label: 'Primary',
                          type: StatusType.primary,
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    const Divider(),
                    const SizedBox(height: 12),

                    // Quick Specs & Status Indicators
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildStatusItem(
                          context,
                          icon: Icons.local_parking_rounded,
                          label: 'Slot',
                          value: 'Basement 1 • #42',
                          color: AppColors.info,
                        ),
                        _buildStatusItem(
                          context,
                          icon: Icons.car_repair_rounded,
                          label: 'Service',
                          value: 'Due Soon',
                          color: AppColors.warningDark,
                        ),
                        _buildStatusItem(
                          context,
                          icon: Icons.verified_user_outlined,
                          label: 'Insurance',
                          value: 'Valid (2027)',
                          color: AppColors.success,
                        ),
                      ],
                    ),

                    const SizedBox(height: 14),
                    // Action Buttons Row
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: onBookService,
                            icon: const Icon(Icons.cleaning_services_rounded, size: 16),
                            label: const Text('Book Care', style: TextStyle(fontSize: 12)),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              minimumSize: const Size(0, 36),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: onParkingSlot,
                            icon: const Icon(Icons.qr_code_2_rounded, size: 16),
                            label: const Text('Slot Pass', style: TextStyle(fontSize: 12)),
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              minimumSize: const Size(0, 36),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
            loading: () => const Center(child: CircularProgressIndicator(strokeWidth: 2)),
            error: (_, __) => const SizedBox.shrink(),
          ),
        ),
      ],
    );
  }

  Widget _buildStatusItem(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Row(
      children: [
        Icon(icon, size: 16, color: color),
        const SizedBox(width: 4),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: const TextStyle(fontSize: 10, color: AppColors.textMutedLight)),
            Text(value, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700)),
          ],
        ),
      ],
    );
  }
}
