import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yellowspotuser/features/auth/application/auth_controller.dart';
import 'package:yellowspotuser/features/auth/screens/edit_profile_screen.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(AuthController.provider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        centerTitle: true,
      ),
      body: userAsync.when(
        data: (user) => SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              _buildProfileHeader(context, user?.name ?? 'Guest'),
              const SizedBox(height: 24),
              _buildSectionCard(
                title: 'Personal Information',
                icon: Icons.person_outline,
                children: [
                  _buildInfoRow('Full Name', user?.name ?? 'Guest'),
                  _buildInfoRow('Email Address', user?.email ?? ''),
                  _buildInfoRow('Phone Number', '+91 98765 43210'),
                ],
              ),
              const SizedBox(height: 16),
              _buildSectionCard(
                title: 'Residence Details',
                icon: Icons.home_outlined,
                children: [
                  _buildInfoRow('Building', 'Tower A'),
                  _buildInfoRow('Floor', '12'),
                  _buildInfoRow('# Flat Number', '1201'),
                ],
              ),
              const SizedBox(height: 16),
              _buildSectionCard(
                title: 'Emergency & ID',
                icon: Icons.shield_outlined,
                children: [
                  _buildInfoRow('Emergency Contact', '+91 98765 43211'),
                  _buildInfoRow('ID Proof', 'Aadhaar - XXXX XXXX 1234'),
                ],
              ),
              const SizedBox(height: 16),
              _buildSettingsList(ref),
              const SizedBox(height: 24),
              OutlinedButton.icon(
                onPressed: () async {
                  // Clear session first, then unwind any pushed routes so
                  // AuthWrapper's freshly-rebuilt LoginScreen is on top.
                  await ref
                      .read(AuthController.provider.notifier)
                      .logout();
                  if (context.mounted) {
                    Navigator.of(context).popUntil((r) => r.isFirst);
                  }
                },
                icon: const Icon(Icons.logout, color: Colors.red),
                label: const Text('Log Out', style: TextStyle(color: Colors.red)),
                style: OutlinedButton.styleFrom(side: const BorderSide(color: Colors.red)),
              ),
              const SizedBox(height: 16),
              const Text('Yellowspot v1.0.0', style: TextStyle(color: Colors.grey, fontSize: 12)),
            ],
          ),
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) => Center(child: Text(error.toString())),
      ),
    );
  }

  Widget _buildProfileHeader(BuildContext context, String name) {
    return Row(
      children: [
        CircleAvatar(
          radius: 30,
          backgroundColor: Colors.yellow[700],
          child: Text(name.isNotEmpty ? name[0].toUpperCase() : '', style: const TextStyle(fontSize: 24, color: Colors.black, fontWeight: FontWeight.bold)),
        ),
        const SizedBox(width: 16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(name, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            Row(
              children: [
                const Icon(Icons.verified_outlined, color: Colors.green, size: 16),
                const SizedBox(width: 4),
                const Text('Verified', style: TextStyle(color: Colors.green)),
                const SizedBox(width: 8),
                const Text('•', style: TextStyle(color: Colors.grey)),
                const SizedBox(width: 8),
                const Text('Owner', style: TextStyle(color: Colors.grey)),
              ],
            ),
          ],
        ),
        const Spacer(),
        IconButton(
          onPressed: () {
            Navigator.of(context).push(MaterialPageRoute(builder: (context) => const EditProfileScreen()));
          },
          icon: const Icon(Icons.edit_outlined),
        ),
      ],
    );
  }

  Widget _buildSectionCard({required String title, required IconData icon, required List<Widget> children}) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: Colors.grey[600]),
                const SizedBox(width: 8),
                Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ],
            ),
            const Divider(height: 24),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey)),
          const SizedBox(height: 4),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 16)),
        ],
      ),
    );
  }

  Widget _buildSettingsList(WidgetRef ref) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Column(
        children: [
          _buildSettingsItem(Icons.notifications_none_outlined, 'Notifications', () {}),
          _buildSettingsItem(Icons.privacy_tip_outlined, 'Privacy & Security', () {}),
          _buildSettingsItem(Icons.help_outline, 'Help & Support', () {}),
          _buildSettingsItem(Icons.description_outlined, 'Terms & Conditions', () {}),
          _buildSettingsItem(Icons.info_outline, 'About Yellowspot', () {}),
        ],
      ),
    );
  }

  Widget _buildSettingsItem(IconData icon, String title, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon, color: Colors.grey[600]),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: onTap,
    );
  }
}
