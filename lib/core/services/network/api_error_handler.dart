import 'package:dio/dio.dart';

class ApiException implements Exception {
  final int? statusCode;
  final String message;
  final String? code;
  final dynamic details;

  const ApiException({
    this.statusCode,
    required this.message,
    this.code,
    this.details,
  });

  @override
  String toString() => message;
}

class ApiErrorHandler {
  static ApiException fromDioError(DioError error) {
    if (error.type == DioErrorType.connectTimeout ||
        error.type == DioErrorType.receiveTimeout ||
        error.type == DioErrorType.sendTimeout) {
      return const ApiException(
        statusCode: 408,
        message: 'Connection timed out. Please check your internet connectivity.',
        code: 'TIMEOUT',
      );
    }

    if (error.type == DioErrorType.other) {
      return const ApiException(
        statusCode: null,
        message: 'No internet connection detected. Please verify your network.',
        code: 'NETWORK_OFFLINE',
      );
    }

    final response = error.response;
    if (response == null) {
      return const ApiException(
        statusCode: null,
        message: 'Unexpected network error occurred. Please try again.',
        code: 'UNKNOWN_NETWORK_ERROR',
      );
    }

    final statusCode = response.statusCode;
    final data = response.data;
    String serverMsg = '';

    if (data is Map<String, dynamic>) {
      serverMsg = data['message']?.toString() ?? data['error']?.toString() ?? '';
    }

    switch (statusCode) {
      case 400:
        return ApiException(
          statusCode: 400,
          message: serverMsg.isNotEmpty ? serverMsg : 'Invalid request. Please check input parameters.',
          code: 'BAD_REQUEST',
        );
      case 401:
        return const ApiException(
          statusCode: 401,
          message: 'Your session has expired. Please log in again.',
          code: 'UNAUTHORIZED',
        );
      case 403:
        return const ApiException(
          statusCode: 403,
          message: 'Access denied. You do not have permission for this resource.',
          code: 'FORBIDDEN',
        );
      case 404:
        return ApiException(
          statusCode: 404,
          message: serverMsg.isNotEmpty ? serverMsg : 'Requested resource was not found.',
          code: 'NOT_FOUND',
        );
      case 409:
        return ApiException(
          statusCode: 409,
          message: serverMsg.isNotEmpty ? serverMsg : 'Booking conflict detected. The slot or resource is already reserved.',
          code: 'CONFLICT',
        );
      case 422:
        return ApiException(
          statusCode: 422,
          message: serverMsg.isNotEmpty ? serverMsg : 'Validation error. Please verify the submitted data.',
          code: 'UNPROCESSABLE_ENTITY',
          details: data,
        );
      case 429:
        return const ApiException(
          statusCode: 429,
          message: 'Too many requests. Please slow down and try again in a few moments.',
          code: 'RATE_LIMIT_EXCEEDED',
        );
      case 500:
        return const ApiException(
          statusCode: 500,
          message: 'YellowSpot server encountered an internal error. Please try again shortly.',
          code: 'INTERNAL_SERVER_ERROR',
        );
      case 503:
        return const ApiException(
          statusCode: 503,
          message: 'Service is temporarily undergoing maintenance. Please check back soon.',
          code: 'SERVICE_UNAVAILABLE',
        );
      default:
        return ApiException(
          statusCode: statusCode,
          message: serverMsg.isNotEmpty ? serverMsg : 'Network request failed ($statusCode).',
          code: 'HTTP_$statusCode',
        );
    }
  }
}
