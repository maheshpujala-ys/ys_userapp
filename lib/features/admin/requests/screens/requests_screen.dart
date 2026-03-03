import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yellowspotuser/features/admin/data/admin_providers.dart';

class RequestsScreen extends ConsumerWidget {
  const RequestsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final requestsState = ref.watch(requestsDataProvider);
    return requestsState.when(
      data: (data) => ListView.builder(
        itemCount: data.length,
        itemBuilder: (context, index) {
          final item = data[index];
          return RequestListItem(
            userName: item['userName'],
            unit: item['unit'],
            requestType: item['requestType'],
            timestamp: item['timestamp'],
          );
        },
      ),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stackTrace) => Center(child: Text(error.toString())),
    );
  }
}

class RequestListItem extends StatelessWidget {
  final String userName;
  final String unit;
  final String requestType;
  final String timestamp;

  const RequestListItem({
    Key? key,
    required this.userName,
    required this.unit,
    required this.requestType,
    required this.timestamp,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(userName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                Text(timestamp, style: const TextStyle(fontSize: 12, color: Colors.grey)),
              ],
            ),
            Text(unit, style: const TextStyle(color: Colors.grey)),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                  decoration: BoxDecoration(
                    color: Colors.blue[100],
                    borderRadius: BorderRadius.circular(5.0),
                  ),
                  child: Text(requestType, style: TextStyle(color: Colors.blue[800], fontWeight: FontWeight.bold)),
                ),
                Row(
                  children: [
                    OutlinedButton(onPressed: () {}, child: const Text('Reject')),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.yellow[700]),
                      child: const Text('Approve', style: TextStyle(color: Colors.black)),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
