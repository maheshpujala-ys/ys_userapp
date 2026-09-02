import 'package:flutter_test/flutter_test.dart';
import 'package:yellowspotuser/features/admin/domain/access_event_model.dart';
import 'package:yellowspotuser/features/admin/domain/admin_models.dart';

void main() {
  group('Access Event Correlation & Idempotency Engine Tests (Phase 9.1)', () {
    late AccessEventCorrelationEngine engine;

    setUp(() {
      engine = AccessEventCorrelationEngine();
    });

    test('1. Same vehicle enters twice in separate legitimate crossings generates 2 distinct events', () {
      final crossing1 = engine.processEvent(
        idempotencyKey: 'tx-cross-001',
        deviceEventId: 'dev-anpr-101',
        gateId: 'gate-1-main',
        deviceId: 'CAM-GATE1-ANPR',
        credentialOrPlate: 'KA 03 MN 8821',
        eventType: AccessMethodType.anpr,
        isAuthorizedCredential: true,
        loop2Cleared: true,
      );

      final crossing2 = engine.processEvent(
        idempotencyKey: 'tx-cross-002',
        deviceEventId: 'dev-anpr-102',
        gateId: 'gate-1-main',
        deviceId: 'CAM-GATE1-ANPR',
        credentialOrPlate: 'KA 03 MN 8821',
        eventType: AccessMethodType.anpr,
        isAuthorizedCredential: true,
        loop2Cleared: true,
      );

      expect(crossing1.eventId, isNot(equals(crossing2.eventId)));
      expect(crossing1.processingStatus, AccessProcessingStatus.eventRecorded);
      expect(crossing2.processingStatus, AccessProcessingStatus.eventRecorded);
      expect(engine.eventLog.length, 2);
    });

    test('2. Same vehicle generates duplicate ANPR messages (same deviceEventId deduplicated)', () {
      final initial = engine.processEvent(
        idempotencyKey: 'tx-key-101',
        deviceEventId: 'dev-anpr-duplicate-test',
        gateId: 'gate-1-main',
        deviceId: 'CAM-GATE1-ANPR',
        credentialOrPlate: 'KA 03 MN 8821',
        eventType: AccessMethodType.anpr,
        isAuthorizedCredential: true,
      );

      final duplicate = engine.processEvent(
        idempotencyKey: 'tx-key-102',
        deviceEventId: 'dev-anpr-duplicate-test',
        gateId: 'gate-1-main',
        deviceId: 'CAM-GATE1-ANPR',
        credentialOrPlate: 'KA 03 MN 8821',
        eventType: AccessMethodType.anpr,
        isAuthorizedCredential: true,
      );

      expect(initial.processingStatus, AccessProcessingStatus.physicalOpenConfirmed);
      expect(duplicate.processingStatus, AccessProcessingStatus.duplicateEvent);
      expect(duplicate.eventId, initial.eventId);
      expect(engine.eventLog.length, 1);
    });

    test('3. Same RFID event retry is deduplicated via idempotencyKey', () {
      final rfid1 = engine.processEvent(
        idempotencyKey: 'rfid-retry-key-01',
        gateId: 'gate-1-main',
        deviceId: 'RFID-GATE1-UHF',
        credentialOrPlate: 'RFID-YS-4001',
        eventType: AccessMethodType.rfidFastTag,
        isAuthorizedCredential: true,
      );

      final rfidRetry = engine.processEvent(
        idempotencyKey: 'rfid-retry-key-01',
        gateId: 'gate-1-main',
        deviceId: 'RFID-GATE1-UHF',
        credentialOrPlate: 'RFID-YS-4001',
        eventType: AccessMethodType.rfidFastTag,
        isAuthorizedCredential: true,
      );

      expect(rfidRetry.processingStatus, AccessProcessingStatus.duplicateEvent);
      expect(rfidRetry.eventId, rfid1.eventId);
      expect(engine.eventLog.length, 1);
    });

    test('4. Same device event ID arriving twice returns duplicateEvent status', () {
      engine.processEvent(
        idempotencyKey: 'key-a',
        deviceEventId: 'DEV-EVT-999',
        gateId: 'gate-1',
        deviceId: 'dev-1',
        credentialOrPlate: 'TS 09 EQ 1234',
        eventType: AccessMethodType.anpr,
        isAuthorizedCredential: true,
      );

      final duplicate = engine.processEvent(
        idempotencyKey: 'key-b',
        deviceEventId: 'DEV-EVT-999',
        gateId: 'gate-1',
        deviceId: 'dev-1',
        credentialOrPlate: 'TS 09 EQ 1234',
        eventType: AccessMethodType.anpr,
        isAuthorizedCredential: true,
      );

      expect(duplicate.processingStatus, AccessProcessingStatus.duplicateEvent);
    });

    test('5. API request timeout and client retry with idempotencyKey returns cached result', () {
      final original = engine.processEvent(
        idempotencyKey: 'idemp-client-tx-555',
        gateId: 'gate-1',
        deviceId: 'HONEYWELL-QR-01',
        credentialOrPlate: 'QR-PASS-GUEST-01',
        eventType: AccessMethodType.qrCode,
        isAuthorizedCredential: true,
        loop2Cleared: true,
      );

      final clientRetry = engine.processEvent(
        idempotencyKey: 'idemp-client-tx-555',
        gateId: 'gate-1',
        deviceId: 'HONEYWELL-QR-01',
        credentialOrPlate: 'QR-PASS-GUEST-01',
        eventType: AccessMethodType.qrCode,
        isAuthorizedCredential: true,
        loop2Cleared: true,
      );

      expect(clientRetry.eventId, original.eventId);
      expect(clientRetry.commandId, original.commandId);
      expect(clientRetry.isCrossingConfirmed, true);
    });

    test('6. Late arriving event is processed without corrupting state log', () {
      final tMinus5 = DateTime.now().subtract(const Duration(minutes: 5));
      final lateEvent = engine.processEvent(
        idempotencyKey: 'late-key-1',
        deviceEventId: 'dev-late-1',
        gateId: 'gate-1',
        deviceId: 'CAM-GATE1-ANPR',
        credentialOrPlate: 'DL 01 AA 1000',
        eventType: AccessMethodType.anpr,
        isAuthorizedCredential: true,
        timestamp: tMinus5,
        loop2Cleared: true,
      );

      expect(lateEvent.timestamp, tMinus5);
      expect(lateEvent.processingStatus, AccessProcessingStatus.eventRecorded);
    });

    test('7. Out-of-order events receive unique correlation IDs and preserve individual payloads', () {
      final ev2Time = DateTime.now().subtract(const Duration(seconds: 10));
      final ev1Time = DateTime.now().subtract(const Duration(seconds: 20));

      final ev2 = engine.processEvent(
        idempotencyKey: 'ooo-key-2',
        deviceEventId: 'ooo-dev-2',
        gateId: 'gate-1',
        deviceId: 'CAM-GATE1-ANPR',
        credentialOrPlate: 'KA 03 MN 8821',
        eventType: AccessMethodType.anpr,
        isAuthorizedCredential: true,
        timestamp: ev2Time,
      );

      final ev1 = engine.processEvent(
        idempotencyKey: 'ooo-key-1',
        deviceEventId: 'ooo-dev-1',
        gateId: 'gate-1',
        deviceId: 'CAM-GATE1-ANPR',
        credentialOrPlate: 'TS 09 EQ 1234',
        eventType: AccessMethodType.anpr,
        isAuthorizedCredential: true,
        timestamp: ev1Time,
      );

      expect(ev1.correlationId, isNot(equals(ev2.correlationId)));
      expect(engine.eventLog.length, 2);
    });

    test('8. Edge gateway reconnects and batch resends queued events deduplicating repeats', () {
      // 10 events queued at edge
      for (int i = 0; i < 10; i++) {
        engine.processEvent(
          idempotencyKey: 'batch-sync-key-$i',
          deviceEventId: 'batch-dev-$i',
          gateId: 'gate-1',
          deviceId: 'EDGE-GATEWAY-01',
          credentialOrPlate: 'VEH-BATCH-$i',
          eventType: AccessMethodType.anpr,
          isAuthorizedCredential: true,
          loop2Cleared: true,
        );
      }
      expect(engine.eventLog.length, 10);

      // Edge gateway reconnects and resends all 10
      for (int i = 0; i < 10; i++) {
        final res = engine.processEvent(
          idempotencyKey: 'batch-sync-key-$i',
          deviceEventId: 'batch-dev-$i',
          gateId: 'gate-1',
          deviceId: 'EDGE-GATEWAY-01',
          credentialOrPlate: 'VEH-BATCH-$i',
          eventType: AccessMethodType.anpr,
          isAuthorizedCredential: true,
          loop2Cleared: true,
        );
        expect(res.processingStatus, AccessProcessingStatus.duplicateEvent);
      }
      expect(engine.eventLog.length, 10); // Zero duplicate rows added
    });

    test('9. Two vehicles detected close together receive distinct event IDs', () {
      final v1 = engine.processEvent(
        idempotencyKey: 'close-seq-1',
        deviceEventId: 'cam-seq-1',
        gateId: 'gate-1',
        deviceId: 'CAM-GATE1-ANPR',
        credentialOrPlate: 'KA 03 MN 8821',
        eventType: AccessMethodType.anpr,
        isAuthorizedCredential: true,
      );

      final v2 = engine.processEvent(
        idempotencyKey: 'close-seq-2',
        deviceEventId: 'cam-seq-2',
        gateId: 'gate-1',
        deviceId: 'CAM-GATE1-ANPR',
        credentialOrPlate: 'TS 09 EQ 1234',
        eventType: AccessMethodType.anpr,
        isAuthorizedCredential: true,
      );

      expect(v1.eventId, isNot(equals(v2.eventId)));
      expect(v1.vehiclePlate, 'KA 03 MN 8821');
      expect(v2.vehiclePlate, 'TS 09 EQ 1234');
      expect(engine.eventLog.length, 2);
    });

    test('10. Vehicle approaches (DETECTED) but reverses out is recorded as abortedReversed', () {
      final result = engine.processEvent(
        idempotencyKey: 'reverse-approach-01',
        gateId: 'gate-1',
        deviceId: 'CAM-GATE1-ANPR',
        credentialOrPlate: 'MH 02 ZZ 9999',
        eventType: AccessMethodType.anpr,
        isAuthorizedCredential: true,
        isAbortedReverse: true,
      );

      expect(result.processingStatus, AccessProcessingStatus.abortedReversed);
      expect(result.physicalState, BarrierPhysicalState.closed);
      expect(result.isCrossingConfirmed, false);
    });

    test('11. Barrier command issued but physical OPEN confirmation never arrives triggers physicalOpenTimeout', () {
      final result = engine.processEvent(
        idempotencyKey: 'fault-timeout-key-01',
        gateId: 'gate-1',
        deviceId: 'ADAM-6060-RELAY',
        credentialOrPlate: 'KA 03 MN 8821',
        eventType: AccessMethodType.anpr,
        isAuthorizedCredential: true,
        limitSwitchOpenReceived: false, // Limit switch timed out
      );

      expect(result.processingStatus, AccessProcessingStatus.physicalOpenTimeout);
      expect(result.physicalState, BarrierPhysicalState.fault);
      expect(result.isCrossingConfirmed, false);
    });

    test('12. Barrier opens but crossing is not confirmed stays physicalOpenConfirmed without final event recorded', () {
      final result = engine.processEvent(
        idempotencyKey: 'open-no-loop2-01',
        gateId: 'gate-1',
        deviceId: 'ADAM-6060-RELAY',
        credentialOrPlate: 'KA 03 MN 8821',
        eventType: AccessMethodType.anpr,
        isAuthorizedCredential: true,
        limitSwitchOpenReceived: true,
        loop2Cleared: false, // Has not crossed exit loop
      );

      expect(result.processingStatus, AccessProcessingStatus.physicalOpenConfirmed);
      expect(result.physicalState, BarrierPhysicalState.open);
      expect(result.isCrossingConfirmed, false);
    });

    test('13. Same vehicle crosses again after legitimate exit is permitted as a new crossing', () {
      // Entry 1
      engine.processEvent(
        idempotencyKey: 'entry-seq-101',
        deviceEventId: 'dev-e1',
        gateId: 'gate-1-entry',
        deviceId: 'CAM-GATE1-ENTRY',
        credentialOrPlate: 'KA 03 MN 8821',
        eventType: AccessMethodType.anpr,
        isAuthorizedCredential: true,
        loop2Cleared: true,
      );

      // Exit 1
      engine.processEvent(
        idempotencyKey: 'exit-seq-101',
        deviceEventId: 'dev-x1',
        gateId: 'gate-1-exit',
        deviceId: 'CAM-GATE1-EXIT',
        credentialOrPlate: 'KA 03 MN 8821',
        eventType: AccessMethodType.anpr,
        isAuthorizedCredential: true,
        loop2Cleared: true,
      );

      // Entry 2 (Legitimate return crossing)
      final returnEntry = engine.processEvent(
        idempotencyKey: 'entry-seq-102',
        deviceEventId: 'dev-e2',
        gateId: 'gate-1-entry',
        deviceId: 'CAM-GATE1-ENTRY',
        credentialOrPlate: 'KA 03 MN 8821',
        eventType: AccessMethodType.anpr,
        isAuthorizedCredential: true,
        loop2Cleared: true,
      );

      expect(returnEntry.processingStatus, AccessProcessingStatus.eventRecorded);
      expect(engine.eventLog.length, 3);
    });

    test('14. Multiple gates process same vehicle independently without cross-gate collision', () {
      final gate1Crossing = engine.processEvent(
        idempotencyKey: 'gate1-pass-1',
        gateId: 'gate-1-north',
        deviceId: 'CAM-NORTH-01',
        credentialOrPlate: 'KA 03 MN 8821',
        eventType: AccessMethodType.anpr,
        isAuthorizedCredential: true,
        loop2Cleared: true,
      );

      final gate2Crossing = engine.processEvent(
        idempotencyKey: 'gate2-pass-1',
        gateId: 'gate-2-south',
        deviceId: 'CAM-SOUTH-01',
        credentialOrPlate: 'KA 03 MN 8821',
        eventType: AccessMethodType.anpr,
        isAuthorizedCredential: true,
        loop2Cleared: true,
      );

      expect(gate1Crossing.gateId, 'gate-1-north');
      expect(gate2Crossing.gateId, 'gate-2-south');
      expect(gate1Crossing.eventId, isNot(equals(gate2Crossing.eventId)));
      expect(engine.eventLog.length, 2);
    });
  });
}
