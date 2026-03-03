import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yellowspotuser/core/providers/app_providers.dart';
import 'package:yellowspotuser/features/residential/domain/vehicle.dart';

class ResidentialRepository {
  final Dio _dio;

  ResidentialRepository(this._dio);

  static final provider = Provider<ResidentialRepository>(
    (ref) => ResidentialRepository(ref.watch(dioProvider)),
  );

  Future<Map<String, dynamic>> getResidentialData() async {
    await Future.delayed(const Duration(seconds: 1));
    return {
      'ownerName': 'Rajesh Kumar',
      'unit': 'Unit B-1204',
      'society': 'Phoenix Heights',
      'vehicles': [
        Vehicle(number: 'TS09ER1234', type: VehicleType.fourWheeler, plateType: PlateType.ev, isActive: true),
        Vehicle(number: 'TS09ER5678', type: VehicleType.twoWheeler, plateType: PlateType.private, isActive: true),
        Vehicle(number: 'TS09ER9012', type: VehicleType.fourWheeler, plateType: PlateType.taxi, isActive: false),
      ]
    };
  }
}
