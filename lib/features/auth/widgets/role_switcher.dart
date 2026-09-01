import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yellowspotuser/core/providers/app_providers.dart';
import 'package:yellowspotuser/features/auth/application/auth_controller.dart';
import 'package:yellowspotuser/features/auth/domain/app_user.dart';

class RoleSwitcher extends ConsumerWidget {
  const RoleSwitcher({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(AuthController.provider).asData?.value;
    final activeRole = ref.watch(activeRoleProvider);

    if (user == null || user.roles.length <= 1) {
      return const SizedBox.shrink(); 
    }

    return PopupMenuButton<UserRole>(
      onSelected: (role) {
        ref.read(activeRoleProvider.notifier).state = role;
      },
      itemBuilder: (context) => user.roles.map((role) {
        return PopupMenuItem(
          value: role,
          child: Text('Switch to ${role.name}'),
        );
      }).toList(),
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
