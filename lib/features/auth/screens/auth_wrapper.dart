import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yellowspotuser/core/providers/app_providers.dart';
import 'package:yellowspotuser/features/admin/dashboard/screens/admin_dashboard_screen.dart';
import 'package:yellowspotuser/features/auth/application/auth_controller.dart';
import 'package:yellowspotuser/features/auth/domain/app_user.dart';
import 'package:yellowspotuser/features/auth/screens/login_screen.dart';
import 'package:yellowspotuser/features/core/screens/home_screen.dart';

/// Decision tuple for routing: avoids rebuilds when unrelated user fields change.
class _AuthRoute {
  const _AuthRoute(this.isLoading, this.isLoggedIn, this.isAdmin);
  final bool isLoading;
  final bool isLoggedIn;
  final bool isAdmin;

  @override
  bool operator ==(Object other) =>
      other is _AuthRoute &&
      isLoading == other.isLoading &&
      isLoggedIn == other.isLoggedIn &&
      isAdmin == other.isAdmin;

  @override
  int get hashCode => Object.hash(isLoading, isLoggedIn, isAdmin);
}

class AuthWrapper extends ConsumerWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final route = ref.watch(AuthController.provider.select((s) => _AuthRoute(
          s.isLoading,
          s.asData?.value != null,
          s.asData?.value?.roles.contains(UserRole.admin) ?? false,
        )));

    if (route.isLoading) return const _AuthSplash();
    if (!route.isLoggedIn) return const LoginScreen();

    if (route.isAdmin) {
      final isAdminView = ref.watch(isAdminViewProvider);
      return isAdminView ? const AdminDashboardScreen() : const HomeScreen();
    }
    return const HomeScreen();
  }
}

class _AuthSplash extends StatelessWidget {
  const _AuthSplash();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: CircularProgressIndicator()),
    );
  }
}
