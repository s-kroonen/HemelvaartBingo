// features/core/network/socket_provider.dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'api_client.dart'; // Assuming apiBaseUrl is here

final socketProvider = FutureProvider.family<IO.Socket, String>((
  ref,
  matchId,
) async {
  final user = FirebaseAuth.instance.currentUser;
  if (user == null) throw Exception("User not authenticated");

  // 1. Get the latest Firebase ID Token
  final token = await user.getIdToken();

  // 2. Clean the URL
  // Converts "https://api.com/api/v1" -> "https://api.com"
  final uri = Uri.parse(apiBaseUrl);
  final baseUrl =
      "${uri.scheme}://${uri.host}${uri.hasPort ? ':${uri.port}' : ''}";

  // 3. Initialize Socket with Auth Headers
  final socket = IO.io(
    baseUrl,
    IO.OptionBuilder()
        .setTransports(['websocket'])
        .setExtraHeaders({
          'Authorization': 'Bearer $token', // Standard Bearer token
        })
        // Optional: use 'auth' instead if your NestJS gateway looks there
        .setAuth({'token': token})
        .enableAutoConnect()
        .build(),
  );

  socket.onConnect((_) {
    socket.emit('joinMatch', {
      'matchId': matchId,
    });
  });

  // Handle disposal
  ref.onDispose(() {
    socket.emit('leaveMatch', {
      'matchId': matchId,
    });
    socket.dispose();
  });

  return socket;
});
