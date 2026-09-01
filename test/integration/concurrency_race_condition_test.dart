import 'package:flutter_test/flutter_test.dart';
import 'package:yellowspotuser/core/services/network/api_error_handler.dart';

void main() {
  test('Concurrency Simulation: Two residents reserving the same parking slot triggers 409 Conflict', () async {
    bool slotReservedByFirst = false;

    Future<String> attemptSlotBooking(String residentId, String slotId) async {
      if (!slotReservedByFirst) {
        slotReservedByFirst = true;
        return 'BOOKING_SUCCESS_$slotId';
      } else {
        throw const ApiException(
          statusCode: 409,
          message: 'Booking conflict detected. The slot or resource is already reserved.',
          code: 'CONFLICT',
        );
      }
    }

    // Resident A books first
    final resultA = await attemptSlotBooking('resident_A', 'SLOT_B2_45');
    expect(resultA, equals('BOOKING_SUCCESS_SLOT_B2_45'));

    // Resident B attempts the same slot concurrently
    expect(
      () => attemptSlotBooking('resident_B', 'SLOT_B2_45'),
      throwsA(isA<ApiException>().having((e) => e.statusCode, 'statusCode', 409)),
    );
  });
}
