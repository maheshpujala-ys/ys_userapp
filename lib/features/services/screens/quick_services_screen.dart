import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yellowspotuser/features/services/application/services_controller.dart';

class QuickServicesScreen extends ConsumerWidget {
  const QuickServicesScreen({super.key});

  void _showSnackbar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final servicesState = ref.watch(ServicesController.provider);
    final size = MediaQuery.of(context).size;
    final gridAspectRatio = size.width < 360 ? 0.7 : 0.85;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text('Quick Services', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: servicesState.when(
        data: (data) => SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildFeaturedServices(context, data['featuredServices'] ?? []),
              const SizedBox(height: 24),
              _buildOtherServices(context, gridAspectRatio),
              const SizedBox(height: 24),
              _buildRecentTransactions(context, data['recentTransactions'] ?? []),
              const SizedBox(height: 24),
              _buildEmergencyServices(context, gridAspectRatio),
            ],
          ),
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) => Center(child: Text(error.toString())),
      ),
    );
  }

  Widget _buildFeaturedServices(BuildContext context, List<Map<String, dynamic>> services) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: services.map((service) {
        return _buildFeaturedServiceCard(
          context,
          service['title'],
          service['subtitle'],
          () => _showSnackbar(context, '${service['title']} Tapped'),
          icon: service['title'] == 'EV Charging' ? Icons.ev_station : Icons.receipt_long,
        );
      }).toList(),
    );
  }

  Widget _buildFeaturedServiceCard(BuildContext context, String title, String subtitle, VoidCallback onTap, {IconData? icon}) {
    return Expanded(
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        elevation: 2,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(15),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 8.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (icon != null)
                  CircleAvatar(
                    radius: 25,
                    backgroundColor: Colors.lightBlue[50],
                    child: Icon(icon, size: 28, color: Colors.blue[800]),
                  ),
                const SizedBox(height: 10),
                Text(
                  title, 
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14), 
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle, 
                  style: TextStyle(color: Colors.grey[600], fontSize: 11), 
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildOtherServices(BuildContext context, double aspectRatio) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      elevation: 2,
      child: ExpansionTile(
        title: const Text('Other Services', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        tilePadding: const EdgeInsets.symmetric(horizontal: 16),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(8, 0, 8, 16),
            child: GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 4,
              crossAxisSpacing: 4,
              mainAxisSpacing: 12,
              childAspectRatio: aspectRatio,
              children: [
                _buildOtherServiceIcon(Icons.phone_android, 'Mobile Recharge', Colors.blue),
                _buildOtherServiceIcon(Icons.tv, 'DTH Recharge', Colors.purple),
                _buildOtherServiceIcon(Icons.lightbulb_outline, 'Electricity Bill', Colors.amber),
                _buildOtherServiceIcon(Icons.water_drop_outlined, 'Water Bill', Colors.lightBlue),
                _buildOtherServiceIcon(Icons.local_fire_department_outlined, 'Gas Bill', Colors.deepOrange),
                _buildOtherServiceIcon(Icons.credit_card, 'Credit Card', Colors.indigo),
                _buildOtherServiceIcon(Icons.shield_outlined, 'Insurance', Colors.teal),
                _buildOtherServiceIcon(Icons.wifi, 'Broadband', Colors.cyan),
                _buildOtherServiceIcon(Icons.tram, 'Metro Card', Colors.pink),
                _buildOtherServiceIcon(Icons.phone_in_talk_outlined, 'Landline', Colors.blueGrey),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildOtherServiceIcon(IconData icon, String label, Color color) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        CircleAvatar(
          radius: 22, 
          backgroundColor: color.withOpacity(0.1),
          child: Icon(icon, size: 22, color: color),
        ),
        const SizedBox(height: 6),
        Flexible(
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 10, height: 1.1, fontWeight: FontWeight.w500),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildRecentTransactions(BuildContext context, List<Map<String, dynamic>> transactions) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Recent Transactions', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: transactions.length,
          separatorBuilder: (context, index) => const SizedBox(height: 8),
          itemBuilder: (context, index) {
            final transaction = transactions[index];
            return _buildTransactionItem(transaction['title'], transaction['subtitle'], transaction['amount'], transaction['success']);
          },
        ),
      ],
    );
  }

  Widget _buildTransactionItem(String title, String subtitle, String amount, bool success) {
    return Card(
      margin: EdgeInsets.zero,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey[200]!),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                  const SizedBox(height: 2),
                  Text(subtitle, style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(amount, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                const SizedBox(height: 2),
                Text(
                  success ? 'Success' : 'Failed', 
                  style: TextStyle(
                    color: success ? Colors.green : Colors.red, 
                    fontWeight: FontWeight.bold, 
                    fontSize: 11,
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget _buildEmergencyServices(BuildContext context, double aspectRatio) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Emergency Services', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.red)),
        const SizedBox(height: 16),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 4,
          crossAxisSpacing: 8,
          mainAxisSpacing: 8,
          childAspectRatio: 0.8,
          children: [
            _buildEmergencyServiceIcon(Icons.car_repair, 'Emergency Tow', '1800-TOW', Colors.yellow[50]!),
            _buildEmergencyServiceIcon(Icons.monitor_heart, 'Ambulance', '108', Colors.red[50]!),
            _buildEmergencyServiceIcon(Icons.local_police_outlined, 'Police', '100', Colors.blue[50]!),
            _buildEmergencyServiceIcon(Icons.local_fire_department_outlined, 'Fire', '101', Colors.orange[50]!),
          ],
        ),
      ],
    );
  }

  Widget _buildEmergencyServiceIcon(IconData icon, String label, String subtitle, Color color) {
    return Card(
      margin: EdgeInsets.zero,
      elevation: 1,
      shadowColor: Colors.black12,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: color,
      child: InkWell(
        onTap: () {},
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 22, color: Colors.black87),
              const SizedBox(height: 6),
              Flexible(
                child: Text(
                  label, 
                  textAlign: TextAlign.center, 
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 9), 
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle, 
                style: const TextStyle(fontSize: 8, color: Colors.black54),
                maxLines: 1,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
