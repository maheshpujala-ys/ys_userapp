import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yellowspotuser/core/providers/app_providers.dart';
import 'package:yellowspotuser/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:yellowspotuser/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:yellowspotuser/features/auth/domain/app_user.dart';
import 'package:yellowspotuser/features/auth/domain/entities/auth_credentials.dart';
import 'package:yellowspotuser/features/auth/domain/entities/change_password_request.dart';
import 'package:yellowspotuser/features/auth/domain/entities/register_request.dart';

/// Abstract auth repository — the single contract the application layer
/// (ViewModels) depends on. Swappable for fakes in tests.
abstract class AuthRepository {
  Future<AppUser> login(AuthCredentials credentials);

  Future<void> register(RegisterRequest request);

  Future<void> changePassword(ChangePasswordRequest request);

  static final provider = Provider<AuthRepository>((ref) {
    return AuthRepositoryImpl(
      AuthRemoteDataSource(ref.watch(dioProvider)),
    );
  });
}
