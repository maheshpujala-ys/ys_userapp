import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:yellowspotuser/core/providers/app_providers.dart';
import 'package:yellowspotuser/core/theme/app_colors.dart';
import 'package:yellowspotuser/core/theme/app_text_styles.dart';
import 'package:yellowspotuser/core/widgets/app_card.dart';
import 'package:yellowspotuser/core/widgets/app_status_pill.dart';
import 'package:yellowspotuser/core/widgets/empty_state.dart';
import 'package:yellowspotuser/core/widgets/loading_state.dart';
import 'package:yellowspotuser/features/map/application/map_controller.dart';
import 'package:yellowspotuser/features/parking/application/parking_controller.dart';
import 'package:yellowspotuser/features/parking/screens/book_spot_screen.dart';

enum ParkingFilter {
  all,
  resident,
  visitor,
  ev,
  covered,
  nearLift,
  basement,
}

class ParkingHubScreen extends ConsumerStatefulWidget {
  const ParkingHubScreen({super.key});

  @override
  ConsumerState<ParkingHubScreen> createState() => _ParkingHubScreenState();
}

class _ParkingHubScreenState extends ConsumerState<ParkingHubScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isMapView = true;
  ParkingFilter _selectedFilter = ParkingFilter.all;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final parkingState = ref.watch(ParkingController.filteredProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Smart Parking Hub'),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColors.primary,
          indicatorWeight: 3,
          labelColor: isDark ? AppColors.primary : Colors.black87,
          labelStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
          unselectedLabelColor: isDark ? AppColors.textMutedDark : AppColors.textSecondaryLight,
          tabs: const [
            Tab(text: 'Find & Reserve Spot'),
            Tab(text: 'My Active Bookings (1)'),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(_isMapView ? Icons.view_list_rounded : Icons.map_rounded),
            tooltip: _isMapView ? 'Switch to List' : 'Switch to Map',
            onPressed: () => setState(() => _isMapView = !_isMapView),
          ),
        ],
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Tab 1: Find Parking (Map or List View)
          _buildFindParkingTab(context, parkingState, isDark),

          // Tab 2: My Active Bookings
          _buildActiveBookingsTab(context, isDark),
        ],
      ),
    );
  }

  Widget _buildFindParkingTab(
    BuildContext context,
    AsyncValue<List<Map<String, dynamic>>> parkingState,
    bool isDark,
  ) {
    final mapState = ref.watch(mapControllerProvider);

    return Column(
      children: [
        // Search & Filter Bar
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
          child: TextField(
            onChanged: (value) => ref.read(searchQueryProvider.notifier).state = value,
            decoration: InputDecoration(
              hintText: 'Search society, mall, or tower slot...',
              prefixIcon: const Icon(Icons.search, color: AppColors.textMutedLight),
              suffixIcon: ref.watch(searchQueryProvider).isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear, size: 18),
                      onPressed: () => ref.read(searchQueryProvider.notifier).state = '',
                    )
                  : null,
            ),
          ),
        ),

        // Filter Chips
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: Row(
            children: ParkingFilter.values.map((filter) {
              final isSelected = _selectedFilter == filter;
              String label;
              switch (filter) {
                case ParkingFilter.all:
                  label = 'All Slots';
                  break;
                case ParkingFilter.resident:
                  label = 'Resident Bay';
                  break;
                case ParkingFilter.visitor:
                  label = 'Visitor Bay';
                  break;
                case ParkingFilter.ev:
                  label = '⚡ EV Charging';
                  break;
                case ParkingFilter.covered:
                  label = 'Covered';
                  break;
                case ParkingFilter.nearLift:
                  label = 'Near Lift';
                  break;
                case ParkingFilter.basement:
                  label = 'Basement';
                  break;
              }

              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: FilterChip(
                  label: Text(label),
                  selected: isSelected,
                  onSelected: (val) => setState(() => _selectedFilter = filter),
                  selectedColor: AppColors.primaryContainer,
                  checkmarkColor: Colors.black87,
                  labelStyle: TextStyle(
                    color: isSelected ? Colors.black87 : (isDark ? Colors.white70 : Colors.black87),
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                    fontSize: 12,
                  ),
                ),
              );
            }).toList(),
          ),
        ),
        const SizedBox(height: 6),

        // Content: Map View or List View
        Expanded(
          child: _isMapView
              ? Stack(
                  children: [
                    GoogleMap(
                      initialCameraPosition: const CameraPosition(
                        target: LatLng(17.3850, 78.4867),
                        zoom: 13,
                      ),
                      markers: mapState.asData?.value ?? {},
                    ),
                    // Bottom Sheet with preview cards
                    Positioned(
                      bottom: 16,
                      left: 0,
                      right: 0,
                      child: SizedBox(
                        height: 140,
                        child: parkingState.when(
                          data: (list) => ListView.separated(
                            scrollDirection: Axis.horizontal,
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            itemCount: list.length,
                            separatorBuilder: (_, __) => const SizedBox(width: 12),
                            itemBuilder: (context, index) {
                              final spot = list[index];
                              return _buildParkingCard(context, spot, isDark, width: 290);
                            },
                          ),
                          loading: () => const LoadingStateWidget(),
                          error: (err, _) => const SizedBox.shrink(),
                        ),
                      ),
                    ),
                  ],
                )
              : parkingState.when(
                  data: (list) {
                    if (list.isEmpty) {
                      return const EmptyStateWidget(
                        icon: Icons.local_parking_rounded,
                        title: 'No Parking Spots Found',
                        description: 'Try adjusting your search keyword or selected filter criteria.',
                      );
                    }

                    return ListView.separated(
                      padding: const EdgeInsets.all(16),
                      itemCount: list.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final spot = list[index];
                        return _buildParkingCard(context, spot, isDark);
                      },
                    );
                  },
                  loading: () => const LoadingStateWidget(message: 'Searching available parking slots...'),
                  error: (err, _) => Center(child: Text(err.toString())),
                ),
        ),
      ],
    );
  }

  Widget _buildParkingCard(
    BuildContext context,
    Map<String, dynamic> spot,
    bool isDark, {
    double? width,
  }) {
    final mallName = spot['mallName'] ?? 'Palm Meadows Tower A';
    final address = spot['address'] ?? 'Tower A - Basement 1';
    final available = spot['availableSpots'] ?? 14;
    final total = spot['totalSpots'] ?? 40;

    return AppCard(
      width: width,
      padding: const EdgeInsets.all(14),
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => BookSpotScreen(
              mallName: mallName,
              address: address,
              availableSpots: available,
              totalSpots: total,
            ),
          ),
        );
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  mallName,
                  style: AppTextStyles.titleSmall.copyWith(fontWeight: FontWeight.w800),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              AppStatusPill(
                label: '$available Available',
                type: available > 5 ? StatusType.success : StatusType.warning,
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            address,
            style: AppTextStyles.bodySmall.copyWith(
              color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
            ),
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Row(
                children: [
                  Icon(Icons.ev_station_rounded, size: 16, color: AppColors.success),
                  SizedBox(width: 4),
                  Text('EV Ready', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600)),
                ],
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => BookSpotScreen(
                        mallName: mallName,
                        address: address,
                        availableSpots: available,
                        totalSpots: total,
                      ),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                  minimumSize: const Size(0, 32),
                ),
                child: const Text('Book Spot', style: TextStyle(fontSize: 12)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActiveBookingsTab(BuildContext context, bool isDark) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        AppCard(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  AppStatusPill(label: 'Active Reservation', type: StatusType.success),
                  Text(
                    'Expires in 42m',
                    style: TextStyle(color: AppColors.error, fontWeight: FontWeight.w700, fontSize: 12),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                'Slot B2-45 • Covered EV Bay',
                style: AppTextStyles.titleMedium.copyWith(fontWeight: FontWeight.w800),
              ),
              Text(
                'Palm Meadows • Tower A Basement 2',
                style: AppTextStyles.bodySmall.copyWith(
                  color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                ),
              ),
              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 12),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildBookingDetail('Vehicle', 'TS 09 EQ 4821'),
                  _buildBookingDetail('Start', '10:30 AM'),
                  _buildBookingDetail('End', '08:00 PM'),
                  _buildBookingDetail('Type', 'EV Reserved'),
                ],
              ),
              const SizedBox(height: 18),

              // QR Pass Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => _showDigitalQrPassModal(context),
                  icon: const Icon(Icons.qr_code_2_rounded, size: 18),
                  label: const Text('Show Gate QR Pass'),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildBookingDetail(String label, String value) {
    return Column(
      children: [
        Text(label, style: const TextStyle(fontSize: 10, color: AppColors.textMutedLight)),
        const SizedBox(height: 2),
        Text(value, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
      ],
    );
  }

  void _showDigitalQrPassModal(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Parking Gate Access QR', textAlign: TextAlign.center),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: const Icon(Icons.qr_code_2_rounded, size: 180, color: Colors.black),
            ),
            const SizedBox(height: 14),
            const Text(
              'Slot B2-45 • TS09EQ4821',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 4),
            const Text(
              'Hold this QR code against the gate scanner for barrier entry/exit.',
              style: TextStyle(fontSize: 12, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}
