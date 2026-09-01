import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yellowspotuser/core/providers/app_providers.dart';
import 'package:yellowspotuser/features/admin/domain/admin_models.dart';

abstract class AdminOperationsRepository {
  Future<List<AdminResidentItem>> getResidents();
  Future<List<AdminVehicleItem>> getVehicles();
  Future<List<AdminSmartCardItem>> getSmartCards();
  Future<List<AdminGateDevice>> getGateDevices();
  Future<List<AdminSosAlert>> getSosAlerts();
  Future<List<AdminAuditLogItem>> getAuditLogs();
  Future<void> updateSmartCardStatus(String cardId, SmartCardStatus status);
  Future<void> overrideGateBarrier(String gateId, bool open);
  Future<void> updateSosStatus(String alertId, SosAlertStatus status);
}

class MockAdminOperationsRepository implements AdminOperationsRepository {
  final Dio? dio;
  MockAdminOperationsRepository([this.dio]);

  final List<AdminResidentItem> _residents = [
    const AdminResidentItem(
      id: 'res-1',
      name: 'Rajesh Kumar',
      email: 'rajesh.kumar@example.com',
      phone: '+91 98765 43210',
      tower: 'Tower A',
      unit: 'Flat 1204',
      isOwner: true,
      isActive: true,
      vehicleCount: 2,
      smartCardCount: 3,
    ),
    const AdminResidentItem(
      id: 'res-2',
      name: 'Priya Sharma',
      email: 'priya.sharma@example.com',
      phone: '+91 98765 43211',
      tower: 'Tower B',
      unit: 'Flat 802',
      isOwner: false,
      isActive: true,
      vehicleCount: 1,
      smartCardCount: 2,
    ),
    const AdminResidentItem(
      id: 'res-3',
      name: 'Amit Patel',
      email: 'amit.patel@example.com',
      phone: '+91 98765 43212',
      tower: 'Tower A',
      unit: 'Flat 401',
      isOwner: true,
      isActive: true,
      vehicleCount: 2,
      smartCardCount: 2,
    ),
  ];

  final List<AdminVehicleItem> _vehicles = [
    const AdminVehicleItem(
      id: 'v-1',
      registration: 'TS 09 EQ 4821',
      makeModel: 'Tata Nexon EV Max',
      ownerName: 'Rajesh Kumar',
      unit: 'A-1204',
      type: 'EV',
      parkingBay: 'B2-45 (EV Reserved)',
      rfidTag: 'FASTAG-882109',
      isAuthorized: true,
    ),
    const AdminVehicleItem(
      id: 'v-2',
      registration: 'KA 03 MX 9021',
      makeModel: 'Hyundai Creta SX',
      ownerName: 'Priya Sharma',
      unit: 'B-802',
      type: '4W',
      parkingBay: 'B1-12',
      rfidTag: 'FASTAG-449102',
      isAuthorized: true,
    ),
    const AdminVehicleItem(
      id: 'v-3',
      registration: 'TS 08 AB 1102',
      makeModel: 'Ather 450X',
      ownerName: 'Amit Patel',
      unit: 'A-401',
      type: '2W',
      parkingBay: 'B2-2W-18',
      rfidTag: 'FASTAG-110299',
      isAuthorized: true,
    ),
  ];

  final List<AdminSmartCardItem> _smartCards = [
    AdminSmartCardItem(
      id: 'sc-1',
      cardUid: 'RFID-9842-AX',
      residentName: 'Rajesh Kumar',
      unit: 'A-1204',
      status: SmartCardStatus.active,
      permissions: const ['Main Gate', 'Basement 2 Parking', 'Clubhouse', 'Gym'],
      createdDate: DateTime.now().subtract(const Duration(days: 90)),
      expiryDate: DateTime.now().add(const Duration(days: 275)),
      lastUsedGate: 'Gate 1 (ANPR Barrier)',
    ),
    AdminSmartCardItem(
      id: 'sc-2',
      cardUid: 'RFID-1120-BB',
      residentName: 'Priya Sharma',
      unit: 'B-802',
      status: SmartCardStatus.active,
      permissions: const ['Main Gate', 'Basement 1 Parking', 'Clubhouse'],
      createdDate: DateTime.now().subtract(const Duration(days: 30)),
      expiryDate: DateTime.now().add(const Duration(days: 335)),
      lastUsedGate: 'Gate 2 (Pedestrian Gate)',
    ),
  ];

  final List<AdminGateDevice> _gateDevices = [
    const AdminGateDevice(
      gateId: 'gate-1',
      name: 'Main Security Gate 1 (Entry/Exit)',
      cameraStatus: GateDeviceStatus.online,
      anprStatus: GateDeviceStatus.online,
      rfidReaderStatus: GateDeviceStatus.online,
      barrierStatus: GateDeviceStatus.online,
      isBarrierOpen: false,
    ),
    const AdminGateDevice(
      gateId: 'gate-2',
      name: 'Service Gate 2 (Deliveries & Staff)',
      cameraStatus: GateDeviceStatus.online,
      anprStatus: GateDeviceStatus.online,
      rfidReaderStatus: GateDeviceStatus.online,
      barrierStatus: GateDeviceStatus.warning,
      isBarrierOpen: false,
    ),
  ];

