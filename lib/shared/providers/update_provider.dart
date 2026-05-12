import 'dart:js_interop';

import 'package:flutter_riverpod/legacy.dart';
import 'package:web/web.dart' as web;

final updateProvider = StateNotifierProvider<UpdateNotifier, bool>((ref) {
  return UpdateNotifier();
});

class UpdateNotifier extends StateNotifier<bool> {
  UpdateNotifier() : super(false) {
    _init();
  }

  void _init() {
    // Listen for the custom event from index.html
    web.window.addEventListener('pwa_update_available', (web.Event event) {
      state = true;
    }.toJS); // Correct way to handle JS callbacks in modern Flutter
  }

  void activateUpdate() {
    // Signal index.html to trigger skipWaiting
    web.window.dispatchEvent(web.CustomEvent('pwa_activate_update'));
  }
}