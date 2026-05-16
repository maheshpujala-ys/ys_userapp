import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yellowspotuser/features/admin/data/admin_providers.dart';

class SecurityScreen extends ConsumerWidget {
  const SecurityScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final securityState = ref.watch(securityDataProvider);
    return securityState.when(
      data: (data) => SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            children: [
              _buildSecurityStats(data),
              const SizedBox(height: 16),
              _buildCameraNetworkSection(),
            ],
          ),
        ),
      ),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stackTrace) => Center(child: Text(error.toString())),
    );
  }

  Widget _buildSecurityStats(Map<String, dynamic> data) {
    return GridView.count(
      shrinkWrap: true,
      crossAxisCount: 2,
      childAspectRatio: 2.2, // Increased ratio to reduce card height and prevent vertical overflow
      crossAxisSpacing: 8,
      mainAxisSpacing: 8,
      physics: const NeverScrollableScrollPhysics(),
      children: [
        _buildStatCard('Active Cameras', data['activeCameras'].toString(), Icons.videocam_outlined),
        _buildStatCard('Security Alerts', data['securityAlerts'].toString(), Icons.warning_amber_outlined, isAlert: true),
        _buildStatCard('Recording Hours', data['recordingHours'].toString(), Icons.history_outlined),
        _buildStatCard('Storage Used', '${data['storageUsed']}% ', Icons.storage_outlined),
        _buildStatCard('Incidents', data['incidents'].toString(), Icons.error_outline),
        _buildStatCard('System Status', data['systemStatus'].toString(), Icons.verified_user_outlined, isSecure: data['systemStatus'] == 'SECURE'),
      ],
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, {bool isAlert = false, bool isSecure = false}) {
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 20, color: isAlert ? Colors.red : (isSecure ? Colors.green : Colors.black)),
            const SizedBox(height: 4),
            Text(
              value, 
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              overflow: TextOverflow.ellipsis,
            ),
            Flexible(
              child: Text(
                title, 
                textAlign: TextAlign.center, 
                style: const TextStyle(fontSize: 11),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCameraNetworkSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Security Camera Network', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            TextButton(
              onPressed: () {}, 
              style: TextButton.styleFrom(visualDensity: VisualDensity.compact),
              child: const Text('View All'),
            ),
          ],
        ),
        const CameraListItem(zone: 'Zone A - Entry Gate', location: 'Main Entrance', isActive: true),
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
    return Card(
      child: ListTile(
        visualDensity: VisualDensity.compact,
        title: Text(zone, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
        subtitle: Text(location, style: const TextStyle(fontSize: 12)),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
              decoration: BoxDecoration(
                color: isActive ? Colors.green[100] : Colors.grey[200],
                borderRadius: BorderRadius.circular(5.0),
              ),
              child: Text(
                isActive ? 'active' : 'inactive', 
                style: TextStyle(color: isActive ? Colors.green[800] : Colors.grey[600], fontSize: 10, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(width: 8),
            const Icon(Icons.visibility_outlined, size: 20),
          ],
        ),
      ),
    );
  }
}
