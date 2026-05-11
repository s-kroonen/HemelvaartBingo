// features/core/network/socket_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

import 'api_client.dart';

final socketProvider = Provider.family<IO.Socket, String>((ref, matchId) {
  final socket = IO.io(apiBaseUrl, IO.OptionBuilder()
      .setTransports(['websocket'])
      .enableAutoConnect()
      .build());

  socket.onConnect((_) {
    // Join the specific match room
    socket.emit('joinMatch', matchId);
  });

  ref.onDispose(() {
    socket.emit('leaveMatch', matchId);
    socket.dispose();
  });

  return socket;
});