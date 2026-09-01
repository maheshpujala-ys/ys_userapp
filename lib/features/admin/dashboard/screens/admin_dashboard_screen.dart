import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yellowspotuser/core/providers/app_providers.dart';
import 'package:yellowspotuser/core/theme/app_colors.dart';
import 'package:yellowspotuser/core/theme/app_text_styles.dart';
import 'package:yellowspotuser/core/widgets/app_card.dart';
import 'package:yellowspotuser/features/admin/activity/screens/activity_screen.dart';
import 'package:yellowspotuser/features/admin/dashboard/application/admin_controller.dart';
import 'package:yellowspotuser/features/admin/entry_exit/screens/entry_exit_screen.dart';
import 'package:yellowspotuser/features/admin/requests/screens/requests_screen.dart';
import 'package:yellowspotuser/features/admin/residents/screens/create_visitor_pass_screen.dart';
import 'package:yellowspotuser/features/admin/residents/screens/resident_directory_screen.dart';
import 'package:yellowspotuser/features/admin/security/screens/security_screen.dart';
import 'package:yellowspotuser/features/admin/smart_cards/screens/smart_cards_screen.dart';
import 'package:yellowspotuser/features/admin/vehicles/screens/vehicle_management_screen.dart';
import 'package:yellowspotuser/features/auth/application/auth_controller.dart';

class AdminDashboardScreen extends ConsumerStatefulWidget {
  const AdminDashboardScreen({super.key});

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
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : const Color(0xFFF8FAFC),
      body: SafeArea(
        child: NestedScrollView(
          headerSliverBuilder: (context, innerBoxIsScrolled) => [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildTopBar(context, isDark),
                    const SizedBox(height: 18),
                    adminState.when(
                      data: (data) => _buildStatsGrid(data, isDark),
                      loading: () => _buildStatsGrid(const {'residents': 480, 'vehicles': 650, 'parking': 78, 'pending': 5}, isDark),
                      error: (_, __) => _buildStatsGrid(const {'residents': 480, 'vehicles': 650, 'parking': 78, 'pending': 5}, isDark),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'Admin Actions',
                      style: AppTextStyles.titleMedium.copyWith(
                        fontWeight: FontWeight.w800,
                        color: isDark ? Colors.white : const Color(0xFF0F172A),
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildActionButtons(context, isDark),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
            SliverPersistentHeader(
              pinned: true,
              delegate: _SliverAppBarDelegate(
                Container(
                  color: isDark ? AppColors.surfaceDark : Colors.white,
                  child: TabBar(
                    controller: _tabController,
                    labelColor: AppColors.primaryDark,
                    unselectedLabelColor: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                    indicatorColor: AppColors.primary,
                    indicatorWeight: 3,
                    labelStyle: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13),
                    tabs: const [
                      Tab(text: 'Entry/Exit'),
                      Tab(text: 'Requests'),
                      Tab(text: 'Security'),
                      Tab(text: 'Activity'),
                    ],
                  ),
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

  Widget _buildTopBar(BuildContext context, bool isDark) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Residential Admin',
              style: AppTextStyles.displaySmall.copyWith(
                fontWeight: FontWeight.w900,
                color: isDark ? Colors.white : const Color(0xFF0F172A),
              ),
            ),
            Text(
              'Society Operations & Security Control',
              style: AppTextStyles.bodySmall.copyWith(
                color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
              ),
            ),
          ],
        ),
        Row(
          children: [
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.black,
                elevation: 0,
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              ),
              icon: const Icon(Icons.near_me_outlined, size: 16, color: Colors.black),
              label: const Text(
                'Back to User',
                style: TextStyle(fontWeight: FontWeight.w800, fontSize: 12),
              ),
              onPressed: () {
                ref.read(isAdminViewProvider.notifier).state = false;
              },
            ),
            const SizedBox(width: 8),
            IconButton(
              icon: const Icon(Icons.logout_rounded, color: AppColors.error),
              tooltip: 'Logout',
              onPressed: () {
                ref.read(AuthController.provider.notifier).logout();
              },
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatsGrid(Map<String, dynamic> data, bool isDark) {
    final residents = data['residents']?.toString() ?? '480';
    final vehicles = data['vehicles']?.toString() ?? '650';
    final parking = data['parking']?.toString() ?? '78';
    final pending = data['pending']?.toString() ?? '5';

    return GridView.count(
      shrinkWrap: true,
      crossAxisCount: 2,
      childAspectRatio: 2.1,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      physics: const NeverScrollableScrollPhysics(),
      children: [
        _buildStatCard('Residents', residents, Icons.people_alt_outlined, AppColors.info, isDark),
        _buildStatCard('Vehicles', vehicles, Icons.directions_car_filled_outlined, AppColors.teal, isDark),
        _buildStatCard('Parking Occupancy', '$parking%', Icons.local_parking_rounded, AppColors.primaryDark, isDark),
        _buildStatCard('Pending Approvals', pending, Icons.access_time_filled_rounded, AppColors.warning, isDark),
      ],
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color accentColor, bool isDark) {
    return AppCard(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: accentColor),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: AppTextStyles.titleLarge.copyWith(
              fontWeight: FontWeight.w900,
              color: isDark ? Colors.white : const Color(0xFF0F172A),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context, bool isDark) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 1.9,
      children: [
        _buildActionButton(
          context,
          'Resident Directory',
          Icons.people_alt_rounded,
          const Color(0xFFFEF3C7),
          const Color(0xFF92400E),
          () => Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const ResidentDirectoryScreen()),
          ),
        ),
        _buildActionButton(
          context,
          'Vehicle Registry',
          Icons.directions_car_rounded,
          const Color(0xFFCCFBF1),
          const Color(0xFF115E59),
          () => Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const VehicleManagementScreen()),
          ),
        ),
        _buildActionButton(
          context,
          'Smart Cards & RFID',
          Icons.credit_card_rounded,
          const Color(0xFFE0E7FF),
          const Color(0xFF3730A3),
          () => Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const SmartCardsScreen()),
          ),
        ),
        _buildActionButton(
          context,
          'Issue Visitor Pass',
          Icons.qr_code_scanner_rounded,
          const Color(0xFFFFEDD5),
          const Color(0xFF9A3412),
          () => showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            builder: (context) => const CreateVisitorPassScreen(),
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton(
    BuildContext context,
    String label,
    IconData icon,
    Color bgColor,
    Color iconColor,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(icon, size: 24, color: iconColor),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w800,
                color: iconColor,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  final Widget child;

  _SliverAppBarDelegate(this.child);

  @override
  double get minExtent => 48.0;

  @override
  double get maxExtent => 48.0;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return child;
  }

  @override
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) {
    return false;
  }
}
