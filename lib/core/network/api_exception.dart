import 'package:dio/dio.dart';

/// Domain-friendly error: hides Dio so the UI / VMs don't import it.
class ApiException implements Exception {
  ApiException({required this.message, this.statusCode});

  factory ApiException.fromDio(DioException e, {required String fallback}) {
    final code = e.response?.statusCode;
    final data = e.response?.data;
    String? msg;
    if (data is Map && data['message'] is String) {
      msg = data['message'] as String;
    } else if (data is Map && data['error'] is String) {
      msg = data['error'] as String;
    } else if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.receiveTimeout ||
        e.type == DioExceptionType.sendTimeout) {
      msg = 'Network timeout — please try again';
    } else if (e.type == DioExceptionType.connectionError) {
      msg = 'Cannot reach the server';
    }
    return ApiException(message: msg ?? fallback, statusCode: code);
  }

  final String message;
  final int? statusCode;

  @override
  String toString() => message;
}
