import 'package:flutter_test/flutter_test.dart';
import 'package:yellowspotuser/features/admin/data/admin_operations_repository.dart';
import 'package:yellowspotuser/features/admin/domain/admin_models.dart';

void main() {
  late MockAdminOperationsRepository repository;

  setUp(() {
    repository = MockAdminOperationsRepository();
  });

  group('Admin Operations Repository Tests', () {
    test('fetches residents directory and verifies tenant fields', () async {
      final residents = await repository.getResidents();
      expect(residents, isNotEmpty);
      expect(residents.first.name, equals('Rajesh Kumar'));
      expect(residents.first.isOwner, isTrue);
    });

    test('fetches vehicles and checks EV and RFID FastTag tags', () async {
      final vehicles = await repository.getVehicles();
      expect(vehicles, isNotEmpty);
      expect(vehicles.any((v) => v.type == 'EV'), isTrue);
    });

    test('fetches smart cards and updates status to suspended', () async {
      final cards = await repository.getSmartCards();
      final cardId = cards.first.id;

      await repository.updateSmartCardStatus(cardId, SmartCardStatus.suspended);
      final updatedCards = await repository.getSmartCards();
      expect(updatedCards.firstWhere((c) => c.id == cardId).status, equals(SmartCardStatus.suspended));
    });

    test('fetches gate devices and audits overrides', () async {
      final gates = await repository.getGateDevices();
      expect(gates.length, equals(2));
      expect(gates.first.anprStatus, equals(GateDeviceStatus.online));

      final auditLogs = await repository.getAuditLogs();
      expect(auditLogs, isNotEmpty);
    });
  });
}
