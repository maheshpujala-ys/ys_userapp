import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yellowspotuser/core/providers/app_providers.dart';
import 'package:yellowspotuser/features/auth/application/auth_controller.dart';
import 'package:yellowspotuser/features/auth/domain/app_user.dart';

class RoleSwitcher extends ConsumerWidget {
  const RoleSwitcher({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final roles = ref.watch(AuthController.provider
        .select((s) => s.asData?.value?.roles ?? const <UserRole>[]));
    if (roles.length <= 1) return const SizedBox.shrink();

    final activeRole = ref.watch(activeRoleProvider);

    return PopupMenuButton<UserRole>(
      onSelected: (role) =>
          ref.read(activeRoleProvider.notifier).state = role,
      itemBuilder: (context) => [
        for (final role in roles)
          PopupMenuItem(value: role, child: Text('Switch to ${role.name}')),
      ],
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Chip(
          label: Text('Current Role: ${activeRole?.name ?? 'None'}'),
          avatar: const Icon(Icons.swap_horiz),
        ),
      ),
    );
  }
}
