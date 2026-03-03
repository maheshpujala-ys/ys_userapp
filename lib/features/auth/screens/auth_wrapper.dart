import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yellowspotuser/features/admin/dashboard/screens/admin_dashboard_screen.dart';
import 'package:yellowspotuser/features/auth/application/auth_controller.dart';
import 'package:yellowspotuser/features/auth/domain/app_user.dart';
import 'package:yellowspotuser/features/auth/screens/login_screen.dart';
import 'package:yellowspotuser/features/core/screens/home_screen.dart';

class AuthWrapper extends ConsumerWidget {
  const AuthWrapper({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(AuthController.provider);

    return authState.when(
      data: (user) {
        if (user == null) {
          return const LoginScreen();
        } else if (user.roles.contains(UserRole.admin)) {
          // If the user is an admin, send them directly to the admin dashboard.
          return const AdminDashboardScreen();
        } else {
          return const HomeScreen(); // Regular users go to the home screen.
        }
      },
      loading: () => const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (error, stackTrace) => const LoginScreen(), // On error, always show login.
    );
  }
}
