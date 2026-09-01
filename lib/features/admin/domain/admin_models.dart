enum AdminSubRole {
  superAdmin,
  societyAdmin,
  securityManager,
  securityGuard,
  facilityManager,
  maintenanceManager,
  accounts,
}

enum SmartCardStatus {
  created,
  assigned,
  active,
  suspended,
  revoked,
  expired,
}

enum GateDeviceStatus {
  online,
  offline,
  warning,
}

enum SosAlertStatus {
  triggered,
  acknowledged,
  responding,
  resolved,
  cancelled,
}

enum BarrierPhysicalState {
  open,
  closed,
  opening,
  closing,
  offline,
  fault,
  unknown,
}

class AdminPermission {
  static bool canManageResidents(AdminSubRole role) =>
      role == AdminSubRole.superAdmin || role == AdminSubRole.societyAdmin;

  static bool canManageVehicles(AdminSubRole role) =>
      role == AdminSubRole.superAdmin ||
      role == AdminSubRole.societyAdmin ||
      role == AdminSubRole.securityManager;

  static bool canManageParking(AdminSubRole role) =>
      role == AdminSubRole.superAdmin ||
      role == AdminSubRole.societyAdmin ||
      role == AdminSubRole.facilityManager;

  static bool canManageSmartCards(AdminSubRole role) =>
      role == AdminSubRole.superAdmin ||
      role == AdminSubRole.societyAdmin ||
      role == AdminSubRole.securityManager;

  static bool canControlGates(AdminSubRole role) =>
      role == AdminSubRole.superAdmin ||
      role == AdminSubRole.societyAdmin ||
      role == AdminSubRole.securityManager ||
      role == AdminSubRole.securityGuard;

  static bool canResolveSos(AdminSubRole role) =>
      role == AdminSubRole.superAdmin ||
      role == AdminSubRole.societyAdmin ||
      role == AdminSubRole.securityManager ||
      role == AdminSubRole.securityGuard;

  static bool canManageMaintenance(AdminSubRole role) =>
      role == AdminSubRole.superAdmin ||
      role == AdminSubRole.societyAdmin ||
      role == AdminSubRole.facilityManager ||
      role == AdminSubRole.maintenanceManager;

  static bool canViewAuditLogs(AdminSubRole role) =>
      role == AdminSubRole.superAdmin || role == AdminSubRole.societyAdmin;
}

class AdminResidentItem {
  final String id;
  final String name;
  final String email;
  final String phone;
  final String tower;
  final String unit;
  final bool isOwner;
  final bool isActive;
  final int vehicleCount;
  final int smartCardCount;

  const AdminResidentItem({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.tower,
    required this.unit,
    required this.isOwner,
    required this.isActive,
    required this.vehicleCount,
    required this.smartCardCount,
  });
}

class AdminVehicleItem {
  final String id;
  final String registration;
  final String makeModel;
  final String ownerName;
  final String unit;
  final String type; // '2W', '4W', 'EV'
  final String parkingBay;
  final String rfidTag;
  final bool isAuthorized;

  const AdminVehicleItem({
    required this.id,
    required this.registration,
    required this.makeModel,
    required this.ownerName,
    required this.unit,
    required this.type,
    required this.parkingBay,
    required this.rfidTag,
    required this.isAuthorized,
  });
}

class AdminSmartCardItem {
  final String id;
  final String cardUid;
  final String residentName;
  final String unit;
  final SmartCardStatus status;
  final List<String> permissions;
  final DateTime createdDate;
  final DateTime expiryDate;
  final String lastUsedGate;

  const AdminSmartCardItem({
    required this.id,
    required this.cardUid,
    required this.residentName,
    required this.unit,
    required this.status,
    required this.permissions,
    required this.createdDate,
    required this.expiryDate,
    required this.lastUsedGate,
  });
}

class AdminGateDevice {
  final String gateId;
  final String name;
  final GateDeviceStatus cameraStatus;
  final GateDeviceStatus anprStatus;
  final GateDeviceStatus rfidReaderStatus;
  final GateDeviceStatus barrierStatus;
  final bool isBarrierOpen;
  final BarrierPhysicalState physicalState;

  const AdminGateDevice({
    required this.gateId,
    required this.name,
    required this.cameraStatus,
    required this.anprStatus,
    required this.rfidReaderStatus,
    required this.barrierStatus,
    required this.isBarrierOpen,
    this.physicalState = BarrierPhysicalState.closed,
  });
}

class AdminSosAlert {
  final String id;
  final String type;
  final String residentName;
  final String unit;
  final String location;
  final DateTime timestamp;
  final SosAlertStatus status;
  final String? responderNote;

  const AdminSosAlert({
    required this.id,
    required this.type,
    required this.residentName,
    required this.unit,
    required this.location,
    required this.timestamp,
    required this.status,
    this.responderNote,
  });
}

class AdminAuditLogItem {
  final String id;
  final String operatorName;
  final AdminSubRole operatorRole;
  final String action;
  final String target;
  final DateTime timestamp;
  final String result; // 'SUCCESS', 'DENIED', 'OVERRIDE'

  const AdminAuditLogItem({
    required this.id,
    required this.operatorName,
    required this.operatorRole,
    required this.action,
    required this.target,
    required this.timestamp,
    required this.result,
  });
}
