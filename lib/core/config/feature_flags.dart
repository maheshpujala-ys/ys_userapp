class FeatureFlags {
  final bool aiAssistant;
  final bool liveParking;
  final bool anpr;
  final bool rfid;
  final bool evCharging;
  final bool payments;
  final bool emergencySos;

  const FeatureFlags({
    this.aiAssistant = true,
    this.liveParking = true,
    this.anpr = false, // Requires live camera hardware
    this.rfid = false, // Requires physical RFID readers
    this.evCharging = false, // Requires OCPP charging station
    this.payments = false, // Requires live payment gateway key
    this.emergencySos = true,
  });

  static const FeatureFlags development = FeatureFlags(
    aiAssistant: true,
    liveParking: true,
    anpr: false,
    rfid: false,
    evCharging: false,
    payments: false,
    emergencySos: true,
  );

  static const FeatureFlags production = FeatureFlags(
    aiAssistant: true,
    liveParking: true,
    anpr: true,
    rfid: true,
    evCharging: true,
    payments: true,
    emergencySos: true,
  );
}
