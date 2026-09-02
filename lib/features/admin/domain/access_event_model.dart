import 'package:yellowspotuser/features/admin/domain/admin_models.dart';

enum AccessProcessingStatus {
  detected,
  identified,
  authorizationPending,
  authorized,
  denied,
  commandSent,
  physicalOpenConfirmed,
  vehicleCrossingConfirmed,
  eventRecorded,
  authorizationFailed,
  commandFailed,
  controllerOffline,
  physicalOpenTimeout,
  physicalStateUnknown,
  duplicateEvent,
  replayedEvent,
  abortedReversed,
}

enum AccessMethodType {
  anpr,
  rfidFastTag,
  qrCode,
  manualSecurityOverride,
}

class AccessEventRecord {
  final String eventId;
  final String? deviceEventId;
  final String correlationId;
  final String idempotencyKey;
  final String gateId;
  final String deviceId;
  final String? vehicleId;
  final String? vehiclePlate;
  final String? residentId;
  final String? residentName;
  final String? unit;
  final DateTime timestamp;
  final AccessMethodType eventType;
  final String authorizationDecision; // 'AUTHORIZED', 'DENIED', 'MANUAL_VERIFY'
  final String? commandId;
  final BarrierPhysicalState physicalState;
  final AccessProcessingStatus processingStatus;
  final bool isCrossingConfirmed;

  const AccessEventRecord({
    required this.eventId,
    this.deviceEventId,
    required this.correlationId,
    required this.idempotencyKey,
    required this.gateId,
    required this.deviceId,
    this.vehicleId,
    this.vehiclePlate,
    this.residentId,
    this.residentName,
    this.unit,
    required this.timestamp,
    required this.eventType,
    required this.authorizationDecision,
    this.commandId,
    required this.physicalState,
    required this.processingStatus,
    this.isCrossingConfirmed = false,
  });

  AccessEventRecord copyWith({
    String? eventId,
    String? deviceEventId,
    String? correlationId,
    String? idempotencyKey,
    String? gateId,
    String? deviceId,
    String? vehicleId,
    String? vehiclePlate,
    String? residentId,
    String? residentName,
    String? unit,
    DateTime? timestamp,
    AccessMethodType? eventType,
    String? authorizationDecision,
    String? commandId,
    BarrierPhysicalState? physicalState,
    AccessProcessingStatus? processingStatus,
    bool? isCrossingConfirmed,
  }) {
    return AccessEventRecord(
      eventId: eventId ?? this.eventId,
      deviceEventId: deviceEventId ?? this.deviceEventId,
      correlationId: correlationId ?? this.correlationId,
      idempotencyKey: idempotencyKey ?? this.idempotencyKey,
      gateId: gateId ?? this.gateId,
      deviceId: deviceId ?? this.deviceId,
      vehicleId: vehicleId ?? this.vehicleId,
      vehiclePlate: vehiclePlate ?? this.vehiclePlate,
      residentId: residentId ?? this.residentId,
      residentName: residentName ?? this.residentName,
      unit: unit ?? this.unit,
      timestamp: timestamp ?? this.timestamp,
      eventType: eventType ?? this.eventType,
      authorizationDecision: authorizationDecision ?? this.authorizationDecision,
      commandId: commandId ?? this.commandId,
      physicalState: physicalState ?? this.physicalState,
      processingStatus: processingStatus ?? this.processingStatus,
      isCrossingConfirmed: isCrossingConfirmed ?? this.isCrossingConfirmed,
    );
  }
}

/// Backend-Authoritative Access Event Correlation & Idempotency Engine
class AccessEventCorrelationEngine {
  final Map<String, AccessEventRecord> _processedIdempotencyKeys = {};
  final Map<String, AccessEventRecord> _processedDeviceEvents = {};
  final List<AccessEventRecord> _eventLog = [];

  List<AccessEventRecord> get eventLog => List.unmodifiable(_eventLog);

