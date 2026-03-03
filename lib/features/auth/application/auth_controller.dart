import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:yellowspotuser/core/providers/app_providers.dart';
import 'package:yellowspotuser/features/auth/data/auth_repository.dart';
import 'package:yellowspotuser/features/auth/domain/app_user.dart';

class AuthController extends StateNotifier<AsyncValue<AppUser?>> {
  final AuthRepository _authRepository;
  final FlutterSecureStorage _secureStorage;

  AuthController(this._authRepository, this._secureStorage) : super(const AsyncValue.loading()) { // Start in a loading state
    tryAutoLogin();
  }

  static final provider = StateNotifierProvider<AuthController, AsyncValue<AppUser?>>((ref) {
    return AuthController(ref.watch(AuthRepository.provider), ref.watch(secureStorageProvider));
  });

  Future<void> tryAutoLogin() async {
    final token = await _secureStorage.read(key: 'auth_token');
    if (token != null) {
      if (token == 'multi-role-token') {
        state = AsyncValue.data(AppUser(id: 'admin1', email: 'admin@test.com', name: 'Admin User', roles: [UserRole.admin, UserRole.user], token: token));
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
    // We reset the state back to data(null) on success so the UI can react, 
    // or handle success via listener in the screen.
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
    state = const AsyncValue.data(null);
  }
}
