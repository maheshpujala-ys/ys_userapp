import 'package:flutter/material.dart';
import 'package:yellowspotuser/core/theme/app_colors.dart';
import 'package:yellowspotuser/core/theme/app_text_styles.dart';

class QuickActionItem {
  final String title;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const QuickActionItem({
    required this.title,
    required this.icon,
    required this.color,
    required this.onTap,
  });
}

class QuickActionsGrid extends StatelessWidget {
  final Function(int tabIndex)? onNavigateTab;
  final VoidCallback? onInviteGuest;
  final VoidCallback? onAccessPass;
  final VoidCallback? onMyGarage;
  final VoidCallback? onEvCharging;
  final VoidCallback? onSos;

  const QuickActionsGrid({
    super.key,
    this.onNavigateTab,
    this.onInviteGuest,
    this.onAccessPass,
    this.onMyGarage,
    this.onEvCharging,
    this.onSos,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final List<QuickActionItem> actions = [
      QuickActionItem(
        title: 'Find Parking',
        icon: Icons.local_parking_rounded,
        color: AppColors.primaryDark,
        onTap: () => onNavigateTab?.call(1), // Parking tab
      ),
      QuickActionItem(
        title: 'Invite Guest',
        icon: Icons.person_add_alt_1_rounded,
        color: AppColors.info,
        onTap: onInviteGuest ?? () => onNavigateTab?.call(3), // Residence tab
      ),
      QuickActionItem(
        title: 'Access Pass',
        icon: Icons.qr_code_2_rounded,
        color: AppColors.teal,
        onTap: onAccessPass ?? () => onNavigateTab?.call(3),
      ),
      QuickActionItem(
        title: 'My Garage',
        icon: Icons.directions_car_filled_rounded,
        color: AppColors.purple,
        onTap: onMyGarage ?? () => onNavigateTab?.call(3),
      ),
      QuickActionItem(
        title: 'EV Charging',
        icon: Icons.ev_station_rounded,
        color: AppColors.success,
        onTap: onEvCharging ?? () => onNavigateTab?.call(3),
      ),
      QuickActionItem(
        title: 'Vehicle Help',
        icon: Icons.car_repair_rounded,
        color: Colors.deepOrange,
        onTap: () => onNavigateTab?.call(2), // Services tab
      ),
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: actions.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
          childAspectRatio: 1.05,
        ),
        itemBuilder: (context, index) {
          final action = actions[index];

          return Material(
            color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
            borderRadius: BorderRadius.circular(16),
            child: InkWell(
              onTap: action.onTap,
              borderRadius: BorderRadius.circular(16),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isDark ? AppColors.borderDark : AppColors.borderLight,
                    width: 1,
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: action.color.withValues(alpha: 0.12),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(action.icon, size: 22, color: action.color),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      action.title,
                      style: AppTextStyles.labelSmall.copyWith(
                        fontWeight: FontWeight.w700,
                        fontSize: 11,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