  /// Processes an incoming raw access event payload through the idempotency & lifecycle pipeline
  AccessEventRecord processEvent({
    required String idempotencyKey,
    String? deviceEventId,
    required String gateId,
    required String deviceId,
    required String credentialOrPlate,
    required AccessMethodType eventType,
    required bool isAuthorizedCredential,
    String? residentId,
    String? vehicleId,
    String? unit,
    DateTime? timestamp,
    bool loop1Approach = true,
    bool loop2Cleared = false,
    bool limitSwitchOpenReceived = true,
    bool isAbortedReverse = false,
  }) {
    final eventTime = timestamp ?? DateTime.now();

    // 1. Idempotency Key Check (Client retry / network retry protection)
    if (_processedIdempotencyKeys.containsKey(idempotencyKey)) {
      final existing = _processedIdempotencyKeys[idempotencyKey]!;
      return existing.copyWith(processingStatus: AccessProcessingStatus.duplicateEvent);
    }

    // 2. Device Event ID Deduplication (Hardware retry protection)
    if (deviceEventId != null && _processedDeviceEvents.containsKey(deviceEventId)) {
      final existing = _processedDeviceEvents[deviceEventId]!;
      return existing.copyWith(processingStatus: AccessProcessingStatus.duplicateEvent);
    }

    // 3. Lifecycle state progression: DETECTED -> IDENTIFIED -> AUTHORIZATION
    final correlationId = 'corr-$gateId-${DateTime.now().millisecondsSinceEpoch}-${_eventLog.length + 1}';
    final eventId = 'evt-${DateTime.now().millisecondsSinceEpoch}-${_eventLog.length + 1}';

    if (!isAuthorizedCredential) {
      final deniedRecord = AccessEventRecord(
        eventId: eventId,
        deviceEventId: deviceEventId,
        correlationId: correlationId,
        idempotencyKey: idempotencyKey,
        gateId: gateId,
        deviceId: deviceId,
        vehiclePlate: credentialOrPlate,
        vehicleId: vehicleId,
        residentId: residentId,
        unit: unit,
        timestamp: eventTime,
        eventType: eventType,
        authorizationDecision: 'DENIED',
        physicalState: BarrierPhysicalState.closed,
        processingStatus: AccessProcessingStatus.denied,
        isCrossingConfirmed: false,
      );
      _record(deniedRecord);
      return deniedRecord;
    }

    // Vehicle reverse maneuver detection (Approach without physical crossing)
    if (isAbortedReverse) {
      final reverseRecord = AccessEventRecord(
        eventId: eventId,
        deviceEventId: deviceEventId,
        correlationId: correlationId,
        idempotencyKey: idempotencyKey,
        gateId: gateId,
        deviceId: deviceId,
        vehiclePlate: credentialOrPlate,
        vehicleId: vehicleId,
        residentId: residentId,
        unit: unit,
        timestamp: eventTime,
        eventType: eventType,
        authorizationDecision: 'AUTHORIZED',
        physicalState: BarrierPhysicalState.closed,
        processingStatus: AccessProcessingStatus.abortedReversed,
        isCrossingConfirmed: false,
      );
      _record(reverseRecord);
      return reverseRecord;
    }

    // Barrier Physical Open Timeout check
    if (!limitSwitchOpenReceived) {
      final timeoutRecord = AccessEventRecord(
        eventId: eventId,
        deviceEventId: deviceEventId,
        correlationId: correlationId,
        idempotencyKey: idempotencyKey,
        gateId: gateId,
        deviceId: deviceId,
        vehiclePlate: credentialOrPlate,
        vehicleId: vehicleId,
        residentId: residentId,
        unit: unit,
        timestamp: eventTime,
        eventType: eventType,
        authorizationDecision: 'AUTHORIZED',
        commandId: 'cmd-pulse-${_eventLog.length + 1}',
        physicalState: BarrierPhysicalState.fault,
        processingStatus: AccessProcessingStatus.physicalOpenTimeout,
        isCrossingConfirmed: false,
      );
      _record(timeoutRecord);
      return timeoutRecord;
    }

    // Successful crossing state
    final successRecord = AccessEventRecord(
      eventId: eventId,
      deviceEventId: deviceEventId,
      correlationId: correlationId,
      idempotencyKey: idempotencyKey,
      gateId: gateId,
      deviceId: deviceId,
      vehiclePlate: credentialOrPlate,
      vehicleId: vehicleId,
      residentId: residentId,
      unit: unit,
      timestamp: eventTime,
      eventType: eventType,
      authorizationDecision: 'AUTHORIZED',
      commandId: 'cmd-pulse-${_eventLog.length + 1}',
      physicalState: loop2Cleared ? BarrierPhysicalState.closed : BarrierPhysicalState.open,
      processingStatus: loop2Cleared
          ? AccessProcessingStatus.eventRecorded
          : AccessProcessingStatus.physicalOpenConfirmed,
      isCrossingConfirmed: loop2Cleared,
    );

    _record(successRecord);
    return successRecord;
  }

  void _record(AccessEventRecord record) {
    _processedIdempotencyKeys[record.idempotencyKey] = record;
    if (record.deviceEventId != null) {
      _processedDeviceEvents[record.deviceEventId!] = record;
    }
    _eventLog.add(record);
  }

  void clear() {
    _processedIdempotencyKeys.clear;
    _processedDeviceEvents.clear;
    _eventLog.clear;
  }
}
