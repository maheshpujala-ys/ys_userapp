import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:yellowspotuser/core/providers/app_providers.dart';
import 'package:yellowspotuser/core/services/network/dio_interceptor.dart';
import 'package:yellowspotuser/features/auth/domain/app_user.dart';
import 'package:yellowspotuser/features/auth/domain/entities/auth_credentials.dart';
import 'package:yellowspotuser/features/auth/domain/repositories/auth_repository.dart';

const String _kSessionKey = 'auth_session';

/// ViewModel for the authenticated session.
///
/// Owns the persisted session (token + cached user snapshot) and the
/// "currently signed-in" stream consumed by AuthWrapper.
class AuthController extends StateNotifier<AsyncValue<AppUser?>> {
  AuthController(
    this._repository,
    this._secureStorage,
    this._interceptor,
    this._ref,
  ) : super(const AsyncValue.loading()) {
    _restoreSession();
  }

  final AuthRepository _repository;
  final FlutterSecureStorage _secureStorage;
  final DioInterceptor _interceptor;
  final Ref _ref;

  static final provider =
      StateNotifierProvider<AuthController, AsyncValue<AppUser?>>((ref) {
    return AuthController(
      ref.watch(AuthRepository.provider),
      ref.watch(secureStorageProvider),
      ref.watch(dioInterceptorProvider),
      ref,
    );
  });

  Future<void> _restoreSession() async {
    final raw = await _secureStorage.read(key: _kSessionKey);
    if (raw == null || raw.isEmpty) {
      if (mounted) state = const AsyncValue.data(null);
      return;
    }
    try {
      final json = jsonDecode(raw) as Map<String, dynamic>;
      final user = AppUser(
        id: json['id'] as String?,
        username: json['username'] as String,
        email: json['email'] as String?,
        name: json['name'] as String? ?? '',
        roles: (json['roles'] as List<dynamic>)
            .map((e) => UserRoleX.fromApi(e as String))
            .toList(growable: false),
        solutionType: json['solutionType'] as String?,
        token: json['token'] as String,
      );
      _interceptor.setToken(user.token);
      if (user.roles.contains(UserRole.admin)) {
        _ref.read(isAdminViewProvider.notifier).state = true;
      }
      if (mounted) state = AsyncValue.data(user);
    } catch (_) {
      await _secureStorage.delete(key: _kSessionKey);
      if (mounted) state = const AsyncValue.data(null);
    }
  }

  Future<void> login({
    required String username,
    required String password,
  }) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final user = await _repository.login(AuthCredentials(
        username: username,
        password: password,
      ));
      await _persistSession(user);
      _interceptor.setToken(user.token);
      if (user.roles.contains(UserRole.admin)) {
        _ref.read(isAdminViewProvider.notifier).state = true;
      }
      return user;
    });
  }

  Future<void> updateUser({String? name, String? email}) async {
    final current = state.value;
    if (current == null) return;
    final updated = current.copyWith(name: name, email: email);
    await _persistSession(updated);
    if (mounted) state = AsyncValue.data(updated);
  }

  Future<void> logout() async {
    await _secureStorage.delete(key: _kSessionKey);
    _interceptor.setToken(null);
    _ref.read(isAdminViewProvider.notifier).state = false;
    if (mounted) state = const AsyncValue.data(null);
  }

  Future<void> _persistSession(AppUser user) async {
    final json = jsonEncode({
      'id': user.id,
      'username': user.username,
      'email': user.email,
      'name': user.name,
      'roles': user.roles.map((r) => r.apiValue).toList(),
      'solutionType': user.solutionType,
      'token': user.token,
    });
    await _secureStorage.write(key: _kSessionKey, value: json);
  }
}
