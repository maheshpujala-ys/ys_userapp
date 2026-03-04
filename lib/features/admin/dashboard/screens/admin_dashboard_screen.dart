import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yellowspotuser/core/providers/app_providers.dart';
import 'package:yellowspotuser/features/admin/activity/screens/activity_screen.dart';
import 'package:yellowspotuser/features/admin/dashboard/application/admin_controller.dart';
import 'package:yellowspotuser/features/admin/entry_exit/screens/entry_exit_screen.dart';
import 'package:yellowspotuser/features/admin/requests/screens/requests_screen.dart';
import 'package:yellowspotuser/features/admin/residents/screens/add_resident_screen.dart';
import 'package:yellowspotuser/features/admin/residents/screens/create_visitor_pass_screen.dart';
import 'package:yellowspotuser/features/admin/security/screens/security_screen.dart';
import 'package:yellowspotuser/features/admin/smart_cards/screens/add_smart_card_screen.dart';
import 'package:yellowspotuser/features/admin/vehicles/screens/add_vehicle_screen.dart';
import 'package:yellowspotuser/features/auth/application/auth_controller.dart';
import 'package:yellowspotuser/features/core/screens/home_screen.dart';

class AdminDashboardScreen extends ConsumerStatefulWidget {
  const AdminDashboardScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends ConsumerState<AdminDashboardScreen> with SingleTickerProviderStateMixin {
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
    final adminState = ref.watch(AdminController.provider);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: NestedScrollView(
          headerSliverBuilder: (context, innerBoxIsScrolled) => [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildTopBar(context),
                    const SizedBox(height: 16),
                    adminState.when(
                      data: (data) => _buildStatsGrid(data),
                      loading: () => const Center(child: CircularProgressIndicator()),
                      error: (error, stackTrace) => Center(child: Text(error.toString())),
                    ),
                    const SizedBox(height: 24),
                    const Text('Admin Actions', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 12),
                    _buildActionButtons(context),
                    const SizedBox(height: 16),
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
                  labelStyle: const TextStyle(fontWeight: FontWeight.bold),
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
      ),
    );
  }

  Widget _buildTopBar(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          'Residential', 
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        Row(
          children: [
            Container(
              decoration: BoxDecoration(
                color: Colors.yellow[700],
                borderRadius: BorderRadius.circular(20),
              ),
              child: TextButton.icon(
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                ),
                icon: const Icon(Icons.near_me_outlined, color: Colors.black, size: 18),
                label: const Text('Back to User', style: TextStyle(color: Colors.black, fontSize: 13, fontWeight: FontWeight.bold)),
                onPressed: () {
                  ref.read(isAdminViewProvider.notifier).state = false;
                },
              ),
            ),
            const SizedBox(width: 8),
            IconButton(
              icon: const Icon(Icons.logout, color: Colors.red),
              onPressed: () {
                ref.read(AuthController.provider.notifier).logout();
              },
            ),
          ],
        )
      ],
    );
  }

  Widget _buildStatsGrid(Map<String, dynamic> data) {
    return GridView.count(
      shrinkWrap: true,
      crossAxisCount: 2,
      childAspectRatio: 2.2,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      physics: const NeverScrollableScrollPhysics(),
      children: [
        _buildStatCard('Residents', data['residents'].toString(), Icons.people_outline),
        _buildStatCard('Vehicles', data['vehicles'].toString(), Icons.directions_car_outlined),
        _buildStatCard('Parking', '${data['parking']}%', Icons.location_on_outlined),
        _buildStatCard('Pending', data['pending'].toString(), Icons.access_time),
      ],
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[200]!),
      ),
      padding: const EdgeInsets.all(12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            children: [
              Icon(icon, size: 18, color: Colors.blue[700]),
              const SizedBox(width: 4),
              Text(title, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
            ],
          ),
          const SizedBox(height: 4),
          Text(value, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 1.8,
      children: [
        _buildCircularActionButton(
          context, 
          'Add Resident', 
          Icons.person_add_alt_1_outlined, 
          Colors.yellow[100]!,
          () => showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            builder: (context) => const AddResidentScreen(),
          ),
        ),
        _buildCircularActionButton(
          context, 
          'Add Vehicle', 
          Icons.local_shipping_outlined, 
          Colors.teal[100]!,
          () => showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            builder: (context) => const AddVehicleScreen(),
          ),
        ),
        _buildCircularActionButton(
          context, 
          'Add Smart Card', 
          Icons.credit_card_outlined, 
          Colors.blue[100]!,
          () => showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            builder: (context) => const AddSmartCardScreen(),
          ),
        ),
        _buildCircularActionButton(
          context, 
          'Visitor Pass', 
          Icons.qr_code_scanner, 
          Colors.orange[100]!,
          () => showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            builder: (context) => const CreateVisitorPassScreen(),
          ),
        ),
      ],
    );
  }

  Widget _buildCircularActionButton(BuildContext context, String label, IconData icon, Color color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 28, color: Colors.black87),
            const SizedBox(height: 8),
            Text(
              label, 
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 13, 
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          ],
        ),
      ),
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
