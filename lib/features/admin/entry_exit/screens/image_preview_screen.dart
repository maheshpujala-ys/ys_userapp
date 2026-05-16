import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yellowspotuser/features/admin/entry_exit/data/images_remote_data_source.dart';

/// Full-screen viewer for a vehicle entry/exit snapshot.
/// Resolves a presigned URL via `/api/v1/images/preview/{imageId}` then loads
/// the image directly from S3. Pinch-zoomable.
class ImagePreviewScreen extends ConsumerWidget {
  const ImagePreviewScreen({
    super.key,
    required this.imageId,
    this.title,
  });

  final String imageId;

  /// Optional title (e.g. the vehicle number) shown in the app bar.
  final String? title;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final urlAsync = ref.watch(imagePreviewUrlProvider(imageId));

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: Text(title ?? 'Snapshot'),
      ),
      body: urlAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(color: Colors.white),
        ),
        error: (e, _) => _ErrorState(
          message: e.toString(),
          onRetry: () => ref.invalidate(imagePreviewUrlProvider(imageId)),
        ),
        data: (url) => Center(
          child: InteractiveViewer(
            minScale: 1,
            maxScale: 5,
            child: Image.network(
              url,
              fit: BoxFit.contain,
              loadingBuilder: (context, child, progress) {
                if (progress == null) return child;
                final total = progress.expectedTotalBytes;
                final loaded = progress.cumulativeBytesLoaded;
                return Center(
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    value: total != null ? loaded / total : null,
                  ),
                );
              },
              errorBuilder: (context, error, _) => _ErrorState(
                message: 'Image failed to load: $error',
                onRetry: () =>
                    ref.invalidate(imagePreviewUrlProvider(imageId)),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.broken_image_outlined,
                size: 64, color: Colors.white70),
            const SizedBox(height: 12),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white70),
            ),
            const SizedBox(height: 16),
            OutlinedButton.icon(
              style: OutlinedButton.styleFrom(foregroundColor: Colors.white),
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}
