import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yellowspotuser/features/auth/domain/entities/register_request.dart';
import 'package:yellowspotuser/features/auth/domain/repositories/auth_repository.dart';

/// ViewModel for the admin "Create Account" / sign-up flow.
/// Independent of [AuthController] so a logged-in admin registering a new user
/// does NOT affect their own session state.
class RegisterController extends StateNotifier<AsyncValue<void>> {
  RegisterController(this._repository) : super(const AsyncValue.data(null));

  final AuthRepository _repository;

  static final provider = StateNotifierProvider.autoDispose<
      RegisterController, AsyncValue<void>>((ref) {
    return RegisterController(ref.watch(AuthRepository.provider));
  });

  Future<bool> submit({
    required String username,
    required String fullname,
    required String email,
    required String role,
  }) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await _repository.register(RegisterRequest(
        username: username,
        fullname: fullname,
        email: email,
        role: role,
      ));
    });
    return !state.hasError;
  }

  void reset() => state = const AsyncValue.data(null);
}
