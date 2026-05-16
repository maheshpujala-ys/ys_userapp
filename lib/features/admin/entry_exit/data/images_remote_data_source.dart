import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yellowspotuser/core/network/api_endpoints.dart';
import 'package:yellowspotuser/core/network/api_exception.dart';
import 'package:yellowspotuser/core/providers/app_providers.dart';

/// Gateway to `/api/v1/images/preview/{imageId}` — returns a short-lived
/// presigned S3 URL the client can hit directly with `Image.network`.
class ImagesRemoteDataSource {
  ImagesRemoteDataSource(this._dio);

  final Dio _dio;

  /// Fetch a presigned preview URL for the given image id.
  /// Accepts a few response shapes defensively:
  ///   - `{"url": "https://..."}` (the documented shape)
  ///   - `{"previewUrl": "..."}` / `{"signedUrl": "..."}`
  ///   - plain string body
  ///   - 302 redirect (returns the Location header)
  Future<String> getPreviewUrl(String imageId) async {
    try {
      final response = await _dio.get<dynamic>(
        ApiEndpoints.imagePreview(imageId),
        options: Options(
          followRedirects: false,
          validateStatus: (code) =>
              code != null && (code >= 200 && code < 400),
        ),
      );

      // Redirect case — the URL lives in the Location header.
      if (response.statusCode != null &&
          response.statusCode! >= 300 &&
          response.statusCode! < 400) {
        final loc = response.headers.value('location');
        if (loc != null && loc.isNotEmpty) return loc;
      }

      final data = response.data;
      if (data is String && data.isNotEmpty) return data;
      if (data is Map) {
        final m = data.cast<String, dynamic>();
        for (final key in ['url', 'previewUrl', 'signedUrl', 'href']) {
          final v = m[key];
          if (v is String && v.isNotEmpty) return v;
        }
      }
      throw ApiException(
          message: 'Image preview response missing URL',
          statusCode: response.statusCode);
    } on DioException catch (e) {
      throw ApiException.fromDio(e, fallback: 'Could not load image');
    }
  }
}

final imagesRemoteDataSourceProvider = Provider<ImagesRemoteDataSource>(
  (ref) => ImagesRemoteDataSource(ref.watch(dioProvider)),
);

/// Cached preview-URL provider keyed by image id. Avoids re-fetching the
/// presigned URL on every rebuild of the preview screen.
final imagePreviewUrlProvider =
    FutureProvider.autoDispose.family<String, String>((ref, imageId) {
  return ref.watch(imagesRemoteDataSourceProvider).getPreviewUrl(imageId);
});
