import 'dart:async';

/// Placeholder for real-time admin dashboard updates.
///
/// Previously this emitted random mock values every 5 seconds, which overwrote
/// the real stats fetched from `/api/v1/dashboard/stats`. The mock has been
/// neutralized — the broadcast stream is kept alive (so `AdminController`'s
/// `webSocketStream?.listen(...)` wiring still works), but no events are
/// emitted until a real WebSocket endpoint is plugged in here.
class WebSocketService {
  StreamController<Map<String, dynamic>>? _controller;

  Stream<Map<String, dynamic>> get stream {
    _controller ??= StreamController<Map<String, dynamic>>.broadcast();
    return _controller!.stream;
  }

  /// No-op for now. Wire a real WebSocket client (e.g. `web_socket_channel`)
  /// when the backend exposes a URL, and forward incoming dashboard payloads
  /// onto `_controller`.
  void connect() {
    _controller ??= StreamController<Map<String, dynamic>>.broadcast();
  }

  void disconnect() {
    // Nothing to tear down while the mock is disabled.
  }

  void dispose() {
    disconnect();
    _controller?.close();
    _controller = null;
  }
}
