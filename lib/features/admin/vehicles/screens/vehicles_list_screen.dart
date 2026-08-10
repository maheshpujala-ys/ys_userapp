import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yellowspotuser/features/admin/vehicles/data/vehicles_remote_data_source.dart';
import 'package:yellowspotuser/features/admin/vehicles/screens/add_vehicle_screen.dart';

/// Admin-side list of registered vehicles. Pulls from GET /api/v1/vehicle.
class VehiclesListScreen extends ConsumerWidget {
  const VehiclesListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final vehicles = ref.watch(vehiclesListProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Vehicles')),
      body: vehicles.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => _ErrorState(
          message: e.toString(),
          onRetry: () => ref.invalidate(vehiclesListProvider),
        ),
        data: (rows) {
          if (rows.isEmpty) return const _EmptyState();
          return RefreshIndicator(
            onRefresh: () async => ref.invalidate(vehiclesListProvider),
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: rows.length,
              separatorBuilder: (_, _) => const SizedBox(height: 8),
              itemBuilder: (_, i) => _VehicleTile(
                vehicle: rows[i],
                onEdit: () async {
                  await showModalBottomSheet<void>(
                    context: context,
                    isScrollControlled: true,
                    builder: (_) => AddVehicleScreen(existing: rows[i]),
                  );
                  ref.invalidate(vehiclesListProvider);
                },
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: Colors.yellow[700],
        foregroundColor: Colors.black,
        icon: const Icon(Icons.add),
        label: const Text('Add Vehicle'),
        onPressed: () async {
          await showModalBottomSheet<void>(
            context: context,
            isScrollControlled: true,
            builder: (_) => const AddVehicleScreen(),
          );
          ref.invalidate(vehiclesListProvider);
        },
      ),
    );
  }
}

class _VehicleTile extends StatelessWidget {
  const _VehicleTile({required this.vehicle, required this.onEdit});

  final VehicleRegistrationSummary vehicle;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    final regType = vehicle.registrationType;
    final tenant = vehicle.tenantName;
    final carType = vehicle.carType;
    final start = vehicle.startDate;
    final end = vehicle.endDate;
    final isActive = vehicle.isActive;

    return Card(
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onEdit,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: Colors.teal[50],
              child: Icon(
                Icons.directions_car_outlined,
                color: Colors.teal[700],
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          vehicle.vehicleNumber.isEmpty
                              ? '(no number)'
                              : vehicle.vehicleNumber,
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 16),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      _StatusChip(active: isActive),
                    ],
                  ),
                  if (tenant != null && tenant.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        const Icon(Icons.person_outline,
                            size: 14, color: Colors.grey),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(tenant,
                              style: TextStyle(
                                  color: Colors.grey[700], fontSize: 13),
                              overflow: TextOverflow.ellipsis),
                        ),
                      ],
                    ),
                  ],
                  const SizedBox(height: 4),
                  Wrap(
                    spacing: 6,
                    runSpacing: 4,
                    children: [
                      if (regType != null && regType.isNotEmpty)
                        _MetaChip(label: regType, color: Colors.blue),
                      if (carType != null && carType.isNotEmpty)
                        _MetaChip(label: carType, color: Colors.deepPurple),
                    ],
                  ),
                  if (start != null && start.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      _formatRange(start, end),
                      style:
                          TextStyle(color: Colors.grey[600], fontSize: 12),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
      ),
    );
  }
}

/// Human-readable `30 Jun 2025` or `30 Jun 2025 → 30 Jun 2026`.
/// Falls back to the raw string if it can't be parsed.
String _formatRange(String start, String? end) {
  final s = _formatDate(start);
  final e = (end != null && end.isNotEmpty) ? _formatDate(end) : null;
  return e == null ? 'From $s' : 'Valid $s → $e';
}

String _formatDate(String raw) {
  final dt = DateTime.tryParse(raw);
  if (dt == null) return raw;
  const months = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
  ];
  return '${dt.day.toString().padLeft(2, '0')} ${months[dt.month - 1]} ${dt.year}';
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.active});
  final bool active;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: active ? Colors.green[50] : Colors.red[50],
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        active ? 'Active' : 'Inactive',
        style: TextStyle(
          color: active ? Colors.green[700] : Colors.red[700],
          fontSize: 11,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

class _MetaChip extends StatelessWidget {
  const _MetaChip({required this.label, required this.color});
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.directions_car_outlined,
                size: 64, color: Colors.grey[400]),
            const SizedBox(height: 12),
            const Text('No vehicles registered yet',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 4),
            Text('Tap "Add Vehicle" to register the first one.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey[600])),
          ],
        ),
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.red),
            const SizedBox(height: 12),
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            OutlinedButton(
              onPressed: onRetry,
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}