  final List<AdminSosAlert> _sosAlerts = [
    AdminSosAlert(
      id: 'sos-1',
      type: 'Medical Emergency',
      residentName: 'Sunita Roy',
      unit: 'Tower C - Flat 502',
      location: 'Tower C 5th Floor Corridor',
      timestamp: DateTime.now().subtract(const Duration(minutes: 8)),
      status: SosAlertStatus.responding,
      responderNote: 'Guard Unit 2 dispatched with First Aid Kit',
    ),
  ];

  final List<AdminAuditLogItem> _auditLogs = [
    AdminAuditLogItem(
      id: 'aud-1',
      operatorName: 'Suresh Patil',
      operatorRole: AdminSubRole.securityGuard,
      action: 'Manual Gate Override (Open Barrier)',
      target: 'Gate 1 (Visitor ts 08 mx 112)',
      timestamp: DateTime.now().subtract(const Duration(minutes: 15)),
      result: 'OVERRIDE',
    ),
    AdminAuditLogItem(
      id: 'aud-2',
      operatorName: 'Society Admin (admin@test.com)',
      operatorRole: AdminSubRole.societyAdmin,
      action: 'Allocated EV Parking Bay B2-45',
      target: 'Resident Rajesh Kumar (A-1204)',
      timestamp: DateTime.now().subtract(const Duration(hours: 2)),
      result: 'SUCCESS',
    ),
    AdminAuditLogItem(
      id: 'aud-3',
      operatorName: 'Society Admin (admin@test.com)',
      operatorRole: AdminSubRole.societyAdmin,
      action: 'Issued Smart Card RFID-9842-AX',
      target: 'Resident Rajesh Kumar (A-1204)',
      timestamp: DateTime.now().subtract(const Duration(days: 1)),
      result: 'SUCCESS',
    ),
  ];

  @override
  Future<List<AdminResidentItem>> getResidents() async {
    await Future.delayed(const Duration(milliseconds: 100));
    return List.unmodifiable(_residents);
  }

  @override
  Future<List<AdminVehicleItem>> getVehicles() async {
    await Future.delayed(const Duration(milliseconds: 100));
    return List.unmodifiable(_vehicles);
  }

  @override
  Future<List<AdminSmartCardItem>> getSmartCards() async {
    await Future.delayed(const Duration(milliseconds: 100));
    return List.unmodifiable(_smartCards);
  }

  @override
  Future<List<AdminGateDevice>> getGateDevices() async {
    await Future.delayed(const Duration(milliseconds: 100));
    return List.unmodifiable(_gateDevices);
  }

  @override
  Future<List<AdminSosAlert>> getSosAlerts() async {
    await Future.delayed(const Duration(milliseconds: 100));
    return List.unmodifiable(_sosAlerts);
  }

  @override
  Future<List<AdminAuditLogItem>> getAuditLogs() async {
    await Future.delayed(const Duration(milliseconds: 100));
    return List.unmodifiable(_auditLogs);
  }

  @override
  Future<void> updateSmartCardStatus(String cardId, SmartCardStatus status) async {
    await Future.delayed(const Duration(milliseconds: 100));
    final index = _smartCards.indexWhere((c) => c.id == cardId);
    if (index != -1) {
      final old = _smartCards[index];
      _smartCards[index] = AdminSmartCardItem(
        id: old.id,
        cardUid: old.cardUid,
        residentName: old.residentName,
        unit: old.unit,
        status: status,
        permissions: old.permissions,
        createdDate: old.createdDate,
        expiryDate: old.expiryDate,
        lastUsedGate: old.lastUsedGate,
      );
    }
  }

  @override
  Future<void> overrideGateBarrier(String gateId, bool open) async {
    await Future.delayed(const Duration(milliseconds: 100));
  }

  @override
  Future<void> updateSosStatus(String alertId, SosAlertStatus status) async {
    await Future.delayed(const Duration(milliseconds: 100));
    final index = _sosAlerts.indexWhere((a) => a.id == alertId);
    if (index != -1) {
      final old = _sosAlerts[index];
      _sosAlerts[index] = AdminSosAlert(
        id: old.id,
        type: old.type,
        residentName: old.residentName,
        unit: old.unit,
        location: old.location,
        timestamp: old.timestamp,
        status: status,
        responderNote: old.responderNote,
      );
    }
  }
}

final adminOperationsRepositoryProvider = Provider<AdminOperationsRepository>((ref) {
  final dio = ref.watch(dioProvider);
  return MockAdminOperationsRepository(dio);
});
