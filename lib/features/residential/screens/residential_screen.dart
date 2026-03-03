import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yellowspotuser/core/providers/app_providers.dart';
import 'package:yellowspotuser/features/admin/activity/screens/activity_screen.dart';
import 'package:yellowspotuser/features/admin/entry_exit/screens/entry_exit_screen.dart';
import 'package:yellowspotuser/features/admin/requests/screens/requests_screen.dart';
import 'package:yellowspotuser/features/admin/security/screens/security_screen.dart';
import 'package:yellowspotuser/features/auth/application/auth_controller.dart';
import 'package:yellowspotuser/features/auth/domain/app_user.dart';
import 'package:yellowspotuser/features/residential/application/residential_controller.dart';
import 'package:yellowspotuser/features/residential/domain/vehicle.dart';

class ResidentialScreen extends ConsumerStatefulWidget {
  const ResidentialScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<ResidentialScreen> createState() => _ResidentialScreenState();
}

class _ResidentialScreenState extends ConsumerState<ResidentialScreen> with TickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isAdminView = ref.watch(isAdminViewProvider);
    final authState = ref.watch(AuthController.provider);

    if (isAdminView && authState.asData?.value?.roles.contains(UserRole.admin) == true) {
      return _buildAdminView(context, ref);
    }

    return _buildUserView(context, ref);
  }

  Scaffold _buildAdminView(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Residential'),
        centerTitle: true,
        actions: [
          TextButton.icon(
            onPressed: () => ref.read(isAdminViewProvider.notifier).state = false,
            icon: const Icon(Icons.arrow_back), 
            label: const Text('Back to User')
          ),
        ],
      ),
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) => [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Column(
                children: [
                  _buildAdminStatsGrid(),
                  const SizedBox(height: 12),
                  _buildAdminActionButtons(),
                  const SizedBox(height: 12),
                ],
              ),
            ),
          ),
          SliverPersistentHeader(
            pinned: true,
            delegate: _SliverAppBarDelegate(
              TabBar(
                controller: _tabController,
                labelColor: Colors.black,
                unselectedLabelColor: Colors.grey,
                indicatorColor: Colors.yellow[700],
                tabs: const [
                  Tab(text: 'Entry/Exit'),
                  Tab(text: 'Requests'),
                  Tab(text: 'Security'),
                  Tab(text: 'Activity'),
                ],
              ),
            ),
          ),
        ],
        body: TabBarView(
          controller: _tabController,
          children: const [
            EntryExitScreen(),
            RequestsScreen(),
            SecurityScreen(),
            ActivityScreen(),
          ],
        ),
      ),
    );
  }

  Widget _buildAdminStatsGrid() {
    return GridView.count(
      shrinkWrap: true,
      crossAxisCount: 2,
      childAspectRatio: 2.8, // Increased for a more compact layout
      crossAxisSpacing: 8,
      mainAxisSpacing: 8,
      physics: const NeverScrollableScrollPhysics(),
      children: [
        _buildStatCard('Residents', '480', Icons.person_outline),
        _buildStatCard('Vehicles', '650', Icons.drive_eta_outlined),
        _buildStatCard('Parking', '78%', Icons.local_parking_outlined),
        _buildStatCard('Pending', '5', Icons.pending_actions_outlined),
      ],
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon) {
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          children: [
            Icon(icon, color: Colors.grey[600], size: 20),
            const SizedBox(width: 8),
            Flexible(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  Text(title, style: const TextStyle(fontSize: 10), overflow: TextOverflow.ellipsis),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAdminActionButtons() {
    return Row(
      children: [
        Expanded(child: _buildAdminActionButton(Icons.person_add_alt_1, 'Resident', Colors.yellow[700]!, Colors.black)),
        const SizedBox(width: 8),
        Expanded(child: _buildAdminActionButton(Icons.drive_eta_outlined, 'Vehicle', Colors.teal[400]!, Colors.white)),
        const SizedBox(width: 8),
        Expanded(child: _buildAdminActionButton(Icons.credit_card_outlined, 'Smart Card', Colors.blue[700]!, Colors.white)),
      ],
    );
  }

  Widget _buildAdminActionButton(IconData icon, String label, Color bgColor, Color textColor) {
    return ElevatedButton(
      onPressed: () {},
      style: ElevatedButton.styleFrom(
        backgroundColor: bgColor,
        foregroundColor: textColor,
        padding: const EdgeInsets.symmetric(vertical: 8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 20),
          const SizedBox(height: 4),
          Text(label, style: const TextStyle(fontSize: 10), overflow: TextOverflow.ellipsis),
        ],
      ),
    );
  }

  Scaffold _buildUserView(BuildContext context, WidgetRef ref) {
    final residentialState = ref.watch(ResidentialController.provider);
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: residentialState.when(
        data: (data) => SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildUserHeader(context, ref, data['society'] ?? '', data['unit'] ?? ''),
              _buildOwnerCard(context, data['ownerName'] ?? ''),
              _buildActionCards(context),
              _buildSmartAccessCard(context),
              _buildEvCharging(context),
              _buildMyVehicles(context, data['vehicles'] as List<Vehicle>? ?? []),
            ],
          ),
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) => Center(child: Text(error.toString())),
      ),
    );
  }
  
  Widget _buildUserHeader(BuildContext context, WidgetRef ref, String society, String unit) {
    final authState = ref.watch(AuthController.provider);
    final user = authState.asData?.value;

    return Container(
      color: Colors.teal[400],
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
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
          if (user != null && user.roles.contains(UserRole.admin))
            TextButton.icon(
              icon: const Icon(Icons.admin_panel_settings_outlined, color: Colors.white,),
              label: const Text('Admin View', style: TextStyle(color: Colors.white)),
              onPressed: () => ref.read(isAdminViewProvider.notifier).state = true,
            ),
        ],
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
            const Icon(Icons.person_outline, size: 40, color: Colors.blueAccent),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [Text(ownerName, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold), overflow: TextOverflow.ellipsis), const Text('Owner')],
              ),
            ),
            const Spacer(),
            OutlinedButton.icon(onPressed: () => _showSnackbar(context, 'Edit Owner Tapped'), icon: const Icon(Icons.edit_outlined), label: const Text('Edit')),
          ],
        ),
      ),
    );
  }

  Widget _buildActionCards(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildActionCard(context, Icons.qr_code_scanner, 'Visitor Pass', 'Generate QR for guests', () {
          _showSnackbar(context, 'Generating Visitor Pass...');
        }),
        _buildActionCard(context, Icons.local_parking_outlined, 'Book Visitor Spot', 'Reserve parking for guests', () => _showSnackbar(context, 'Book Visitor Spot Tapped')),
      ],
    );
  }

  Widget _buildActionCard(BuildContext context, IconData icon, String title, String subtitle, VoidCallback onTap) {
    return SizedBox(
      width: MediaQuery.of(context).size.width * 0.45,
      child: InkWell(
        onTap: onTap,
        child: Card(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Icon(icon, size: 40, color: Colors.yellow[700]),
                const SizedBox(height: 8),
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold), overflow: TextOverflow.ellipsis),
                const SizedBox(height: 4),
                Text(subtitle, textAlign: TextAlign.center, style: TextStyle(color: Colors.grey[600]), overflow: TextOverflow.ellipsis, maxLines: 1),
              ],
            ),
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
          const Text('Smart Access Card', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
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
                        decoration: BoxDecoration(color: Colors.green.withAlpha(51), borderRadius: BorderRadius.circular(10)),
                        child: const Text('Active', style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                  const Divider(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: const [Text('Issued Date'), Text('Card Type')],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: const [Text('1/15/2024', style: TextStyle(fontWeight: FontWeight.bold)), Text('RFID Tag', style: TextStyle(fontWeight: FontWeight.bold))],
                  ),
                  const SizedBox(height: 16),
                  OutlinedButton.icon(
                    onPressed: () => _showSnackbar(context, 'View QR Code Tapped'),
                    icon: const Icon(Icons.qr_code),
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
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('EV Charging', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              TextButton(onPressed: () {}, child: const Text('View All'))
            ],
          ),
          Card(
            margin: const EdgeInsets.only(top: 8),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  const Icon(Icons.ev_station, color: Colors.green, size: 40),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text('EV Charging Available', style: TextStyle(fontWeight: FontWeight.bold)),
                        Text('2 slots available'),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: const [
                      Text('50m away'),
                      Text('2-4 hours'),
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
          const Text('My Vehicles', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: vehicles.length,
            itemBuilder: (context, index) {
              final vehicle = vehicles[index];
              return VehicleListItem(vehicle: vehicle);
            },
          ),
        ],
      ),
    );
  }
}

