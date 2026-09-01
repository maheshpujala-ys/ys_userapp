import 'package:flutter_test/flutter_test.dart';
import 'package:yellowspotuser/features/admin/domain/admin_models.dart';

void main() {
  group('Admin Permission Matrix Tests', () {
    test('SuperAdmin has full access across all operations', () {
      expect(AdminPermission.canManageResidents(AdminSubRole.superAdmin), isTrue);
      expect(AdminPermission.canManageVehicles(AdminSubRole.superAdmin), isTrue);
      expect(AdminPermission.canManageParking(AdminSubRole.superAdmin), isTrue);
      expect(AdminPermission.canManageSmartCards(AdminSubRole.superAdmin), isTrue);
      expect(AdminPermission.canControlGates(AdminSubRole.superAdmin), isTrue);
      expect(AdminPermission.canResolveSos(AdminSubRole.superAdmin), isTrue);
      expect(AdminPermission.canManageMaintenance(AdminSubRole.superAdmin), isTrue);
      expect(AdminPermission.canViewAuditLogs(AdminSubRole.superAdmin), isTrue);
    });

    test('Security Guard has gate control and SOS access but cannot manage residents or audit logs', () {
      expect(AdminPermission.canControlGates(AdminSubRole.securityGuard), isTrue);
      expect(AdminPermission.canResolveSos(AdminSubRole.securityGuard), isTrue);
      expect(AdminPermission.canManageResidents(AdminSubRole.securityGuard), isFalse);
      expect(AdminPermission.canViewAuditLogs(AdminSubRole.securityGuard), isFalse);
    });

    test('Maintenance Manager can manage maintenance requests but cannot issue smart cards', () {
      expect(AdminPermission.canManageMaintenance(AdminSubRole.maintenanceManager), isTrue);
      expect(AdminPermission.canManageSmartCards(AdminSubRole.maintenanceManager), isFalse);
      expect(AdminPermission.canControlGates(AdminSubRole.maintenanceManager), isFalse);
    });
  });
}
