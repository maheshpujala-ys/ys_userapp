import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:yellowspotuser/core/providers/app_providers.dart';

const String kThemeStorageKey = 'app_theme_mode';

/// Centralized Riverpod controller for application-wide theme mode management.
class ThemeController extends StateNotifier<ThemeMode> {
  final FlutterSecureStorage _secureStorage;

  ThemeController(this._secureStorage) : super(ThemeMode.light) {
    _loadThemeMode();
  }

  Future<void> _loadThemeMode() async {
    try {
      final savedTheme = await _secureStorage.read(key: kThemeStorageKey);
      if (savedTheme != null) {
        state = _parseThemeMode(savedTheme);
      } else {
        state = ThemeMode.light; // Default to Light mode
      }
    } catch (_) {
      state = ThemeMode.light; // Safe fallback on error
    }
  }

  ThemeMode get currentThemeMode => state;

  Future<void> setThemeMode(ThemeMode mode) async {
    state = mode;
    try {
      await _secureStorage.write(key: kThemeStorageKey, value: _serializeThemeMode(mode));
    } catch (_) {
      // Ignored for resilience
    }
  }

  static ThemeMode _parseThemeMode(String value) {
    switch (value.toLowerCase()) {
      case 'dark':
        return ThemeMode.dark;
      case 'system':
        return ThemeMode.system;
      case 'light':
      default:
        return ThemeMode.light;
    }
  }

  static String _serializeThemeMode(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.dark:
        return 'dark';
      case ThemeMode.system:
        return 'system';
      case ThemeMode.light:
        return 'light';
    }
  }
}

/// Global provider for the application theme mode.
final themeControllerProvider = StateNotifierProvider<ThemeController, ThemeMode>((ref) {
  final storage = ref.watch(secureStorageProvider);
  return ThemeController(storage);
});
