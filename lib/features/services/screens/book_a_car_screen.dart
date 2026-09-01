import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class BookACarScreen extends ConsumerWidget {
  const BookACarScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: const Text('Book a Car', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildPromoBanner(),
            const SizedBox(height: 24),
            _buildSectionHeader(icon: Icons.local_taxi_outlined, title: 'Book a Ride'),
            _buildRideSharingGrid(),
            const SizedBox(height: 24),
            _buildSectionHeader(icon: Icons.shopping_cart_outlined, title: 'Buy or Sell Cars'),
            _buildCarPlatformList(),
            const SizedBox(height: 24),
            _buildSectionHeader(icon: Icons.key_outlined, title: 'Car Rentals'),
            _buildCarRentalCard(),
          ],
        ),
      ),
    );
  }

  Widget _buildPromoBanner() {
    return Card(
      color: Colors.yellow[600],
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('First Ride Free!', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.black)),
                  const Text('Get up to ₹100 off on your first cab ride', style: TextStyle(color: Colors.black87)),
                  const SizedBox(height: 8),
                  Chip(label: const Text('YELLOWFIRST', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)), backgroundColor: Colors.yellow[700]),
                ],
              ),
            ),
            const Icon(Icons.card_giftcard, size: 40, color: Colors.black54),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader({required IconData icon, required String title}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        children: [
          Icon(icon, color: Colors.blue[800]),
          const SizedBox(width: 8),
          Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildRideSharingGrid() {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      childAspectRatio: 2.5,
      crossAxisSpacing: 8,
      mainAxisSpacing: 8,
      children: [
        _buildRideServiceCard(name: 'Uber', subtitle: 'Global rides', icon: Icons.local_taxi, iconColor: Colors.black),
        _buildRideServiceCard(name: 'Ola', subtitle: 'City rides', icon: Icons.directions_car, iconColor: Colors.green),
        _buildRideServiceCard(name: 'Rapido', subtitle: 'Bike taxi', icon: Icons.motorcycle, iconColor: Colors.yellow[800]!),
        _buildRideServiceCard(name: 'inDrive', subtitle: 'Bid your fare', icon: Icons.handshake_outlined, iconColor: Colors.blue),
      ],
    );
  }

  Widget _buildRideServiceCard({required String name, required String subtitle, required IconData icon, required Color iconColor}) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          children: [
            CircleAvatar(
              radius: 20,
              backgroundColor: iconColor.withValues(alpha: 0.1),
              child: Icon(icon, size: 20, color: iconColor),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                  Text(subtitle, style: const TextStyle(fontSize: 10, color: Colors.grey), overflow: TextOverflow.ellipsis),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildCarPlatformList() {
    return Column(
      children: [
        _buildCarPlatformCard(name: 'Spinny', subtitle: 'Pre-owned cars', icon: Icons.verified_outlined, color: Colors.indigo),
        _buildCarPlatformCard(name: 'Cars24', subtitle: 'Buy & Sell', icon: Icons.swap_horiz_outlined, color: Colors.orange),
        _buildCarPlatformCard(name: 'CarDekho', subtitle: 'Expert research', icon: Icons.manage_search_outlined, color: Colors.blue),
        _buildCarPlatformCard(name: 'CarWale', subtitle: 'Compare cars', icon: Icons.compare_arrows_outlined, color: Colors.red),
      ],
    );
  }

  Widget _buildCarPlatformCard({required String name, required String subtitle, required IconData icon, required Color color}) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color.withValues(alpha: 0.1),
          child: Icon(icon, color: color, size: 20),
        ),
        title: Text(name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
        subtitle: Text(subtitle, style: const TextStyle(fontSize: 12)),
        trailing: const Icon(Icons.arrow_forward_ios, size: 14),
      ),
    );
  }

  Widget _buildCarRentalCard() {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(backgroundColor: Colors.blue[50], child: Icon(Icons.time_to_leave_outlined, color: Colors.blue[800])),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text('Self-Drive', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    Text('Rent cars without driver', style: TextStyle(color: Colors.grey, fontSize: 12)),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                _buildRentalChip('Zoomcar', Colors.green),
                const SizedBox(width: 8),
                _buildRentalChip('Revv', Colors.deepPurple),
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget _buildRentalChip(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Text(label, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 12)),
    );
  }
}
