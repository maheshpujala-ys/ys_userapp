import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yellowspotuser/features/admin/entry_exit/screens/entry_exit_screen.dart';
import 'package:yellowspotuser/features/corporate/data/corporate_providers.dart';

/// Entry/Exit tab for the corporate dashboard. Renders the same
/// `ParkingLogRow` list that powers Recent Activities — sourced from
/// `/dashboard/parking-logs` via [corporateDashboardProvider].
class CorporateEntryExitScreen extends ConsumerWidget {
  const CorporateEntryExitScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(corporateDashboardProvider);
    return async.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text(e.toString())),
      data: (data) {
        final rows = data.recentActivities;
        if (rows.isEmpty) {
          return const Center(child: Text('No entry/exit activity yet'));
        }
        return RefreshIndicator(
          onRefresh: () async => ref.invalidate(corporateDashboardProvider),
          child: ListView.builder(
            itemCount: rows.length,
            itemBuilder: (context, index) {
              final r = rows[index];
              return EntryExitListItem(
                vehicleNumber: r.vehicleNumber,
                unit: r.flatUnit,
                owner: r.tenantName,
                isEntry: r.isEntry,
                timestamp: _formatTimestamp(r.logTime),
              );
            },
          ),
        );
      },
    );
  }

  String _formatTimestamp(DateTime? dt) {
    if (dt == null) return '';
    final now = DateTime.now();
    final diff = now.difference(dt);
    if (diff.isNegative) return _iso(dt);
    if (diff.inSeconds < 60) return 'just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return _iso(dt);
  }

  String _iso(DateTime dt) {
    String two(int n) => n.toString().padLeft(2, '0');
    return '${dt.year}-${two(dt.month)}-${two(dt.day)} '
        '${two(dt.hour)}:${two(dt.minute)}';
  }
}
