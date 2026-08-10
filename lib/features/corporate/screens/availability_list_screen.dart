import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yellowspotuser/features/corporate/data/corporate_providers.dart';
import 'package:yellowspotuser/features/corporate/domain/corporate_models.dart';

class AvailabilityListScreen extends ConsumerWidget {
  const AvailabilityListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(availabilityListProvider);
    return Scaffold(
      backgroundColor: const Color(0xFFF6F7FB),
      appBar: AppBar(
        title: const Text(
          'Availability List',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0.5,
      ),
      body: RefreshIndicator(
        onRefresh: () async => ref.invalidate(availabilityListProvider),
        child: async.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, _) => _ErrorState(
            message: err.toString(),
            onRetry: () => ref.invalidate(availabilityListProvider),
          ),
          data: (rows) {
            if (rows.isEmpty) return const _EmptyState();
            return ListView.separated(
              padding: const EdgeInsets.all(12),
              physics: const AlwaysScrollableScrollPhysics(),
              itemCount: rows.length + 1,
              separatorBuilder: (context, index) =>
                  const SizedBox(height: 10),
              itemBuilder: (context, i) {
                if (i == 0) return _Summary(rows: rows);
                return _AvailabilityCard(index: i, row: rows[i - 1]);
              },
            );
          },
        ),
      ),
    );
  }
}

class _Summary extends StatelessWidget {
  const _Summary({required this.rows});
  final List<AvailabilityRow> rows;

  @override
  Widget build(BuildContext context) {
    var total = 0, occupied = 0, vacant = 0;
    for (final r in rows) {
      total += r.total;
      occupied += r.occupied;
      vacant += r.vacant;
    }
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Expanded(
              child: _SummaryCell(
                  label: 'Total', value: total, color: Colors.blue.shade700)),
          _Divider(),
          Expanded(
              child: _SummaryCell(
                  label: 'Occupied',
                  value: occupied,
                  color: Colors.orange.shade800)),
          _Divider(),
          Expanded(
              child: _SummaryCell(
                  label: 'Vacant',
                  value: vacant,
                  color: Colors.green.shade700)),
        ],
      ),
    );
  }
}

class _SummaryCell extends StatelessWidget {
  const _SummaryCell({
    required this.label,
    required this.value,
    required this.color,
  });
  final String label;
  final int value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text('$value',
            style: TextStyle(
                fontSize: 22, fontWeight: FontWeight.bold, color: color)),
        Text(label,
            style: TextStyle(fontSize: 11, color: Colors.grey.shade600)),
      ],
    );
  }
}

class _Divider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      height: 32,
      color: Colors.grey.shade200,
    );
  }
}

class _AvailabilityCard extends StatelessWidget {
  const _AvailabilityCard({required this.index, required this.row});
  final int index;
  final AvailabilityRow row;

  @override
  Widget build(BuildContext context) {
    final ratio = row.total > 0 ? (row.occupied / row.total).clamp(0.0, 1.0) : 0.0;
    final ratioColor = ratio >= 0.9
        ? Colors.red.shade400
        : ratio >= 0.6
            ? Colors.orange.shade400
            : Colors.green.shade500;
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 8),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 14,
                  backgroundColor: Colors.blue.shade50,
                  child: Text('$index',
                      style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue.shade700)),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    row.companyName.isEmpty ? '—' : row.companyName,
                    style: const TextStyle(
                        fontSize: 15, fontWeight: FontWeight.bold),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (row.vehicleType.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: Colors.indigo.shade50,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(row.vehicleType,
                        style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: Colors.indigo.shade700)),
                  ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 0, 14, 10),
            child: Row(
              children: [
                Expanded(
                    child: _Stat(
                        label: 'Total',
                        value: row.total,
                        color: Colors.blue.shade700)),
                Expanded(
                    child: _Stat(
                        label: 'Occupied',
                        value: row.occupied,
                        color: Colors.orange.shade800)),
                Expanded(
                    child: _Stat(
                        label: 'Vacant',
                        value: row.vacant,
                        color: Colors.green.shade700)),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 0, 14, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Occupancy',
                        style: TextStyle(
                            fontSize: 11, color: Colors.grey.shade600)),
                    Text('${(ratio * 100).round()}%',
                        style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: ratioColor)),
                  ],
                ),
                const SizedBox(height: 4),
                ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: LinearProgressIndicator(
                    value: ratio,
                    minHeight: 6,
                    backgroundColor: Colors.grey.shade200,
                    valueColor: AlwaysStoppedAnimation(ratioColor),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({
    required this.label,
    required this.value,
    required this.color,
  });
  final String label;
  final int value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text('$value',
            style: TextStyle(
                fontSize: 18, fontWeight: FontWeight.bold, color: color)),
        Text(label,
            style: TextStyle(fontSize: 11, color: Colors.grey.shade600)),
      ],
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      children: [
        const SizedBox(height: 120),
        Icon(Icons.inbox_outlined, size: 48, color: Colors.grey.shade400),
        const SizedBox(height: 12),
        Center(
          child: Text('No availability data',
              style: TextStyle(color: Colors.grey.shade600, fontSize: 14)),
        ),
      ],
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.message, required this.onRetry});
  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(24),
      children: [
        const SizedBox(height: 100),
        const Icon(Icons.error_outline, color: Colors.red, size: 48),
        const SizedBox(height: 12),
        Center(child: Text(message, textAlign: TextAlign.center)),
        const SizedBox(height: 16),
        Center(
          child: OutlinedButton(
            onPressed: onRetry,
            child: const Text('Retry'),
          ),
        ),
      ],
    );
  }
}
