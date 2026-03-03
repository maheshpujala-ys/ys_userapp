import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';

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
            _buildSectionHeader(icon: Icons.send_outlined, title: 'Book a Ride'),
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
                  Chip(label: const Text('YELLOWFIRST'), backgroundColor: Colors.yellow[700]),
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
    return Row(
      children: [
        Icon(icon, color: Colors.grey[600]),
        const SizedBox(width: 8),
        Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildRideSharingGrid() {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      childAspectRatio: 2.5,
      children: [
        _buildRideServiceCard(name: 'Uber', subtitle: 'Ride with Uber', svgAsset: 'assets/icons/uber_logo.svg'),
        _buildRideServiceCard(name: 'Ola', subtitle: 'Book Ola Cabs', svgAsset: 'assets/icons/ola_logo.svg'),
        _buildRideServiceCard(name: 'Rapido', subtitle: 'Bike Taxi', svgAsset: 'assets/icons/rapido_logo.svg'),
        _buildRideServiceCard(name: 'inDrive', subtitle: 'Negotiate your fare'), // Placeholder
      ],
    );
  }

  Widget _buildRideServiceCard({required String name, required String subtitle, String? svgAsset}) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          children: [
            if(svgAsset != null)
              SvgPicture.asset(svgAsset, height: 30, width: 30),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
                  Text(subtitle, style: const TextStyle(fontSize: 12, color: Colors.grey)),
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
        _buildCarPlatformCard(name: 'Spinny', subtitle: 'Pre-owned cars with warranty'),
        _buildCarPlatformCard(name: 'Cars24', subtitle: 'Buy or sell used cars'),
        _buildCarPlatformCard(name: 'CarDekho', subtitle: 'New & used car research'),
        _buildCarPlatformCard(name: 'CarWale', subtitle: 'Compare & buy cars'),
      ],
    );
  }

  Widget _buildCarPlatformCard({required String name, required String subtitle}) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: ListTile(
        title: Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.open_in_new, size: 16),
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
            const Text('Self-Drive', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const Text('Rent cars without driver', style: TextStyle(color: Colors.grey)),
            const SizedBox(height: 8),
            Row(
              children: const [                Chip(label: Text('Zoomcar')),                SizedBox(width: 8),
                Chip(label: Text('Revv')),
              ],
            )
          ],
        ),
      ),
    );
  }
}
