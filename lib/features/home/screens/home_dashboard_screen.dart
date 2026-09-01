import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yellowspotuser/features/home/widgets/community_highlights.dart';
import 'package:yellowspotuser/features/home/widgets/home_header.dart';
import 'package:yellowspotuser/features/home/widgets/primary_vehicle_card.dart';
import 'package:yellowspotuser/features/home/widgets/quick_actions_grid.dart';
import 'package:yellowspotuser/features/home/widgets/today_activity_feed.dart';

class HomeDashboardScreen extends ConsumerWidget {
  final Function(int tabIndex)? onNavigateTab;
  final VoidCallback? onInviteGuest;
  final VoidCallback? onAccessPass;
  final VoidCallback? onMyGarage;
  final VoidCallback? onEvCharging;

  const HomeDashboardScreen({
    super.key,
    this.onNavigateTab,
    this.onInviteGuest,
    this.onAccessPass,
    this.onMyGarage,
    this.onEvCharging,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 1. Header (Greeting, Flat/Villa, SOS, Notification badge)
              const HomeHeader(),
              const SizedBox(height: 16),

              // 2. Quick Action Grid (6 actions)
              QuickActionsGrid(
                onNavigateTab: onNavigateTab,
                onInviteGuest: onInviteGuest,
                onAccessPass: onAccessPass,
                onMyGarage: onMyGarage,
                onEvCharging: onEvCharging,
              ),
              const SizedBox(height: 16),

              // 3. Today's Activity Feed
              TodayActivityFeed(onNavigateTab: onNavigateTab),
              const SizedBox(height: 16),

              // 4. Primary Vehicle Spotlight
              PrimaryVehicleCard(
                onManageGarage: onMyGarage,
                onBookService: () => onNavigateTab?.call(2), // Services
                onParkingSlot: () => onNavigateTab?.call(1), // Parking
              ),
              const SizedBox(height: 16),

              // 5. Community Updates & Notices
              CommunityHighlights(
                onExploreCommunity: () => onNavigateTab?.call(3), // Residence
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}
