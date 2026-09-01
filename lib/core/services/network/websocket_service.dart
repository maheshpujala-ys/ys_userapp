import 'dart:async';
import 'dart:math';

enum WebSocketConnectionState {
  disconnected,
  connecting,
  connected,
  reconnecting,
}

class WebSocketService {
  final _socketController = StreamController<Map<String, dynamic>>.broadcast();
  final _connectionStateController = StreamController<WebSocketConnectionState>.broadcast();
  Timer? _heartbeatTimer;
  Timer? _reconnectTimer;
  bool _isDisposed = false;
  WebSocketConnectionState _currentState = WebSocketConnectionState.disconnected;

  Stream<Map<String, dynamic>> get stream => _socketController.stream;
  Stream<WebSocketConnectionState> get connectionStateStream => _connectionStateController.stream;
  WebSocketConnectionState get currentState => _currentState;

  void _setState(WebSocketConnectionState state) {
    if (_isDisposed) return;
    _currentState = state;
    _connectionStateController.add(state);
  }

  void connect({String? authToken}) {
    if (_isDisposed || _currentState == WebSocketConnectionState.connected) return;

    _setState(WebSocketConnectionState.connecting);

    // Simulated connection establishment with token authentication
    _reconnectTimer?.cancel();
    _reconnectTimer = Timer(const Duration(milliseconds: 500), () {
      if (_isDisposed) return;
      _setState(WebSocketConnectionState.connected);
      _startHeartbeat();
    });
  }

  void _startHeartbeat() {
    _heartbeatTimer?.cancel();
    _heartbeatTimer = Timer.periodic(const Duration(seconds: 8), (_) {
      if (_isDisposed || _currentState != WebSocketConnectionState.connected) return;

      // Broadcast simulated real-time event updates
      _socketController.add({
        'type': 'METRICS_UPDATE',
        'timestamp': DateTime.now().toIso8601String(),
        'data': {
          'availableParking': 70 + Random().nextInt(15),
          'evChargersInUse': 3 + Random().nextInt(3),
          'activeVisitors': 12 + Random().nextInt(5),
          'pendingDeliveries': 2 + Random().nextInt(3),
        },
      });
    });
  }

  void disconnect() {
    _heartbeatTimer?.cancel();
    _reconnectTimer?.cancel();
    _setState(WebSocketConnectionState.disconnected);
  }

  void dispose() {
    _isDisposed = true;
    disconnect();
    _socketController.close();
    _connectionStateController.close();
  }
}
