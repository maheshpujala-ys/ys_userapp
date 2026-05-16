import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yellowspotuser/features/admin/data/admin_providers.dart';
import 'package:yellowspotuser/features/admin/entry_exit/screens/image_preview_screen.dart';

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
          final imageId = (item['imageId'] as String?) ?? '';
          final vehicleNumber = (item['vehicleNumber'] as String?) ?? '';
          return EntryExitListItem(
            vehicleNumber: vehicleNumber,
            unit: (item['unit'] as String?) ?? '',
            owner: (item['owner'] as String?) ?? '',
            isEntry: (item['isEntry'] as bool?) ?? false,
            timestamp: (item['timestamp'] as String?) ?? '',
            onTap: imageId.isEmpty
                ? null
                : () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => ImagePreviewScreen(
                          imageId: imageId,
                          title: vehicleNumber,
                        ),
                      ),
                    ),
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
  final VoidCallback? onTap;

  const EntryExitListItem({
    super.key,
    required this.vehicleNumber,
    required this.unit,
    required this.owner,
    required this.isEntry,
    required this.timestamp,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      child: ListTile(
        onTap: onTap,
        leading: Icon(
          isEntry ? Icons.arrow_forward : Icons.arrow_back,
          color: isEntry ? Colors.green : Colors.red,
        ),
        title: Row(
          children: [
            Flexible(
              child: Text(
                vehicleNumber,
                style: const TextStyle(fontWeight: FontWeight.bold),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (onTap != null) ...[
              const SizedBox(width: 6),
              Icon(Icons.visibility_outlined,
                  size: 16, color: Colors.blueGrey[400]),
            ],
          ],
        ),
        subtitle: Text('$unit • $owner'),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 8.0, vertical: 4.0),
              decoration: BoxDecoration(
                color: isEntry ? Colors.green[100] : Colors.red[100],
                borderRadius: BorderRadius.circular(5.0),
              ),
              child: Text(
                isEntry ? 'Entry' : 'Exit',
                style: TextStyle(
                    color: isEntry ? Colors.green[800] : Colors.red[800],
                    fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 4),
            Text(timestamp,
                style: const TextStyle(fontSize: 12, color: Colors.grey)),
          ],
        ),
      ),
    );
  }
}
