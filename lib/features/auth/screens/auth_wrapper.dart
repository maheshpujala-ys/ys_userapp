import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yellowspotuser/core/providers/app_providers.dart';
import 'package:yellowspotuser/features/admin/dashboard/screens/residential_admin_dashboard_screen.dart';
import 'package:yellowspotuser/features/auth/application/auth_controller.dart';
import 'package:yellowspotuser/features/auth/domain/app_user.dart';
import 'package:yellowspotuser/features/auth/screens/login_screen.dart';
import 'package:yellowspotuser/features/core/screens/home_screen.dart';
import 'package:yellowspotuser/features/corporate/screens/corporate_admin_dashboard_screen.dart';

/// Decision tuple for routing: avoids rebuilds when unrelated user fields change.
class _AuthRoute {
  const _AuthRoute(
      this.isLoading, this.isLoggedIn, this.isAdmin, this.isCorporate);
  final bool isLoading;
  final bool isLoggedIn;
  final bool isAdmin;
  final bool isCorporate;

  @override
  bool operator ==(Object other) =>
      other is _AuthRoute &&
      isLoading == other.isLoading &&
      isLoggedIn == other.isLoggedIn &&
      isAdmin == other.isAdmin &&
      isCorporate == other.isCorporate;

  @override
  int get hashCode =>
      Object.hash(isLoading, isLoggedIn, isAdmin, isCorporate);
}

class AuthWrapper extends ConsumerWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final route = ref.watch(AuthController.provider.select((s) {
      final user = s.asData?.value;
      return _AuthRoute(
        s.isLoading,
        user != null,
        user?.roles.contains(UserRole.admin) ?? false,
        (user?.solutionType ?? '').toUpperCase() == 'CORPORATE',
      );
    }));

    if (route.isLoading) return const _AuthSplash();
    if (!route.isLoggedIn) return const LoginScreen();

    // Corporate has a single dashboard (no separate user shell). Wins over
    // the admin-view toggle so a corporate admin always lands here.
    if (route.isCorporate) return const CorporateAdminDashboardScreen();

    if (route.isAdmin) {
      final isAdminView = ref.watch(isAdminViewProvider);
      return isAdminView
          ? const ResidentialAdminDashboardScreen()
          : const HomeScreen();
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
