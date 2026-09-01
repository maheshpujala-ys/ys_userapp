import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yellowspotuser/core/theme/app_colors.dart';
import 'package:yellowspotuser/core/theme/app_text_styles.dart';
import 'package:yellowspotuser/core/widgets/app_card.dart';
import 'package:yellowspotuser/core/widgets/app_status_pill.dart';
import 'package:yellowspotuser/features/admin/data/admin_operations_repository.dart';
import 'package:yellowspotuser/features/admin/domain/admin_models.dart';

final adminGateDevicesProvider = FutureProvider<List<AdminGateDevice>>((ref) async {
  final repo = ref.watch(adminOperationsRepositoryProvider);
  return repo.getGateDevices();
});

final adminSosAlertsProvider = FutureProvider<List<AdminSosAlert>>((ref) async {
  final repo = ref.watch(adminOperationsRepositoryProvider);
  return repo.getSosAlerts();
});

class SecurityScreen extends ConsumerWidget {
  const SecurityScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final gateDevicesAsync = ref.watch(adminGateDevicesProvider);
    final sosAlertsAsync = ref.watch(adminSosAlertsProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. SOS Emergency Alerts
          sosAlertsAsync.when(
            data: (alerts) {
              if (alerts.isEmpty) return const SizedBox.shrink();
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: AppColors.errorContainer,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(Icons.warning_amber_rounded, color: AppColors.error, size: 18),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'SOS Command Center (${alerts.length} Active)',
                        style: AppTextStyles.titleMedium.copyWith(
                          fontWeight: FontWeight.w800,
                          color: AppColors.error,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  ...alerts.map((alert) => AppCard(
                        padding: const EdgeInsets.all(14),
                        borderColor: AppColors.error,
                        color: isDark ? AppColors.surfaceDark : const Color(0xFFFEF2F2),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  alert.type,
                                  style: AppTextStyles.titleMedium.copyWith(
                                    fontWeight: FontWeight.w800,
                                    color: AppColors.error,
                                  ),
                                ),
                                AppStatusPill(
                                  label: alert.status.name.toUpperCase(),
                                  type: StatusType.error,
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Text('Resident: ${alert.residentName} (${alert.unit})', style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                            Text('Location: ${alert.location}', style: const TextStyle(fontSize: 12, color: AppColors.textMutedLight)),
                            if (alert.responderNote != null) ...[
                              const SizedBox(height: 6),
                              Text('Note: ${alert.responderNote}', style: const TextStyle(fontSize: 11, fontStyle: FontStyle.italic)),
                            ],
                            const SizedBox(height: 10),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                ElevatedButton(
                                  onPressed: () {
                                    ref.read(adminOperationsRepositoryProvider).updateSosStatus(alert.id, SosAlertStatus.resolved);
                                    ref.invalidate(adminSosAlertsProvider);
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(content: Text('SOS Alert marked as Resolved')),
                                    );
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.success,
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                                  ),
                                  child: const Text('Mark Resolved', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                                ),
                              ],
                            ),
                          ],
                        ),
                      )),
                  const SizedBox(height: 20),
                ],
              );
            },
            loading: () => const SizedBox.shrink(),
            error: (_, __) => const SizedBox.shrink(),
          ),

          // 2. Gate Devices & Barrier Overrides
          Text(
            'Gate Device Telemetry & Barriers',
            style: AppTextStyles.titleMedium.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 12),
          gateDevicesAsync.when(
            data: (gates) {
              return Column(
                children: gates.map((gate) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12.0),
                    child: AppCard(
                      padding: const EdgeInsets.all(14),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(gate.name, style: AppTextStyles.titleSmall.copyWith(fontWeight: FontWeight.w800)),
                              AppStatusPill(
                                label: gate.barrierStatus == GateDeviceStatus.online ? 'ONLINE' : 'CHECK',
                                type: gate.barrierStatus == GateDeviceStatus.online ? StatusType.success : StatusType.warning,
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              _buildDeviceChip('ANPR Camera', gate.anprStatus, isDark),
                              _buildDeviceChip('RFID FastTag', gate.rfidReaderStatus, isDark),
                              _buildDeviceChip('Boom Barrier', gate.barrierStatus, isDark),
                            ],
                          ),
                          const SizedBox(height: 12),
                          const Divider(),
                          const SizedBox(height: 6),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('Manual Boom Barrier Override', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                              OutlinedButton.icon(
                                icon: const Icon(Icons.lock_open_rounded, size: 14),
                                label: const Text('Open Gate', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                                onPressed: () {
                                  ref.read(adminOperationsRepositoryProvider).overrideGateBarrier(gate.gateId, true);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text('Sent manual open command to ${gate.name}')),
                                  );
                                },
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (err, _) => Center(child: Text('Error loading gate devices: $err')),
          ),
          const SizedBox(height: 16),

          // 3. Security Camera Network
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Security Camera Network',
                style: AppTextStyles.titleMedium.copyWith(fontWeight: FontWeight.w800),
              ),
              const Text('18 Active Streams', style: TextStyle(fontSize: 12, color: AppColors.success, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 10),
          const CameraListItem(zone: 'Zone A - Main Entry Gate', location: 'Gate 1 (ANPR Cam 01)', isActive: true),
          const SizedBox(height: 8),
          const CameraListItem(zone: 'Zone B - Underground EV Bays', location: 'Basement 2 (Bay B2-45)', isActive: true),
          const SizedBox(height: 8),
          const CameraListItem(zone: 'Zone C - Perimeter West', location: 'Tower A North Gate', isActive: true),
        ],
      ),
    );
  }

  Widget _buildDeviceChip(String name, GateDeviceStatus status, bool isDark) {
    final isOnline = status == GateDeviceStatus.online;
    return Column(
      children: [
        Icon(
          isOnline ? Icons.check_circle_rounded : Icons.warning_rounded,
          size: 16,
          color: isOnline ? AppColors.success : AppColors.warning,
        ),
        const SizedBox(height: 4),
        Text(name, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600)),
      ],
    );
  }
}

class CameraListItem extends StatelessWidget {
  final String zone;
  final String location;
  final bool isActive;

  const CameraListItem({
    super.key,
    required this.zone,
    required this.location,
    required this.isActive,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              const Icon(Icons.videocam_rounded, size: 20, color: AppColors.info),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(zone, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                  Text(location, style: const TextStyle(fontSize: 11, color: AppColors.textMutedLight)),
                ],
              ),
            ],
          ),
          AppStatusPill(
            label: isActive ? 'LIVE' : 'OFFLINE',
            type: isActive ? StatusType.success : StatusType.neutral,
          ),
        ],
      ),
    );
  }
}
