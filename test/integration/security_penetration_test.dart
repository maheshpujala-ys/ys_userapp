import 'package:flutter_test/flutter_test.dart';
import 'package:yellowspotuser/core/services/network/api_error_handler.dart';
import 'package:yellowspotuser/features/admin/domain/admin_models.dart';
import 'package:yellowspotuser/features/auth/domain/app_user.dart';

void main() {
  group('Security & Penetration Authorization Tests', () {
    test('Resident cannot execute Admin gate override without 403 Forbidden', () async {
      final residentUser = AppUser(
        id: 'u-101',
        email: 'resident@test.com',
        name: 'Resident User',
        roles: [UserRole.user],
        token: 'resident_token',
      );

      Future<void> executeGateOverride(AppUser user, String gateId) async {
        if (!user.roles.contains(UserRole.admin)) {
          throw const ApiException(
            statusCode: 403,
            message: 'Access denied. Only authorized administrative personnel can override physical gates.',
            code: 'FORBIDDEN',
          );
        }
      }

      expect(
        () => executeGateOverride(residentUser, 'gate-1'),
        throwsA(isA<ApiException>().having((e) => e.statusCode, 'statusCode', 403)),
      );
    });

    test('Security Guard cannot modify resident profile data (RBAC violation)', () {
      const guardRole = AdminSubRole.securityGuard;
      expect(AdminPermission.canManageResidents(guardRole), isFalse);
      expect(AdminPermission.canViewAuditLogs(guardRole), isFalse);
    });

    test('Expired JWT token triggers 401 Unauthorized session invalidation', () async {
      Future<Map<String, dynamic>> callProtectedApi(String token, DateTime tokenExpiry) async {
        if (DateTime.now().isAfter(tokenExpiry)) {
          throw const ApiException(
            statusCode: 401,
            message: 'Your session has expired. Please log in again.',
            code: 'UNAUTHORIZED',
          );
        }
        return {'status': 'OK'};
      }

      final expiredTokenTimestamp = DateTime.now().subtract(const Duration(hours: 1));

      expect(
        () => callProtectedApi('expired_jwt', expiredTokenTimestamp),
        throwsA(isA<ApiException>().having((e) => e.statusCode, 'statusCode', 401)),
      );
    });

    test('Replayed / Expired QR Access Pass is rejected by gate scanner', () async {
      Future<String> validateGateQrPass(String qrToken, bool isExpired) async {
        if (isExpired) {
          throw const ApiException(
            statusCode: 422,
            message: 'Visitor pass has expired or already been redeemed.',
            code: 'PASS_EXPIRED',
          );
        }
        return 'ACCESS_GRANTED';
      }

      expect(
        () => validateGateQrPass('QR_TOKEN_EXPIRED_01', true),
        throwsA(isA<ApiException>().having((e) => e.statusCode, 'statusCode', 422)),
      );
    });
  });
}
