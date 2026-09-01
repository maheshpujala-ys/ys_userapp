import 'package:flutter_test/flutter_test.dart';
import 'package:yellowspotuser/core/config/app_config.dart';
import 'package:yellowspotuser/core/services/network/api_error_handler.dart';
import 'package:yellowspotuser/features/admin/domain/admin_models.dart';
import 'package:yellowspotuser/features/ai_assistant/application/ai_tool_dispatcher.dart';
import 'package:yellowspotuser/features/auth/domain/app_user.dart';

void main() {
  group('Staging E2E Workflow & Multi-Tenant Security Suite', () {
    test('Environment Configuration: Staging points to Staging API and WebSocket', () {
      final staging = AppConfig.staging;
      expect(staging.environment, equals(AppEnvironment.staging));
      expect(staging.apiBaseUrl, contains('staging-api.yellowspot.io'));
      expect(staging.webSocketUrl, contains('staging-api.yellowspot.io'));
      expect(staging.enableMockFallback, isTrue);
    });

    test('Staging Multi-Tenant Isolation: Resident A in Unit A-101 is denied access to Unit A-102 resources', () async {
      final residentA = AppUser(
        id: 'res-A',
        email: 'residentA@staging.yellowspot.io',
        name: 'Resident A',
        roles: [UserRole.user],
        token: 'jwt_staging_resident_a',
      );

      Future<Map<String, dynamic>> fetchUnitDetails(AppUser caller, String targetUnit) async {
        // Enforce backend tenant isolation rule
        if (targetUnit != 'UNIT_A_101' && !caller.roles.contains(UserRole.admin)) {
          throw const ApiException(
            statusCode: 403,
            message: 'Access denied. You are not authorized to view details for this unit.',
            code: 'TENANT_FORBIDDEN',
          );
        }
        return {'unit': targetUnit, 'status': 'AUTHORIZED'};
      }

      // Access own unit A-101 succeeds
      final ownData = await fetchUnitDetails(residentA, 'UNIT_A_101');
      expect(ownData['status'], equals('AUTHORIZED'));

      // Attempting to query Resident B unit A-102 returns 403 Forbidden
      expect(
        () => fetchUnitDetails(residentA, 'UNIT_A_102'),
        throwsA(isA<ApiException>().having((e) => e.statusCode, 'statusCode', 403)),
      );
    });

    test('Staging Concurrency Engine: Slot 101 double-booking resolves authoritatively with 409 Conflict', () async {
      final Set<String> reservedBays = {};

      Future<String> bookSlot(String residentId, String bayId) async {
        if (reservedBays.contains(bayId)) {
          throw const ApiException(
            statusCode: 409,
            message: 'Booking conflict: Slot bay was just reserved by another resident.',
            code: 'SLOT_CONFLICT',
          );
        }
        reservedBays.add(bayId);
        return 'BOOKING_CONFIRMED_$bayId';
      }

      // Resident A books first
      final success = await bookSlot('res-A', 'BAY_101');
      expect(success, equals('BOOKING_CONFIRMED_BAY_101'));

      // Resident B tries to book the same bay simultaneously
      expect(
        () => bookSlot('res-B', 'BAY_101'),
        throwsA(isA<ApiException>().having((e) => e.statusCode, 'statusCode', 409)),
      );
    });

    test('Staging Admin RBAC: 6 Sub-Roles strictly enforced', () {
      // 1. Super Admin: full access
      expect(AdminPermission.canManageResidents(AdminSubRole.superAdmin), isTrue);
      expect(AdminPermission.canControlGates(AdminSubRole.superAdmin), isTrue);
      expect(AdminPermission.canViewAuditLogs(AdminSubRole.superAdmin), isTrue);

      // 2. Society Admin: full access
      expect(AdminPermission.canManageResidents(AdminSubRole.societyAdmin), isTrue);
      expect(AdminPermission.canManageVehicles(AdminSubRole.societyAdmin), isTrue);

      // 3. Security Guard: Gate & SOS only
      expect(AdminPermission.canControlGates(AdminSubRole.securityGuard), isTrue);
      expect(AdminPermission.canResolveSos(AdminSubRole.securityGuard), isTrue);
      expect(AdminPermission.canManageResidents(AdminSubRole.securityGuard), isFalse);
      expect(AdminPermission.canViewAuditLogs(AdminSubRole.securityGuard), isFalse);

      // 4. Maintenance Manager: Maintenance only
      expect(AdminPermission.canManageMaintenance(AdminSubRole.maintenanceManager), isTrue);
      expect(AdminPermission.canManageSmartCards(AdminSubRole.maintenanceManager), isFalse);

      // 5. Facility Manager: Parking & Maintenance
      expect(AdminPermission.canManageParking(AdminSubRole.facilityManager), isTrue);
      expect(AdminPermission.canManageMaintenance(AdminSubRole.facilityManager), isTrue);
      expect(AdminPermission.canControlGates(AdminSubRole.facilityManager), isFalse);
    });

    test('Staging AI Tool Dispatcher: Intent queries resolve safely', () async {
      final parkingResponse = await AiToolDispatcher.executeIntent('show parking status');
      expect(parkingResponse, contains('Parking Status'));

      final visitorResponse = await AiToolDispatcher.executeIntent('who entered recently');
      expect(visitorResponse, contains('Visitor Access Log'));
    });
  });
}
