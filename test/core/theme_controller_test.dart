import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:yellowspotuser/core/theme/theme_controller.dart';

class FakeSecureStorage extends Fake implements FlutterSecureStorage {
  final Map<String, String> _storage = {};

  @override
  Future<String?> read({
    required String key,
    IOSOptions? iOptions,
    AndroidOptions? aOptions,
    LinuxOptions? lOptions,
    WebOptions? webOptions,
    MacOsOptions? mOptions,
    WindowsOptions? wOptions,
  }) async {
    return _storage[key];
  }

  @override
  Future<void> write({
    required String key,
    required String? value,
    IOSOptions? iOptions,
    AndroidOptions? aOptions,
    LinuxOptions? lOptions,
    WebOptions? webOptions,
    MacOsOptions? mOptions,
    WindowsOptions? wOptions,
  }) async {
    if (value != null) {
      _storage[key] = value;
    } else {
      _storage.remove(key);
    }
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('ThemeController Unit Tests', () {
    late FakeSecureStorage fakeStorage;

    setUp(() {
      fakeStorage = FakeSecureStorage();
    });

    test('1. Default theme is Light mode when no storage exists', () async {
      final controller = ThemeController(fakeStorage);
      // Allow async _loadThemeMode to complete
      await Future.delayed(const Duration(milliseconds: 10));

      expect(controller.currentThemeMode, equals(ThemeMode.light));
    });

    test('2. Select Dark theme updates state and writes "dark" to storage', () async {
      final controller = ThemeController(fakeStorage);
      await Future.delayed(const Duration(milliseconds: 10));

      await controller.setThemeMode(ThemeMode.dark);

      expect(controller.currentThemeMode, equals(ThemeMode.dark));
      final storedValue = await fakeStorage.read(key: kThemeStorageKey);
      expect(storedValue, equals('dark'));
    });

    test('3. Select Light theme updates state and writes "light" to storage', () async {
      final controller = ThemeController(fakeStorage);
      await Future.delayed(const Duration(milliseconds: 10));

      await controller.setThemeMode(ThemeMode.dark);
      await controller.setThemeMode(ThemeMode.light);

      expect(controller.currentThemeMode, equals(ThemeMode.light));
      final storedValue = await fakeStorage.read(key: kThemeStorageKey);
      expect(storedValue, equals('light'));
    });

    test('4. Select System theme updates state and writes "system" to storage', () async {
      final controller = ThemeController(fakeStorage);
      await Future.delayed(const Duration(milliseconds: 10));

      await controller.setThemeMode(ThemeMode.system);

      expect(controller.currentThemeMode, equals(ThemeMode.system));
      final storedValue = await fakeStorage.read(key: kThemeStorageKey);
      expect(storedValue, equals('system'));
    });

    test('5. Preference persists across controller re-instantiation', () async {
      await fakeStorage.write(key: kThemeStorageKey, value: 'dark');

      final controller = ThemeController(fakeStorage);
      await Future.delayed(const Duration(milliseconds: 10));

      expect(controller.currentThemeMode, equals(ThemeMode.dark));
    });

    test('6. Invalid stored value safely falls back to Light mode', () async {
      await fakeStorage.write(key: kThemeStorageKey, value: 'invalid_theme_value');

      final controller = ThemeController(fakeStorage);
      await Future.delayed(const Duration(milliseconds: 10));

      expect(controller.currentThemeMode, equals(ThemeMode.light));
    });

    test('7. Theme changes immediately in memory without requiring app reload', () async {
      final controller = ThemeController(fakeStorage);
      await Future.delayed(const Duration(milliseconds: 10));

      expect(controller.currentThemeMode, equals(ThemeMode.light));

      await controller.setThemeMode(ThemeMode.dark);
      expect(controller.currentThemeMode, equals(ThemeMode.dark));

      await controller.setThemeMode(ThemeMode.system);
      expect(controller.currentThemeMode, equals(ThemeMode.system));

      await controller.setThemeMode(ThemeMode.light);
      expect(controller.currentThemeMode, equals(ThemeMode.light));
    });
  });
}
