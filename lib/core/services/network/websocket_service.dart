import 'dart:async';
import 'dart:math';

class WebSocketService {
  final _socketController = StreamController<Map<String, dynamic>>.broadcast();
  Timer? _timer;

  Stream<Map<String, dynamic>> get stream => _socketController.stream;

  void connect() {
    // In a real app, you would connect to your WebSocket server here.
    _timer = Timer.periodic(const Duration(seconds: 5), (_) {
      // Simulate receiving a real-time update from the WebSocket.
      _socketController.add({
        'residents': 480 + Random().nextInt(5),
        'vehicles': 650 + Random().nextInt(5),
        'parking': 78 + Random().nextInt(5),
        'pending': 5 + Random().nextInt(5),
      });
    });
  }

  void disconnect() {
    _timer?.cancel();
    _socketController.close();
  }
}
