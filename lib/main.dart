import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yellowspotuser/core/services/notifications/notification_service.dart';
import 'package:yellowspotuser/core/theme/app_theme.dart';
import 'package:yellowspotuser/core/theme/theme_controller.dart';
import 'package:yellowspotuser/core/widgets/environment_banner.dart';
import 'package:yellowspotuser/features/auth/screens/auth_wrapper.dart';

void main() async {
  // Ensure native bindings are ready.
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Notification Service
  await NotificationService.init();

  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeControllerProvider);

    return MaterialApp(
      title: 'YellowSpot OS',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeMode,
      builder: (context, child) => EnvironmentBanner(child: child ?? const SizedBox.shrink()),
      home: const AuthWrapper(),
    );
  }
}

