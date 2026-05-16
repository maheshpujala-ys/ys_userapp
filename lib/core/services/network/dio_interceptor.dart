import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

const String kAuthTokenKey = 'auth_token';

/// Interceptor that caches the auth token in memory after the first read,
/// so we don't hit the platform-channel-backed secure storage on every request.
class DioInterceptor extends Interceptor {
  DioInterceptor(this._secureStorage);

  final FlutterSecureStorage _secureStorage;
  String? _cachedToken;
  bool _hydrated = false;

  /// Call after login/signup to push the freshly issued token into the cache,
  /// so the very next request uses it without a storage round-trip.
  void setToken(String? token) {
    _cachedToken = token;
    _hydrated = true;
  }

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    if (!_hydrated) {
      _cachedToken = await _secureStorage.read(key: kAuthTokenKey);
      _hydrated = true;
    }
    final token = _cachedToken;
    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (err.response?.statusCode == 401) {
      // Token rejected — invalidate cache so the next request re-reads storage.
      _cachedToken = null;
      _hydrated = false;
    }
    handler.next(err);
  }
}
