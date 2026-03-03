import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yellowspotuser/features/admin/data/admin_providers.dart';

class ActivityScreen extends ConsumerWidget {
  const ActivityScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activityState = ref.watch(activityDataProvider);
    return activityState.when(
      data: (data) => ListView.builder(
        itemCount: data.length,
        itemBuilder: (context, index) {
          final item = data[index];
          return ActivityListItem(
            title: item['title'],
            subtitle: item['subtitle'],
            timestamp: item['timestamp'],
          );
        },
      ),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stackTrace) => Center(child: Text(error.toString())),
    );
  }
}

class ActivityListItem extends StatelessWidget {
  final String title;
  final String subtitle;
  final String timestamp;

  const ActivityListItem({
    Key? key,
    required this.title,
    required this.subtitle,
    required this.timestamp,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      child: ListTile(
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(subtitle),
        trailing: Text(timestamp, style: const TextStyle(fontSize: 12, color: Colors.grey)),
      ),
    );
  }
}
