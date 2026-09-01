import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yellowspotuser/features/admin/data/admin_providers.dart';

class EntryExitScreen extends ConsumerWidget {
  const EntryExitScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final entryExitState = ref.watch(entryExitDataProvider);
    return entryExitState.when(
      data: (data) => ListView.builder(
        itemCount: data.length,
        itemBuilder: (context, index) {
          final item = data[index];
          return EntryExitListItem(
            vehicleNumber: item['vehicleNumber'],
            unit: item['unit'],
            owner: item['owner'],
            isEntry: item['isEntry'],
            timestamp: item['timestamp'],
          );
        },
      ),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stackTrace) => Center(child: Text(error.toString())),
    );
  }
}

class EntryExitListItem extends StatelessWidget {
  final String vehicleNumber;
  final String unit;
  final String owner;
  final bool isEntry;
  final String timestamp;

  const EntryExitListItem({
    super.key,
    required this.vehicleNumber,
    required this.unit,
    required this.owner,
    required this.isEntry,
    required this.timestamp,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      child: ListTile(
        leading: Icon(
          isEntry ? Icons.arrow_forward : Icons.arrow_back,
          color: isEntry ? Colors.green : Colors.red,
        ),
        title: Text(vehicleNumber, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text('$unit • $owner'),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
              decoration: BoxDecoration(
                color: isEntry ? Colors.green[100] : Colors.red[100],
                borderRadius: BorderRadius.circular(5.0),
              ),
              child: Text(
                isEntry ? 'Entry' : 'Exit',
                style: TextStyle(color: isEntry ? Colors.green[800] : Colors.red[800], fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 4),
            Text(timestamp, style: const TextStyle(fontSize: 12, color: Colors.grey)),
          ],
        ),
      ),
    );
  }
}
