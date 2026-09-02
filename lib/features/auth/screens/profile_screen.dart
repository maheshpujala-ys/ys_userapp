import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yellowspotuser/core/theme/app_colors.dart';
import 'package:yellowspotuser/core/theme/app_text_styles.dart';
import 'package:yellowspotuser/core/theme/theme_controller.dart';
import 'package:yellowspotuser/core/widgets/app_card.dart';
import 'package:yellowspotuser/core/widgets/app_status_pill.dart';
import 'package:yellowspotuser/features/ai_assistant/screens/ai_assistant_screen.dart';
import 'package:yellowspotuser/features/auth/application/auth_controller.dart';
import 'package:yellowspotuser/features/auth/domain/app_user.dart';
import 'package:yellowspotuser/features/auth/screens/edit_profile_screen.dart';
import 'package:yellowspotuser/features/auth/widgets/role_switcher.dart';
import 'package:yellowspotuser/features/notifications/screens/notification_center_screen.dart';
import 'package:yellowspotuser/features/residence/access_pass/screens/digital_access_pass_screen.dart';
import 'package:yellowspotuser/features/wallet/screens/wallet_screen.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(AuthController.provider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Profile & Settings'),
      ),
      body: userAsync.when(
        data: (user) {
          final userName = user?.name.isNotEmpty == true ? user!.name : 'Resident User';
          final userEmail = user?.email ?? 'resident@yellowspot.io';

          return SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
            physics: const BouncingScrollPhysics(),
            child: Column(
              children: [
                // 1. Profile Header Card
                AppCard(
                  padding: const EdgeInsets.all(18),
                  child: Row(
                    children: [
                      Container(
                        width: 60,
                        height: 60,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(
                            colors: [AppColors.primaryLight, AppColors.primaryDark],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                        ),
                        child: Center(
                          child: Text(
                            userName.isNotEmpty ? userName[0].toUpperCase() : 'Y',
                            style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w900, color: Colors.black87),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              userName,
                              style: AppTextStyles.titleMedium.copyWith(fontWeight: FontWeight.w800),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              userEmail,
                              style: AppTextStyles.bodySmall.copyWith(
                                color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 6),
                            const Row(
                              children: [
                                AppStatusPill(label: 'Verified Owner', type: StatusType.success),
                                SizedBox(width: 6),
                                Text(
                                  '• Tower A 1204',
                                  style: TextStyle(fontSize: 11, color: AppColors.textMutedLight, fontWeight: FontWeight.w600),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(builder: (_) => const EditProfileScreen()),
                          );
                        },
                        icon: const Icon(Icons.edit_outlined),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // 2. Quick Services Shortcut Row (Wallet, Access Pass, AI Assistant)
                Row(
                  children: [
                    Expanded(
                      child: AppCard(
                        padding: const EdgeInsets.all(12),
                        onTap: () => Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => const WalletScreen()),
                        ),
                        child: const Column(
                          children: [
                            Icon(Icons.account_balance_wallet_rounded, color: AppColors.primaryDark, size: 24),
                            SizedBox(height: 6),
                            Text('Wallet', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                            Text('₹4,850', style: TextStyle(fontSize: 11, color: AppColors.successDark, fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: AppCard(
                        padding: const EdgeInsets.all(12),
                        onTap: () => Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => const DigitalAccessPassScreen()),
                        ),
                        child: const Column(
                          children: [
                            Icon(Icons.qr_code_2_rounded, color: AppColors.teal, size: 24),
                            SizedBox(height: 6),
                            Text('Smart Pass', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                            Text('Active RFID', style: TextStyle(fontSize: 11, color: AppColors.textMutedLight)),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: AppCard(
                        padding: const EdgeInsets.all(12),
                        onTap: () => Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => const AiAssistantScreen()),
                        ),
                        child: const Column(
                          children: [
                            Icon(Icons.auto_awesome_rounded, color: AppColors.purple, size: 24),
                            SizedBox(height: 6),
                            Text('AI Assistant', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                            Text('Smart Voice', style: TextStyle(fontSize: 11, color: AppColors.textMutedLight)),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // 3. Admin Switcher (If user has Admin role)
                if (user != null && user.roles.contains(UserRole.admin)) ...[
                  AppCard(
                    padding: const EdgeInsets.all(14),
                    color: isDark ? AppColors.surfaceElevatedDark : AppColors.primaryContainer,
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.admin_panel_settings_rounded, color: AppColors.primaryDark),
                            SizedBox(width: 10),
                            Text(
                              'Admin Mode Switcher',
                              style: TextStyle(fontWeight: FontWeight.w800),
                            ),
                          ],
                        ),
                        RoleSwitcher(),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                ],

                // 4. Appearance & Theme Selection
                AppCard(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.palette_outlined, color: AppColors.primaryDark, size: 22),
                          const SizedBox(width: 10),
                          Text(
                            'Appearance',
                            style: AppTextStyles.titleSmall.copyWith(fontWeight: FontWeight.w800),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      _buildThemeOption(
                        context: context,
                        ref: ref,
                        title: 'Light Theme',
                        subtitle: 'Clean white surfaces with yellow accents (Recommended)',
                        icon: Icons.light_mode_rounded,
                        mode: ThemeMode.light,
                        currentMode: ref.watch(themeControllerProvider),
                      ),
                      const Divider(height: 16),
                      _buildThemeOption(
                        context: context,
                        ref: ref,
                        title: 'Dark Theme',
                        subtitle: 'Deep dark surfaces for low-light environments',
                        icon: Icons.dark_mode_rounded,
                        mode: ThemeMode.dark,
                        currentMode: ref.watch(themeControllerProvider),
                      ),
                      const Divider(height: 16),
                      _buildThemeOption(
                        context: context,
                        ref: ref,
                        title: 'System Default',
                        subtitle: 'Automatically follow device operating system setting',
                        icon: Icons.settings_brightness_rounded,
                        mode: ThemeMode.system,
                        currentMode: ref.watch(themeControllerProvider),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // 5. App Preferences & Settings
                AppCard(
                  padding: EdgeInsets.zero,
                  child: Column(
                    children: [
                      _buildMenuItem(
                        icon: Icons.notifications_none_rounded,
                        title: 'Notification Center',
                        onTap: () => Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => const NotificationCenterScreen()),
                        ),
                      ),
                      const Divider(height: 1),
                      _buildMenuItem(
                        icon: Icons.lock_outline_rounded,
                        title: 'Security & App PIN',
                        onTap: () {},
                      ),
                      const Divider(height: 1),
                      _buildMenuItem(
                        icon: Icons.help_outline_rounded,
                        title: 'Help & 24/7 Support Desk',
                        onTap: () {},
                      ),
                      const Divider(height: 1),
                      _buildMenuItem(
                        icon: Icons.info_outline_rounded,
                        title: 'About YellowSpot OS',
                        subtitle: 'v2.0.0 (Smart Residential OS)',
                        onTap: () {},
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // 5. Logout Button
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () => ref.read(AuthController.provider.notifier).logout(),
                    icon: const Icon(Icons.logout_rounded, color: AppColors.error, size: 18),
                    label: const Text('Log Out', style: TextStyle(color: AppColors.error, fontWeight: FontWeight.bold)),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: AppColors.error),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text(error.toString())),
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    String? subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: AppColors.primaryDark, size: 22),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
      subtitle: subtitle != null ? Text(subtitle, style: const TextStyle(fontSize: 11, color: AppColors.textMutedLight)) : null,
      trailing: const Icon(Icons.chevron_right, size: 18, color: AppColors.textMutedLight),
      onTap: onTap,
    );
  }

  Widget _buildThemeOption({
    required BuildContext context,
    required WidgetRef ref,
    required String title,
    required String subtitle,
    required IconData icon,
    required ThemeMode mode,
    required ThemeMode currentMode,
  }) {
    final isSelected = mode == currentMode;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return InkWell(
      onTap: () => ref.read(themeControllerProvider.notifier).setThemeMode(mode),
      borderRadius: BorderRadius.circular(10),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isSelected
                    ? (isDark ? AppColors.primary.withValues(alpha: 0.2) : AppColors.primaryContainer)
                    : (isDark ? AppColors.surfaceElevatedDark : AppColors.dividerLight),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: isSelected ? AppColors.primaryDark : AppColors.textSecondaryLight,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                      fontSize: 14,
                      color: isSelected
                          ? (isDark ? AppColors.primary : AppColors.textPrimaryLight)
                          : (isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 11,
                      color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              const Icon(
                Icons.check_circle_rounded,
                color: AppColors.primaryDark,
                size: 22,
              )
            else
              Icon(
                Icons.circle_outlined,
                color: isDark ? AppColors.borderDark : AppColors.borderLight,
                size: 22,
              ),
          ],
        ),
      ),
    );
  }
}
