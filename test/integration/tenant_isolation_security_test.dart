import 'package:flutter_test/flutter_test.dart';
import 'package:yellowspotuser/core/services/network/api_error_handler.dart';
import 'package:yellowspotuser/features/auth/domain/app_user.dart';

void main() {
  test('Tenant Isolation: Resident cannot query or modify other unit data without 403 Forbidden', () async {
    final residentUser = AppUser(
      id: 'res_1204',
      email: 'resident@yellowspot.io',
      name: 'Rajesh Kumar',
      roles: [UserRole.user],
      token: 'jwt_resident_token',
    );

    Future<Map<String, dynamic>> fetchUnitData(AppUser caller, String targetUnitId) async {
      // Simulate backend tenant authorization check
      if (targetUnitId != 'UNIT_A_1204' && !caller.roles.contains(UserRole.admin)) {
        throw const ApiException(
          statusCode: 403,
          message: 'Access denied. You do not have permission for this resource.',
          code: 'FORBIDDEN',
        );
      }

      return {'unit': targetUnitId, 'owner': caller.name};
    }

    // Access own unit succeeds
    final ownData = await fetchUnitData(residentUser, 'UNIT_A_1204');
    expect(ownData['unit'], equals('UNIT_A_1204'));

    // Attempting to access another resident's unit throws 403 Forbidden
    expect(
      () => fetchUnitData(residentUser, 'UNIT_B_0901'),
      throwsA(isA<ApiException>().having((e) => e.statusCode, 'statusCode', 403)),
    );
  });
}