class VehicleListItem extends StatelessWidget {
  final Vehicle vehicle;

  const VehicleListItem({Key? key, required this.vehicle}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(top: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          children: [
            Text(vehicle.type == VehicleType.fourWheeler ? '4W' : '2W', style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(width: 16),
            Expanded(child: _buildPlate(vehicle.plateType, vehicle.number)),
            const SizedBox(width: 8),
            if (vehicle.plateType == PlateType.ev)
              const Chip(label: Text('EV'), backgroundColor: Colors.green, labelStyle: TextStyle(color: Colors.white)),
            const SizedBox(width: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: vehicle.isActive ? Colors.green.withAlpha(51) : Colors.red.withAlpha(51),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(vehicle.isActive ? 'Active' : 'Inactive', style: TextStyle(color: vehicle.isActive ? Colors.green : Colors.red, fontWeight: FontWeight.bold)),
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
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: plateColor,
        borderRadius: BorderRadius.circular(5),
        border: Border.all(color: Colors.black, width: 1.5),
      ),
      child: Text(number, style: TextStyle(color: textColor, fontWeight: FontWeight.bold, fontSize: 16)),
    );
  }
}

class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  _SliverAppBarDelegate(this._tabBar);

  final TabBar _tabBar;

  @override
  double get minExtent => _tabBar.preferredSize.height;
  @override
  double get maxExtent => _tabBar.preferredSize.height;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: Colors.white,
      child: _tabBar,
    );
  }

  @override
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) {
    return false;
  }
}
