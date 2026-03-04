import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:yellowspotuser/core/providers/app_providers.dart';
import 'package:yellowspotuser/features/auth/data/auth_repository.dart';
import 'package:yellowspotuser/features/auth/domain/app_user.dart';

class AuthController extends StateNotifier<AsyncValue<AppUser?>> {
  final AuthRepository _authRepository;
  final FlutterSecureStorage _secureStorage;
  final StateNotifierProviderRef _ref;

  AuthController(this._authRepository, this._secureStorage, this._ref) : super(const AsyncValue.loading()) {
    tryAutoLogin();
  }

  static final provider = StateNotifierProvider<AuthController, AsyncValue<AppUser?>>((ref) {
    return AuthController(ref.watch(AuthRepository.provider), ref.watch(secureStorageProvider), ref);
  });

  Future<void> tryAutoLogin() async {
    final token = await _secureStorage.read(key: 'auth_token');
    if (token != null) {
      if (token == 'multi-role-token') {
        final user = AppUser(id: 'admin1', email: 'admin@test.com', name: 'Admin User', roles: [UserRole.admin, UserRole.user], token: token);
        _ref.read(isAdminViewProvider.notifier).state = true; // Set admin view by default
        state = AsyncValue.data(user);
      } else if (token == 'user-token' || token == 'new-user-token') {
        state = AsyncValue.data(AppUser(id: 'user1', email: 'user@test.com', name: 'Test User', roles: [UserRole.user], token: token));
      } else {
        state = const AsyncValue.data(null);
      }
    } else {
      state = const AsyncValue.data(null);
    }
  }

  Future<void> login(String email, String password) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final user = await _authRepository.login(email, password);
      await _secureStorage.write(key: 'auth_token', value: user.token);
      
      if (user.roles.contains(UserRole.admin)) {
        _ref.read(isAdminViewProvider.notifier).state = true; // Set admin view on login
      }
      
      return user;
    });
  }

  Future<void> signUp({required String name, required String email, required String password}) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final user = await _authRepository.signUp(name: name, email: email, password: password);
      await _secureStorage.write(key: 'auth_token', value: user.token);
      return user;
    });
  }

  Future<void> forgotPassword(String email) async {
    state = const AsyncValue.loading();
    final result = await AsyncValue.guard(() => _authRepository.forgotPassword(email));
    state = result.when(
      data: (_) => const AsyncValue.data(null),
      error: (e, st) => AsyncValue.error(e, st),
      loading: () => const AsyncValue.loading(),
    );
  }

  Future<void> updateUser(String name, String email) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final user = state.value!;
      final updatedUser = await _authRepository.updateUser(user.id, name, email);
      return updatedUser;
    });
  }

  Future<void> logout() async {
    state = const AsyncValue.loading();
    await _secureStorage.delete(key: 'auth_token');
    _ref.read(isAdminViewProvider.notifier).state = false; // Reset view on logout
    state = const AsyncValue.data(null);
  }
}
