import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class CarServicesScreen extends ConsumerWidget {
  const CarServicesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Colors.grey[100],
        elevation: 0,
        centerTitle: true,
        title: const Text('Car Services', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildOngoingServiceCard(),
            const SizedBox(height: 24),
            _buildEmergencyServices(),
            const SizedBox(height: 24),
            _buildAllServices(),
          ],
        ),
      ),
    );
  }

  Widget _buildOngoingServiceCard() {
    return Card(
      color: Colors.yellow[600],
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              children: [
                const Icon(Icons.settings_outlined, size: 30),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text(
                        'Regular Service', 
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        'TS 09 AB 1234 • Tata Nexon EV', 
                        style: TextStyle(color: Colors.black87, fontSize: 13),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(color: Colors.green, borderRadius: BorderRadius.circular(20)),
                  child: const Text(
                    'In Progress', 
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 11),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: const [
                Flexible(child: Text('AutoZone Service Center', style: TextStyle(fontSize: 12), overflow: TextOverflow.ellipsis)),
                Flexible(child: Text('Est. 2 hours remaining', style: TextStyle(fontSize: 12), overflow: TextOverflow.ellipsis)),
              ],
            ),
            const SizedBox(height: 8),
            const LinearProgressIndicator(value: 0.6, backgroundColor: Colors.white, color: Colors.green,),
          ],
        ),
      ),
    );
  }

  Widget _buildEmergencyServices() {
    return Card(
      color: Colors.red[50],
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Emergency Services', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.red)),
            const Text('24/7 assistance when you need it most', style: TextStyle(color: Colors.redAccent, fontSize: 13)),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildEmergencyServiceIcon(Icons.support_agent_outlined, 'Roadside\nAssi...'),
                _buildEmergencyServiceIcon(Icons.car_crash_outlined, 'Towing\nService'),
                _buildEmergencyServiceIcon(Icons.vpn_key_outlined, 'Key\nLockout'),
                _buildEmergencyServiceIcon(Icons.local_gas_station_outlined, 'Fuel\nDelivery'),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.call, color: Colors.white, size: 18,),
                label: const Text('Call SOS Helpline', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red, 
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildEmergencyServiceIcon(IconData icon, String label) {
    return Expanded(
      child: Column(
        children: [
          CircleAvatar(radius: 22, child: Icon(icon, size: 24), backgroundColor: Colors.red[100]),
          const SizedBox(height: 8),
          Text(
            label, 
            textAlign: TextAlign.center, 
            style: const TextStyle(fontSize: 10, height: 1.1),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildAllServices() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('All Services', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        const SizedBox(height: 16),
        _buildServiceListItem(icon: Icons.settings_outlined, title: 'Regular Service', subtitle: 'Oil change, filter replacement, basic checkup', price: '₹2,000 - ₹5,000'),
        _buildServiceListItem(icon: Icons.wash_outlined, title: 'Car Wash', subtitle: 'Interior & exterior cleaning, polish', price: '₹500 - ₹2,000'),
        _buildServiceListItem(icon: Icons.tire_repair_outlined, title: 'Tyre Service', subtitle: 'Alignment, balancing, puncture repair', price: '₹200 - ₹8,000'),
        _buildServiceListItem(icon: Icons.ac_unit_outlined, title: 'AC Service', subtitle: 'Gas refill, compressor check, cleaning', price: '₹1,500 - ₹4,000'),
        _buildServiceListItem(icon: Icons.battery_charging_full_outlined, title: 'Battery Service', subtitle: 'Testing, replacement, jump start', price: '₹200 - ₹12,000'),
        _buildServiceListItem(icon: Icons.format_paint_outlined, title: 'Denting & Painting', subtitle: 'Scratch removal, panel beating', price: '₹3,000 - ₹50,000'),
      ],
    );
  }

  Widget _buildServiceListItem({required IconData icon, required String title, required String subtitle, required String price}) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: CircleAvatar(child: Icon(icon, size: 24), backgroundColor: Colors.grey[200]),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(subtitle, style: const TextStyle(fontSize: 12), maxLines: 2, overflow: TextOverflow.ellipsis),
            const SizedBox(height: 4),
            Text(price, style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 13)),
          ],
        ),
        trailing: const Icon(Icons.arrow_forward_ios, size: 14),
      ),
    );
  }
}
