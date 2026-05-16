import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yellowspotuser/core/network/api_endpoints.dart';
import 'package:yellowspotuser/core/network/api_exception.dart';
import 'package:yellowspotuser/core/providers/app_providers.dart';

/// Request body for `POST /api/v1/smart_cards` and `PUT /api/v1/smart_cards/{id}`
/// (SmartCardRequestDto).
class SmartCardCreateRequest {
  const SmartCardCreateRequest({
    required this.locationId,
    required this.cardNumber,
    required this.serialNumber,
    required this.cardType,
    required this.allocationStatus,
    required this.vehicleTypeId,
    this.activeInd = 'Y',
  });

  final int locationId;
  final String cardNumber;
  final String serialNumber;
  final String cardType;

  /// `ALLOCATED` / `AVAILABLE`.
  final String allocationStatus;
  final int vehicleTypeId;
  final String activeInd;

  Map<String, dynamic> toJson() => {
        'locationId': locationId,
        'cardNumber': cardNumber,
        'serialNumber': serialNumber,
        'cardType': cardType,
        'allocationStatus': allocationStatus,
        'vehicleTypeId': vehicleTypeId,
        'activeInd': activeInd,
      };
}

/// Projection of SmartCardResponseDto — carries everything needed for both
/// list display and pre-filling the edit form.
class SmartCardSummary {
  const SmartCardSummary({
    required this.smartCardId,
    required this.cardNumber,
    this.serialNumber,
    this.cardType,
    this.allocationStatus,
    this.activeInd,
    this.vehicleTypeId,
    this.locationId,
    this.locationName,
  });

  factory SmartCardSummary.fromJson(Map<String, dynamic> json) {
    final loc = json['location'];
    int? locId;
    String? locName;
    if (loc is Map) {
      final l = loc.cast<String, dynamic>();
      final v = l['locationId'];
      if (v is num) locId = v.toInt();
      final n = l['name'];
      if (n is String) locName = n;
    }
    if (locId == null && json['locationId'] is num) {
      locId = (json['locationId'] as num).toInt();
    }
    return SmartCardSummary(
      smartCardId: _asInt(json['smartCardId']),
      cardNumber: _asString(json['cardNumber']),
      serialNumber: _asNullableString(json['serialNumber']),
      cardType: _asNullableString(json['cardType']),
      allocationStatus: _asNullableString(json['allocationStatus']),
      activeInd: _asNullableString(json['activeInd']),
      vehicleTypeId: (json['vehicleTypeId'] as num?)?.toInt(),
      locationId: locId,
      locationName: locName,
    );
  }

  final int smartCardId;
  final String cardNumber;
  final String? serialNumber;
  final String? cardType;
  final String? allocationStatus;
  final String? activeInd;
  final int? vehicleTypeId;
  final int? locationId;
  final String? locationName;

  bool get isActive => (activeInd ?? '').toUpperCase() == 'Y';

  static int _asInt(dynamic v) {
    if (v is num) return v.toInt();
    if (v is String) return int.tryParse(v) ?? 0;
    return 0;
  }

  static String _asString(dynamic v) {
    if (v == null) return '';
    if (v is String) return v;
    return v.toString();
  }

  static String? _asNullableString(dynamic v) {
    if (v == null) return null;
    if (v is String) return v.isEmpty ? null : v;
    return v.toString();
  }
}

class SmartCardsRemoteDataSource {
  SmartCardsRemoteDataSource(this._dio);

  final Dio _dio;

  Future<void> createSmartCard(SmartCardCreateRequest request) async {
    try {
      await _dio.post<dynamic>(
        ApiEndpoints.smartCards,
        data: request.toJson(),
      );
    } on DioException catch (e) {
      throw ApiException.fromDio(e, fallback: 'Could not create smart card');
    }
  }

  Future<void> updateSmartCard(
      int smartCardId, SmartCardCreateRequest request) async {
    try {
      await _dio.put<dynamic>(
        '${ApiEndpoints.smartCards}/$smartCardId',
        data: request.toJson(),
      );
    } on DioException catch (e) {
      throw ApiException.fromDio(e, fallback: 'Could not update smart card');
    }
  }

  Future<List<SmartCardSummary>> getSmartCards(
      {int page = 0, int size = 50}) async {
    try {
      final response = await _dio.get<dynamic>(
        ApiEndpoints.smartCards,
        queryParameters: {'page': page, 'size': size},
      );
      final rows = _extractRows(response.data);
      return rows.map(SmartCardSummary.fromJson).toList(growable: false);
    } on DioException catch (e) {
      throw ApiException.fromDio(e, fallback: 'Could not load smart cards');
    }
  }

  Future<List<SmartCardSummary>> getAvailableSmartCards() async {
    try {
      final response = await _dio.get<dynamic>(ApiEndpoints.smartCardsAvailable);
      final rows = _extractRows(response.data);
      return rows.map(SmartCardSummary.fromJson).toList(growable: false);
    } on DioException catch (e) {
      throw ApiException.fromDio(e,
          fallback: 'Could not load available smart cards');
    }
  }

  static List<Map<String, dynamic>> _extractRows(dynamic body) {
    if (body is List) return _coerceMaps(body);
    if (body is Map) {
      final m = body.cast<String, dynamic>();
      final content = m['content'];
      if (content is List) return _coerceMaps(content);
      final embedded = m['_embedded'];
      if (embedded is Map) {
        for (final v in embedded.values) {
          if (v is List) return _coerceMaps(v);
        }
      }
      final data = m['data'];
      if (data is List) return _coerceMaps(data);
    }
    return const [];
  }

  static List<Map<String, dynamic>> _coerceMaps(List raw) {
    final out = <Map<String, dynamic>>[];
    for (final item in raw) {
      if (item is Map) out.add(item.cast<String, dynamic>());
    }
    return out;
  }
}

final smartCardsRemoteDataSourceProvider = Provider<SmartCardsRemoteDataSource>(
  (ref) => SmartCardsRemoteDataSource(ref.watch(dioProvider)),
);

final smartCardsListProvider =
    FutureProvider.autoDispose<List<SmartCardSummary>>((ref) {
  return ref.watch(smartCardsRemoteDataSourceProvider).getSmartCards();
});
