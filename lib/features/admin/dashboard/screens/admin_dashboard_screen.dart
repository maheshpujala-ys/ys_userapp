import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yellowspotuser/core/providers/app_providers.dart';
import 'package:yellowspotuser/features/admin/accounts/screens/create_account_screen.dart';
import 'package:yellowspotuser/features/admin/activity/screens/activity_screen.dart';
import 'package:yellowspotuser/features/admin/data/admin_providers.dart';
import 'package:yellowspotuser/features/admin/entry_exit/screens/entry_exit_screen.dart';
import 'package:yellowspotuser/features/admin/requests/screens/requests_screen.dart';
import 'package:yellowspotuser/features/admin/residents/screens/create_visitor_pass_screen.dart';
import 'package:yellowspotuser/features/admin/residents/screens/residents_list_screen.dart';
import 'package:yellowspotuser/features/admin/security/screens/security_screen.dart';
import 'package:yellowspotuser/features/admin/smart_cards/screens/smart_cards_list_screen.dart';
import 'package:yellowspotuser/features/admin/vehicles/screens/vehicles_list_screen.dart';
import 'package:yellowspotuser/features/auth/application/auth_controller.dart';

class AdminDashboardScreen extends ConsumerStatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  ConsumerState<AdminDashboardScreen> createState() =>
      _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends ConsumerState<AdminDashboardScreen>
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
                    // Isolated consumer — only this subtree rebuilds on websocket ticks.
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
}

class _TopBar extends ConsumerWidget {
  const _TopBar();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text('Residential',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
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
                icon: const Icon(Icons.near_me_outlined,
                    color: Colors.black, size: 18),
                label: const Text('Back to User',
                    style: TextStyle(
                        color: Colors.black,
                        fontSize: 13,
                        fontWeight: FontWeight.bold)),
                onPressed: () =>
                    ref.read(isAdminViewProvider.notifier).state = false,
              ),
            ),
            const SizedBox(width: 4),
            IconButton(
              tooltip: 'Refresh stats',
              icon: const Icon(Icons.refresh),
              onPressed: () =>
                  ref.read(adminControllerProvider.notifier).refresh(),
            ),
            IconButton(
              icon: const Icon(Icons.logout, color: Colors.red),
              onPressed: () =>
                  ref.read(AuthController.provider.notifier).logout(),
            ),
          ],
        ),
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
                    title: 'Residents',
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

  /// Small hint widget rendered to the right of the title (e.g. "tap" badge).
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
  int _mode = 0; // 0 = total, 1 = 4W, 2 = 2W

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
          label: 'Create Account',
          icon: Icons.person_add_alt_outlined,
          color: Colors.purple[100]!,
          builder: (_) => const CreateAccountScreen(),
        ),
        _CircularActionButton(
          label: 'Residents',
          icon: Icons.people_alt_outlined,
          color: Colors.yellow[100]!,
          page: (_) => const ResidentsListScreen(),
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
          label: 'Visitor Pass',
          icon: Icons.qr_code_scanner,
          color: Colors.orange[100]!,
          builder: (_) => const CreateVisitorPassScreen(),
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
    this.builder,
    this.page,
  }) : assert(builder != null || page != null,
            'Provide either a bottom-sheet builder or a full-page builder');

  final String label;
  final IconData icon;
  final Color color;

  /// Bottom-sheet builder. Used by quick "create" forms.
  final WidgetBuilder? builder;

  /// Full-page builder. Used by list screens that need their own scaffold.
  final WidgetBuilder? page;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        if (page != null) {
          Navigator.of(context).push(MaterialPageRoute(builder: page!));
        } else {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            builder: builder!,
          );
        }
      },
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
