import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yellowspotuser/core/providers/app_providers.dart';
import 'package:yellowspotuser/features/auth/application/auth_controller.dart';
import 'package:yellowspotuser/features/auth/domain/app_user.dart';
import 'package:yellowspotuser/features/residential/application/residential_controller.dart';
import 'package:yellowspotuser/features/residential/domain/vehicle.dart';

class ResidentialScreen extends ConsumerWidget {
  const ResidentialScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final residentialState = ref.watch(ResidentialController.provider);
    final isAdmin = ref.watch(AuthController.provider.select(
      (s) => s.asData?.value?.roles.contains(UserRole.admin) ?? false,
    ));

    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: residentialState.when(
        data: (data) => SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildHeader(context, ref, data['society'] ?? '', data['unit'] ?? '', isAdmin),
              _buildOwnerCard(context, data['ownerName'] ?? ''),
              _buildActionCards(context),
              _buildSmartAccessCard(context),
              _buildEvCharging(context),
              _buildMyVehicles(context, data['vehicles'] as List<Vehicle>? ?? const []),
            ],
          ),
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) => Center(child: Text(error.toString())),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, WidgetRef ref, String society, String unit, bool isAdmin) {
    return Container(
      color: Colors.teal[400],
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      child: SafeArea(
        bottom: false,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(society, style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold), overflow: TextOverflow.ellipsis),
                  Text(unit, style: const TextStyle(color: Colors.white70, fontSize: 16), overflow: TextOverflow.ellipsis),
                ],
              ),
            ),
            if (isAdmin)
              TextButton.icon(
                style: TextButton.styleFrom(backgroundColor: Colors.white.withOpacity(0.2)),
                icon: const Icon(Icons.admin_panel_settings_outlined, color: Colors.white, size: 18),
                label: const Text('Admin', style: TextStyle(color: Colors.white, fontSize: 12)),
                onPressed: () => ref.read(isAdminViewProvider.notifier).state = true,
              ),
          ],
        ),
      ),
    );
  }

  void _showSnackbar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  Widget _buildOwnerCard(BuildContext context, String ownerName) {
    return Card(
      margin: const EdgeInsets.all(16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            const CircleAvatar(
              backgroundColor: Colors.blueAccent,
              child: Icon(Icons.person_outline, color: Colors.white),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(ownerName, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold), overflow: TextOverflow.ellipsis),
                  const Text('Owner', style: TextStyle(color: Colors.grey)),
                ],
              ),
            ),
            const SizedBox(width: 8),
            OutlinedButton.icon(
              onPressed: () => _showSnackbar(context, 'Edit Owner Tapped'), 
              icon: const Icon(Icons.edit_outlined, size: 16), 
              label: const Text('Edit', style: TextStyle(fontSize: 12)),
              style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 8)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionCards(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Row(
        children: [
          Expanded(child: _buildActionCard(context, Icons.qr_code_scanner, 'Visitor Pass', 'Generate QR', () {
            _showSnackbar(context, 'Generating Visitor Pass...');
          })),
          const SizedBox(width: 12),
          Expanded(child: _buildActionCard(context, Icons.local_parking_outlined, 'Book Spot', 'Reserve for guests', () => _showSnackbar(context, 'Book Visitor Spot Tapped'))),
        ],
      ),
    );
  }

  Widget _buildActionCard(BuildContext context, IconData icon, String title, String subtitle, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(15),
      child: Card(
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 32, color: Colors.yellow[700]),
              const SizedBox(height: 8),
              Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14), overflow: TextOverflow.ellipsis),
              const SizedBox(height: 4),
              Text(subtitle, textAlign: TextAlign.center, style: TextStyle(color: Colors.grey[600], fontSize: 10), overflow: TextOverflow.ellipsis, maxLines: 1),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSmartAccessCard(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Smart Access Card', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          Card(
            margin: const EdgeInsets.only(top: 8),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Row(
                    children: [
                      const Icon(Icons.credit_card_outlined, color: Colors.blueAccent),
                      const SizedBox(width: 8),
                      const Expanded(child: Text('RFID Tag', style: TextStyle(fontWeight: FontWeight.bold))),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        decoration: BoxDecoration(color: Colors.green.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
                        child: const Text('Active', style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 12)),
                      ),
                    ],
                  ),
                  const Divider(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('Issued Date', style: TextStyle(fontSize: 12, color: Colors.grey)), Text('1/15/2024', style: TextStyle(fontWeight: FontWeight.bold))])),
                      const Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.end, children: [Text('Card Type', style: TextStyle(fontSize: 12, color: Colors.grey)), Text('RFID Tag', style: TextStyle(fontWeight: FontWeight.bold))])),
                    ],
                  ),
                  const SizedBox(height: 16),
                  OutlinedButton.icon(
                    onPressed: () => _showSnackbar(context, 'View QR Code Tapped'),
                    icon: const Icon(Icons.qr_code, size: 18),
                    label: const Text('View QR Code'),
                    style: OutlinedButton.styleFrom(minimumSize: const Size.fromHeight(40)),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEvCharging(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('EV Charging', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              TextButton(onPressed: () {}, child: const Text('View All'))
            ],
          ),
          Card(
            margin: EdgeInsets.zero,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  const Icon(Icons.ev_station, color: Colors.green, size: 32),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('EV Charging Available', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                        Text('2 slots available', style: TextStyle(fontSize: 12, color: Colors.grey)),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: const [
                      Text('50m away', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                      Text('2-4 hours', style: TextStyle(fontSize: 10, color: Colors.grey)),
                    ],
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMyVehicles(BuildContext context, List<Vehicle> vehicles) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('My Vehicles', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          // Small fixed list — Column avoids the cost of a nested scrollable.
          for (final v in vehicles) VehicleListItem(key: ValueKey(v.number), vehicle: v),
        ],
      ),
    );
  }
}

