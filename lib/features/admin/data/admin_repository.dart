import 'package:dio/dio.dart';
import 'package:yellowspotuser/core/network/api_endpoints.dart';
import 'package:yellowspotuser/core/network/api_exception.dart';

/// Repository for the admin dashboard tabs.
///
/// Dashboard stats + Entry/Exit + Activity are wired to the UAB Parking
/// Management API. Requests and Security remain mocked — the API has no
/// matching endpoints (per integration plan).
class AdminRepository {
  AdminRepository(this._dio);

  final Dio _dio;

  /// Aggregates `/dashboard/stats` + `/tenants/stats` into the
  /// `{residents, vehicles, parking, pending}` shape the UI cards consume.
  /// Same shape is emitted by the mock websocket — keep them aligned.
  Future<Map<String, dynamic>> getDashboardData() async {
    try {
      final responses = await Future.wait([
        _dio.get<dynamic>(ApiEndpoints.dashboardStats),
        _dio.get<dynamic>(ApiEndpoints.tenantStats),
      ]);
      final stats = _asMap(responses[0].data);
      final tenants = _asMap(responses[1].data);
      final totalSlots = _asInt(stats['totalSlots']);
      final vehicleOut = _asInt(stats['vehicleOut']);
      final totalVehicles = _asInt(stats['totalVehicleCount']);
      final fourWheeler = _asInt(stats['fourWheelerCount']);
      final twoWheeler = _asInt(stats['twoWheelerCount']);
      final occupiedPct = totalSlots > 0
          ? (((totalSlots - vehicleOut) / totalSlots) * 100).round()
          : 0;
      final residents = _asInt(tenants['tenants']) + _asInt(tenants['owners']);
      return {
        'residents': residents,
        'vehicles': totalVehicles,
        'fourWheelerCount': fourWheeler,
        'twoWheelerCount': twoWheeler,
        'parking': occupiedPct,
        // No backend equivalent yet — Admin "Requests" stays mocked.
        'pending': 0,
      };
    } on DioException catch (e) {
      throw ApiException.fromDio(e, fallback: 'Could not load dashboard');
    }
  }

  /// Maps each row of `/dashboard/parking-logs` (ParkingLogProjection) to
  /// the `{vehicleNumber, unit, owner, isEntry, timestamp}` shape the UI uses.
  Future<List<Map<String, dynamic>>> getEntryExitData() async {
    try {
      final response = await _dio.get<dynamic>(
        ApiEndpoints.dashboardParkingLogs,
        queryParameters: {'page': 0, 'size': 20},
      );
      final rows = _extractRows(response.data);
      return rows.map((row) {
        final logType = _asString(row['logType']).toUpperCase();
        final isEntry = logType == 'IN' || logType == 'ENTRY';
        final tenantName = _asString(row['tenantName']);
        final unitName = _asString(row['name']);
        return <String, dynamic>{
          'vehicleNumber': _asString(row['vehicleNumber']),
          'unit': unitName.isNotEmpty ? unitName : tenantName,
          'owner': tenantName,
          'isEntry': isEntry,
          'timestamp': _formatTimestamp(row['logTime']),
          'imageId': _asString(row['imageId']),
        };
      }).toList(growable: false);
    } on DioException catch (e) {
      throw ApiException.fromDio(e, fallback: 'Could not load entry/exit log');
    }
  }

  /// Maps each `/user-logs` row to `{title, subtitle, timestamp}`.
  Future<List<Map<String, dynamic>>> getActivityData() async {
    try {
      final response = await _dio.get<dynamic>(
        ApiEndpoints.userLogs,
        queryParameters: {'page': 0, 'size': 20},
      );
      final rows = _extractRows(response.data);
      return rows.map((row) {
        final fullname = _asString(row['fullname']);
        final username = _asString(row['username']);
        final name = fullname.isNotEmpty
            ? fullname
            : (username.isNotEmpty ? username : 'User');
        final logoutDt = _parseDateTime(row['logoutTime']);
        final action = logoutDt != null ? 'logged out' : 'signed in';
        final ip = _asString(row['ipAddress']);
        final device = _asString(row['deviceId']);
        final stamp = row['lastActive'] ?? row['loginTime'];
        return <String, dynamic>{
          'title': '$name $action',
          'subtitle': [ip, device].where((s) => s.isNotEmpty).join(' • '),
          'timestamp': _formatTimestamp(stamp),
        };
      }).toList(growable: false);
    } on DioException catch (e) {
      throw ApiException.fromDio(e, fallback: 'Could not load activity');
    }
  }

