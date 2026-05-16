import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yellowspotuser/features/auth/domain/entities/change_password_request.dart';
import 'package:yellowspotuser/features/auth/domain/repositories/auth_repository.dart';

/// ViewModel for the change-password flow.
/// One-shot action — independent of the auth session so the user is NOT
/// logged out when this is invoked.
class ChangePasswordController extends StateNotifier<AsyncValue<void>> {
  ChangePasswordController(this._repository)
      : super(const AsyncValue.data(null));

  final AuthRepository _repository;

  static final provider = StateNotifierProvider.autoDispose<
      ChangePasswordController, AsyncValue<void>>((ref) {
    return ChangePasswordController(ref.watch(AuthRepository.provider));
  });

  Future<bool> submit(String newPassword) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await _repository.changePassword(
        ChangePasswordRequest(newPassword: newPassword),
      );
    });
    return !state.hasError;
  }
}