class VehicleListItem extends StatelessWidget {
  final Vehicle vehicle;

  const VehicleListItem({super.key, required this.vehicle});

  @override
  Widget build(BuildContext context) {
    final bool is4W = vehicle.type == VehicleType.fourWheeler;

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          children: [
            Icon(
              is4W ? Icons.directions_car_filled_outlined : Icons.motorcycle_outlined,
              size: 24,
              color: is4W ? Colors.blueGrey[700] : Colors.teal[700],
            ),
            const SizedBox(width: 12),
            _buildPlate(vehicle.plateType, vehicle.number),
            const SizedBox(width: 8),
            if (vehicle.plateType == PlateType.ev)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(color: Colors.green, borderRadius: BorderRadius.circular(4)),
                child: const Text('EV', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
              ),
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: vehicle.isActive ? Colors.green.withOpacity(0.1) : Colors.red.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                vehicle.isActive ? 'Active' : 'Inactive', 
                style: TextStyle(color: vehicle.isActive ? Colors.green : Colors.red, fontWeight: FontWeight.bold, fontSize: 10)
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlate(PlateType plateType, String number) {
    Color plateColor;
    Color textColor;
    switch (plateType) {
      case PlateType.ev:
        plateColor = Colors.green;
        textColor = Colors.white;
        break;
      case PlateType.taxi:
        plateColor = Colors.yellow;
        textColor = Colors.black;
        break;
      default:
        plateColor = Colors.white;
        textColor = Colors.black;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: plateColor,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: Colors.black87, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 1,
            offset: const Offset(0, 1),
          )
        ]
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('IND', style: TextStyle(fontSize: 6, fontWeight: FontWeight.bold, color: Colors.blue)),
          const SizedBox(width: 4),
          Text(
            number, 
            style: TextStyle(color: textColor, fontWeight: FontWeight.bold, fontSize: 12, letterSpacing: 1),
          ),
        ],
      ),
    );
  }
}
