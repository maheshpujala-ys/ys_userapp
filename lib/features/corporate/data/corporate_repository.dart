import 'dart:io';

import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:yellowspotuser/core/network/api_endpoints.dart';
import 'package:yellowspotuser/core/network/api_exception.dart';
import 'package:yellowspotuser/features/corporate/domain/corporate_models.dart';

/// Repository for the Corporate reports surface
/// (`solutionType == CORPORATE`). Wired to `/api/v1/dashboard/reports/*`.
class CorporateRepository {
  CorporateRepository(this._dio);

  final Dio _dio;

  /// Aggregates `/dashboard/parking-logs` into the corporate dashboard payload.
  ///
  /// Replaces the residential `dashboard/stats` + `tenants/stats` pair.
  /// Optimised to fetch only what's displayed:
  ///   - **1 call, size=20** → the 20 newest rows for "Recent Activities" and
  ///     `totalElements` → Total Transactions.
  ///   - **3 calls, size=1 each** → only `totalElements` (the count metadata)
  ///     scoped by filter — gives accurate Vehicle IN / Vehicle OUT / Visitors
  ///     Today without transferring the actual rows.
  ///
  /// Active 2W / 4W are approximated from the 20-row window (the API has no
  /// "currently inside" endpoint). Total payload ≈ 23 rows + small JSON
  /// envelopes — was 500 rows before.
  Future<CorporateDashboardData> getDashboardData() async {
    try {
      final responses = await Future.wait([
        // Main: recent rows + totalElements for Total Transactions.
        _dio.get<dynamic>(
          ApiEndpoints.dashboardParkingLogs,
          queryParameters: const {'page': 0, 'size': 20},
        ),
        // Vehicle IN — only the count matters.
        _dio.get<dynamic>(
          ApiEndpoints.dashboardParkingLogs,
          queryParameters: const {'page': 0, 'size': 1, 'logType': 'ENTRY'},
        ),
        // Vehicle OUT.
        _dio.get<dynamic>(
          ApiEndpoints.dashboardParkingLogs,
          queryParameters: const {'page': 0, 'size': 1, 'logType': 'EXIT'},
        ),
        // Visitors Today (today's entries).
        _dio.get<dynamic>(
          ApiEndpoints.dashboardParkingLogs,
          queryParameters: const {
            'page': 0,
            'size': 1,
            'logType': 'ENTRY',
            'filterType': 'today',
          },
        ),
      ]);

      final mainBody = responses[0].data;
      final rows = _extractRows(mainBody)
          .map(ParkingLogRow.fromJson)
          .toList();

      final totalTransactions = _readTotalElements(mainBody);
      final vehicleIn = _readTotalElements(responses[1].data);
      final vehicleOut = _readTotalElements(responses[2].data);
      final visitorsToday = _readTotalElements(responses[3].data);

      // Active 2W/4W — approximate from the 20-row window since the API has
      // no "currently inside by type" surface.
      final activeByType = <String, String>{};
      for (final r in rows) {
        if (r.isEntry && r.vehicleNumber.isNotEmpty) {
          activeByType[r.vehicleNumber] = r.vehicleType;
        } else if ((r.logType == 'EXIT' || r.logType == 'OUT') &&
            r.vehicleNumber.isNotEmpty) {
          activeByType.remove(r.vehicleNumber);
        }
      }
      var active2W = 0;
      var active4W = 0;
      for (final t in activeByType.values) {
        final u = t.toUpperCase();
        if (u.contains('2')) active2W++;
        if (u.contains('4')) active4W++;
      }

      rows.sort((a, b) {
        final at = a.logTime;
        final bt = b.logTime;
        if (at == null && bt == null) return 0;
        if (at == null) return 1;
        if (bt == null) return -1;
        return bt.compareTo(at);
      });

      return CorporateDashboardData(
        totalTransactions: totalTransactions,
        vehicleIn: vehicleIn,
        vehicleOut: vehicleOut,
        active2W: active2W,
        active4W: active4W,
        visitorsToday: visitorsToday,
        parkingOccupancy: (vehicleIn - vehicleOut).clamp(0, vehicleIn),
        recentActivities: rows,
      );
    } on DioException catch (e) {
      throw ApiException.fromDio(e,
          fallback: 'Could not load dashboard summary');
    }
  }

