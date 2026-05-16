import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yellowspotuser/core/providers/app_providers.dart';
import 'package:yellowspotuser/features/auth/domain/app_user.dart';
import 'package:yellowspotuser/features/core/screens/home_screen.dart';

class RoleSelectionScreen extends ConsumerWidget {
  final AppUser user;

  const RoleSelectionScreen({super.key, required this.user});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('Select a Role')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: user.roles.map((role) {
            return ElevatedButton(
              onPressed: () {
                ref.read(activeRoleProvider.notifier).state = role;
                Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => const HomeScreen()));
              },
              child: Text('Continue as ${role.name}'),
            );
          }).toList(),
        ),
      ),
    );
  }
}
