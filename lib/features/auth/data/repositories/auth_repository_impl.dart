import 'package:yellowspotuser/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:yellowspotuser/features/auth/domain/app_user.dart';
import 'package:yellowspotuser/features/auth/domain/entities/auth_credentials.dart';
import 'package:yellowspotuser/features/auth/domain/entities/change_password_request.dart';
import 'package:yellowspotuser/features/auth/domain/entities/register_request.dart';
import 'package:yellowspotuser/features/auth/domain/repositories/auth_repository.dart';

/// Concrete repository — turns DTOs into domain entities.
/// Application layer talks to the abstract [AuthRepository] only.
class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl(this._remote);

  final AuthRemoteDataSource _remote;

  @override
  Future<AppUser> login(AuthCredentials credentials) async {
    final dto = await _remote.authenticate(credentials);
    return dto.toDomain(fallbackUsername: credentials.username);
  }

  @override
  Future<void> register(RegisterRequest request) =>
      _remote.register(request);

  @override
  Future<void> changePassword(ChangePasswordRequest request) =>
      _remote.changePassword(request);
}
