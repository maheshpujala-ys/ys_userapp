import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yellowspotuser/core/providers/app_providers.dart';
import 'package:yellowspotuser/features/admin/dashboard/screens/admin_dashboard_screen.dart';
import 'package:yellowspotuser/features/auth/application/auth_controller.dart';
import 'package:yellowspotuser/features/auth/domain/app_user.dart';
import 'package:yellowspotuser/features/auth/screens/login_screen.dart';
import 'package:yellowspotuser/features/core/screens/home_screen.dart';

class AuthWrapper extends ConsumerWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(AuthController.provider);
    final isAdminView = ref.watch(isAdminViewProvider);

    return authState.when(
      data: (user) {
        if (user == null) {
          return const LoginScreen();
        }
        
        // If the user has an Admin role
        if (user.roles.contains(UserRole.admin)) {
          // If the admin wants to see the admin dashboard
          if (isAdminView) {
            return const AdminDashboardScreen();
          } else {
            // If the admin explicitly toggled to user view
            return const HomeScreen();
          }
        }

        // Regular users always see the HomeScreen
        return const HomeScreen();
      },
      loading: () => const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (error, stackTrace) => const LoginScreen(),
    );
  }
}