  static int _readTotalElements(dynamic body) {
    if (body is Map) {
      final te = body['totalElements'];
      if (te is num) return te.toInt();
    }
    return 0;
  }

  Future<List<AvailabilityRow>> getAvailabilityList() async {
    try {
      final response =
          await _dio.get<dynamic>(ApiEndpoints.reportsAvailabilityList);
      return _extractRows(response.data)
          .map(AvailabilityRow.fromJson)
          .toList(growable: false);
    } on DioException catch (e) {
      throw ApiException.fromDio(e,
          fallback: 'Could not load availability list');
    }
  }

  Future<DayWiseReport> getDayWiseReport(DayWiseQuery query) async {
    try {
      final response = await _dio.get<dynamic>(
        ApiEndpoints.reportsDayWise,
        queryParameters: query.toQueryParameters(),
      );
      final body = response.data;
      // Preferred shape: { startDate, endDate, days: [{ reportDate, rows: [...] }] }
      if (body is Map && body['days'] is List) {
        return DayWiseReport.fromJson(body.cast<String, dynamic>());
      }
      // Fallback: legacy flat-list shape — wrap it in a single anonymous day.
      final flat = _extractRows(body)
          .map(DayWiseRow.fromJson)
          .toList(growable: false);
      return DayWiseReport.fromFlatRows(flat);
    } on DioException catch (e) {
      throw ApiException.fromDio(e,
          fallback: 'Could not load datewise report');
    }
  }

  /// Downloads the day-wise report as XLSX. Picks a user-visible location
  /// when the platform exposes one (`Downloads/`), otherwise falls back to the
  /// app documents directory. Returns the saved file path.
  Future<String> downloadDayWiseExcel(DayWiseQuery query) async {
    try {
      final dir = await _pickDownloadDir();
      final stamp = DateTime.now().millisecondsSinceEpoch;
      final filePath =
          '${dir.path}${Platform.pathSeparator}day-wise-report-$stamp.xlsx';
      await _dio.download(
        ApiEndpoints.reportsDayWiseDownload,
        filePath,
        queryParameters: query.toQueryParameters(),
        options: Options(
          responseType: ResponseType.bytes,
          followRedirects: true,
        ),
      );
      return filePath;
    } on DioException catch (e) {
      throw ApiException.fromDio(e, fallback: 'Could not download report');
    }
  }

  /// Best-effort user-visible save location.
  ///   - Android: app-scoped external storage (visible via Files app under
  ///     `Android/data/<package>/files`). Falls back to app docs.
  ///   - iOS: app documents directory (visible via Files app under "On My iPhone").
  ///   - Desktop/Linux/macOS/Windows: real Downloads folder.
  Future<Directory> _pickDownloadDir() async {
    if (Platform.isAndroid) {
      final ext = await getExternalStorageDirectory();
      if (ext != null) return ext;
    } else if (!Platform.isIOS) {
      final downloads = await getDownloadsDirectory();
      if (downloads != null) return downloads;
    }
    return getApplicationDocumentsDirectory();
  }

  static List<Map<String, dynamic>> _extractRows(dynamic body) {
    if (body is List) return _coerceMaps(body);
    if (body is Map) {
      final m = body.cast<String, dynamic>();
      final content = m['content'];
      if (content is List) return _coerceMaps(content);
      final data = m['data'];
      if (data is List) return _coerceMaps(data);
      final rows = m['rows'];
      if (rows is List) return _coerceMaps(rows);
      final embedded = m['_embedded'];
      if (embedded is Map) {
        for (final v in embedded.values) {
          if (v is List) return _coerceMaps(v);
        }
      }
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
