import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yellowspotuser/features/admin/activity/screens/activity_screen.dart';
import 'package:yellowspotuser/features/admin/data/admin_providers.dart';
import 'package:yellowspotuser/features/admin/requests/screens/requests_screen.dart';
import 'package:yellowspotuser/features/admin/residents/screens/residents_list_screen.dart';
import 'package:yellowspotuser/features/admin/security/screens/security_screen.dart';
import 'package:yellowspotuser/features/admin/smart_cards/screens/smart_cards_list_screen.dart';
import 'package:yellowspotuser/features/admin/vehicles/screens/vehicles_list_screen.dart';
import 'package:yellowspotuser/features/auth/widgets/user_avatar_button.dart';
import 'package:yellowspotuser/features/corporate/screens/availability_list_screen.dart';
import 'package:yellowspotuser/features/corporate/screens/corporate_entry_exit_screen.dart';
import 'package:yellowspotuser/features/corporate/screens/datewise_report_screen.dart';

/// Admin dashboard for `solutionType == CORPORATE`. Mirrors the residential
/// layout (2x2 stats + action buttons + 4 tabs) with two differences:
///   - "Residents" → "Employees" labels (same /api/v1/tenants endpoint).
///   - Entry/Exit tab is fed by `/dashboard/parking-logs` (see
///     [CorporateEntryExitScreen]).
class CorporateAdminDashboardScreen extends ConsumerStatefulWidget {
  const CorporateAdminDashboardScreen({super.key});

  @override
  ConsumerState<CorporateAdminDashboardScreen> createState() =>
      _CorporateAdminDashboardScreenState();
}

class _CorporateAdminDashboardScreenState
    extends ConsumerState<CorporateAdminDashboardScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController =
      TabController(length: 4, vsync: this);

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: NestedScrollView(
          headerSliverBuilder: (context, _) => [
            SliverToBoxAdapter(
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const _TopBar(),
                    const SizedBox(height: 16),
                    const _StatsGrid(),
                    const SizedBox(height: 24),
                    const Text('Admin Actions',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 12),
                    const _ActionButtons(),
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
              CorporateEntryExitScreen(),
              RequestsScreen(),
              SecurityScreen(),
              ActivityScreen(),
            ],
          ),
        ),
      ),
    );
  }
}

class _TopBar extends StatelessWidget {
  const _TopBar();

  @override
  Widget build(BuildContext context) {
    return const Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text('Corporate',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
        UserAvatarButton(),
      ],
    );
  }
}

class _StatsGrid extends ConsumerWidget {
  const _StatsGrid();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final adminState = ref.watch(adminControllerProvider);
    return adminState.when(
      data: _buildGrid,
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) => Center(child: Text(error.toString())),
    );
  }

  Widget _buildGrid(Map<String, dynamic> data) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
                child: _StatCard(
                    title: 'Employees',
                    value: '${data['residents']}',
                    icon: Icons.people_outline)),
            const SizedBox(width: 12),
            Expanded(
                child: _VehiclesStatCard(
                  total: (data['vehicles'] as int?) ?? 0,
                  fourWheeler: (data['fourWheelerCount'] as int?) ?? 0,
                  twoWheeler: (data['twoWheelerCount'] as int?) ?? 0,
                )),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
                child: _StatCard(
                    title: 'Parking',
                    value: '${data['parking']}%',
                    icon: Icons.location_on_outlined)),
            const SizedBox(width: 12),
            Expanded(
                child: _StatCard(
                    title: 'Pending',
                    value: '${data['pending']}',
                    icon: Icons.access_time)),
          ],
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    this.onTap,
    this.trailing,
  });

  final String title;
  final String value;
  final IconData icon;
  final VoidCallback? onTap;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final card = Container(
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
              Expanded(
                child: Text(title,
                    style:
                        TextStyle(fontSize: 12, color: Colors.grey[600]),
                    overflow: TextOverflow.ellipsis),
              ),
              ?trailing,
            ],
          ),
          const SizedBox(height: 4),
          Text(value,
              style:
                  const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
        ],
      ),
    );
    if (onTap == null) return card;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: card,
    );
  }
}

/// Tappable Vehicles stat — cycles Total → 4W → 2W → Total → ...
class _VehiclesStatCard extends StatefulWidget {
  const _VehiclesStatCard({
    required this.total,
    required this.fourWheeler,
    required this.twoWheeler,
  });

  final int total;
  final int fourWheeler;
  final int twoWheeler;

  @override
  State<_VehiclesStatCard> createState() => _VehiclesStatCardState();
}

class _VehiclesStatCardState extends State<_VehiclesStatCard> {
  int _mode = 0;

  @override
  Widget build(BuildContext context) {
    late final String title;
    late final int value;
    switch (_mode) {
      case 1:
        title = '4-Wheelers';
        value = widget.fourWheeler;
        break;
      case 2:
        title = '2-Wheelers';
        value = widget.twoWheeler;
        break;
      default:
        title = 'Vehicles';
        value = widget.total;
    }
    return _StatCard(
      title: title,
      value: '$value',
      icon: Icons.directions_car_outlined,
      onTap: () => setState(() => _mode = (_mode + 1) % 3),
      trailing: Icon(Icons.touch_app_outlined,
          size: 12, color: Colors.grey[400]),
    );
  }
}

class _ActionButtons extends StatelessWidget {
  const _ActionButtons();

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 1.8,
      children: [
        _CircularActionButton(
          label: 'Employees',
          icon: Icons.badge_outlined,
          color: Colors.yellow[100]!,
          page: (_) => const ResidentsListScreen(
            entityLabelSingular: 'Employee',
            entityLabelPlural: 'Employees',
          ),
        ),
        _CircularActionButton(
          label: 'Vehicles',
          icon: Icons.directions_car_outlined,
          color: Colors.teal[100]!,
          page: (_) => const VehiclesListScreen(),
        ),
        _CircularActionButton(
          label: 'Smart Cards',
          icon: Icons.credit_card_outlined,
          color: Colors.blue[100]!,
          page: (_) => const SmartCardsListScreen(),
        ),
        _CircularActionButton(
          label: 'Availability List',
          icon: Icons.list_alt_outlined,
          color: Colors.green[100]!,
          page: (_) => const AvailabilityListScreen(),
        ),
        _CircularActionButton(
          label: 'Datewise Report',
          icon: Icons.calendar_month_outlined,
          color: Colors.orange[100]!,
          page: (_) => const DatewiseReportScreen(),
        ),
      ],
    );
  }
}

class _CircularActionButton extends StatelessWidget {
  const _CircularActionButton({
    required this.label,
    required this.icon,
    required this.color,
    required this.page,
  });

  final String label;
  final IconData icon;
  final Color color;
  final WidgetBuilder page;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () =>
          Navigator.of(context).push(MaterialPageRoute(builder: page)),
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
            Text(label,
                textAlign: TextAlign.center,
                style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87)),
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
    return Container(color: Colors.white, child: _tabBar);
  }

  @override
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) => false;
}