  /// Mocked — no matching API endpoint (per integration plan).
  Future<List<Map<String, dynamic>>> getRequestsData() async {
    await Future.delayed(const Duration(milliseconds: 400));
    return [
      {
        'userName': 'John Doe',
        'unit': 'Unit B-1506',
        'requestType': 'Join Request',
        'timestamp': '2 hours ago',
      },
      {
        'userName': 'Jane Smith',
        'unit': 'Unit A-405',
        'requestType': 'Vehicle Addition',
        'timestamp': '3 hours ago',
      },
    ];
  }

  /// Mocked — Security/Cameras feature has no backing API (per integration plan).
  Future<Map<String, dynamic>> getSecurityData() async {
    await Future.delayed(const Duration(milliseconds: 400));
    return {
      'activeCameras': '24/28',
      'securityAlerts': 3,
      'recordingHours': '168h',
      'storageUsed': 85,
      'incidents': 12,
      'systemStatus': 'SECURE',
    };
  }

  // ---- safe coercion helpers ----------------------------------------------

  /// Accept Spring's `PagedModel` (`content`), HATEOAS (`_embedded.<x>`),
  /// or a bare top-level list. Returns rows as `Map<String, dynamic>`.
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

  static Map<String, dynamic> _asMap(dynamic v) =>
      v is Map ? v.cast<String, dynamic>() : const <String, dynamic>{};

  static String _asString(dynamic v) {
    if (v == null) return '';
    if (v is String) return v;
    return v.toString();
  }

  static int _asInt(dynamic v) {
    if (v is num) return v.toInt();
    if (v is String) return int.tryParse(v) ?? 0;
    return 0;
  }

  /// Parses the timestamp shapes this backend emits:
  ///  - Jackson `LocalDateTime` array: `[year, month, day, hour, minute, second]`
  ///    or with nanos: `[..., nanos]` (7 elements).
  ///  - ISO-8601 string: `"2026-05-13T12:09:04"`.
  /// Returns `null` if the value is missing or unparseable.
  static DateTime? _parseDateTime(dynamic v) {
    if (v == null) return null;
    if (v is String) {
      if (v.isEmpty) return null;
      return DateTime.tryParse(v);
    }
    if (v is List && v.length >= 3) {
      try {
        final year = (v[0] as num).toInt();
        final month = (v[1] as num).toInt();
        final day = (v[2] as num).toInt();
        final hour = v.length > 3 ? (v[3] as num).toInt() : 0;
        final minute = v.length > 4 ? (v[4] as num).toInt() : 0;
        final second = v.length > 5 ? (v[5] as num).toInt() : 0;
        final ms = v.length > 6 ? ((v[6] as num).toInt() ~/ 1000000) : 0;
        return DateTime(year, month, day, hour, minute, second, ms);
      } catch (_) {
        return null;
      }
    }
    return null;
  }

  /// Friendly relative-time label for the UI: `"5m ago"`, `"2h ago"`,
  /// `"3d ago"`, or a fallback ISO date for older entries. Empty string if
  /// the input can't be parsed.
  static String _formatTimestamp(dynamic v) {
    final dt = _parseDateTime(v);
    if (dt == null) return _asString(v);
    final now = DateTime.now();
    final diff = now.difference(dt);
    if (diff.isNegative) return _isoDate(dt);
    if (diff.inSeconds < 60) return 'just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return _isoDate(dt);
  }

  static String _isoDate(DateTime dt) {
    String two(int n) => n.toString().padLeft(2, '0');
    return '${dt.year}-${two(dt.month)}-${two(dt.day)} '
        '${two(dt.hour)}:${two(dt.minute)}';
  }
}
