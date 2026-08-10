import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yellowspotuser/features/admin/residents/domain/tenant_models.dart';
import 'package:yellowspotuser/features/admin/residents/screens/add_resident_screen.dart';
import 'package:yellowspotuser/features/admin/vehicles/application/registration_providers.dart';

/// Admin-side list of residents (tenants). Pulls from GET /api/v1/tenants.
///
/// Corporate dashboards reuse this screen with `entityLabelSingular: 'Employee'`
/// and `entityLabelPlural: 'Employees'` — the underlying tenants endpoint is
/// shared across solution types.
class ResidentsListScreen extends ConsumerWidget {
  const ResidentsListScreen({
    super.key,
    this.entityLabelSingular = 'Resident',
    this.entityLabelPlural = 'Residents',
  });

  final String entityLabelSingular;
  final String entityLabelPlural;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tenants = ref.watch(tenantsListProvider);
    final addLabel = 'Add $entityLabelSingular';

    return Scaffold(
      appBar: AppBar(title: Text(entityLabelPlural)),
      body: tenants.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => _ErrorState(
          message: e.toString(),
          onRetry: () => ref.invalidate(tenantsListProvider),
        ),
        data: (rows) {
          if (rows.isEmpty) {
            return _EmptyState(
              entityLabelSingular: entityLabelSingular,
              entityLabelPlural: entityLabelPlural,
            );
          }
          return RefreshIndicator(
            onRefresh: () async => ref.invalidate(tenantsListProvider),
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: rows.length,
              separatorBuilder: (_, _) => const SizedBox(height: 8),
              itemBuilder: (_, i) => _ResidentTile(
                tenant: rows[i],
                onEdit: () async {
                  await showModalBottomSheet<void>(
                    context: context,
                    isScrollControlled: true,
                    builder: (_) =>
                        AddResidentScreen(existing: rows[i]),
                  );
                  ref.invalidate(tenantsListProvider);
                },
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: Colors.yellow[700],
        foregroundColor: Colors.black,
        icon: const Icon(Icons.person_add_alt_1),
        label: Text(addLabel),
        onPressed: () async {
          await showModalBottomSheet<void>(
            context: context,
            isScrollControlled: true,
            builder: (_) => const AddResidentScreen(),
          );
          ref.invalidate(tenantsListProvider);
        },
      ),
    );
  }
}

class _ResidentTile extends StatelessWidget {
  const _ResidentTile({required this.tenant, required this.onEdit});

  final TenantSummary tenant;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    final unitBits = [tenant.tower, tenant.floor, tenant.flat]
        .where((s) => s != null && s.isNotEmpty)
        .toList();
    final unit = unitBits.isEmpty ? null : unitBits.join('-');
    final type = tenant.type;
    final mobile = tenant.mobile;
    final email = tenant.email;

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
              backgroundColor: Colors.yellow[100],
              child: Text(
                _initials(tenant.name),
                style: const TextStyle(
                    color: Colors.black87, fontWeight: FontWeight.bold),
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
                          tenant.name.isEmpty ? '(unnamed)' : tenant.name,
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 16),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (type != null && type.isNotEmpty)
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.blue[50],
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(type,
                              style: TextStyle(
                                  color: Colors.blue[700],
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold)),
                        ),
                    ],
                  ),
                  if (unit != null) ...[
                    const SizedBox(height: 2),
                    Text('Unit $unit',
                        style:
                            TextStyle(color: Colors.grey[700], fontSize: 13)),
                  ],
                  if (mobile != null && mobile.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        const Icon(Icons.phone_outlined,
                            size: 14, color: Colors.grey),
                        const SizedBox(width: 4),
                        Text(mobile,
                            style: TextStyle(
                                color: Colors.grey[700], fontSize: 12)),
                      ],
                    ),
                  ],
                  if (email != null && email.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        const Icon(Icons.email_outlined,
                            size: 14, color: Colors.grey),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(email,
                              style: TextStyle(
                                  color: Colors.grey[700], fontSize: 12),
                              overflow: TextOverflow.ellipsis),
                        ),
                      ],
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

  String _initials(String name) {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty || parts.first.isEmpty) return '?';
    if (parts.length == 1) return parts.first.substring(0, 1).toUpperCase();
    return (parts.first.substring(0, 1) + parts.last.substring(0, 1))
        .toUpperCase();
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({
    required this.entityLabelSingular,
    required this.entityLabelPlural,
  });

  final String entityLabelSingular;
  final String entityLabelPlural;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.people_outline, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 12),
            Text('No ${entityLabelPlural.toLowerCase()} yet',
                style: const TextStyle(
                    fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 4),
            Text('Tap "Add $entityLabelSingular" to register the first one.',
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
