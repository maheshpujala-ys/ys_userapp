import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

typedef OnUnauthorizedCallback = void Function();

class DioInterceptor extends Interceptor {
  final FlutterSecureStorage _secureStorage;
  final OnUnauthorizedCallback? onUnauthorized;

  DioInterceptor(this._secureStorage, {this.onUnauthorized});

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    options.connectTimeout = 15000;
    options.receiveTimeout = 15000;
    options.sendTimeout = 15000;

    final token = await _secureStorage.read(key: 'auth_token');
    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    options.headers['Accept'] = 'application/json';
    options.headers['X-Client-Version'] = '2.0.0';
    super.onRequest(options, handler);
  }

  @override
  void onError(DioError err, ErrorInterceptorHandler handler) async {
    if (err.response?.statusCode == 401) {
      // Clear stored credentials on unauthorized
      await _secureStorage.delete(key: 'auth_token');
      onUnauthorized?.call();
    }
    super.onError(err, handler);
  }
}
