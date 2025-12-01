import 'package:socket_io_client/socket_io_client.dart' as IO;

class SocketService {
  late IO.Socket socket;

  void initSocket(String userType, int id) {
    // ⚡ Connect to your Node.js server
    socket = IO.io("http://localhost:5000", <String, dynamic>{
      "transports": ["websocket"],   // force websocket (recommended)
      "autoConnect": false,
    });

    // When connected
    socket.onConnect((_) {
      print("✅ Connected to Socket.IO server");
      // Join user/doctor room
      socket.emit("join", {"type": userType, "id": id});
    });

    // Listen for booking notifications
    socket.on("bookingNotification", (data) {
      print("📢 New Booking Notification: $data");
      // Here you can update UI, show snackbar, or push notification
    });

    // On disconnect
    socket.onDisconnect((_) {
      print("❌ Disconnected from Socket.IO server");
    });

    socket.connect();
  }

  void disconnect() {
    socket.disconnect();
  }
}
