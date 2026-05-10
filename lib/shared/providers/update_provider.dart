// lib/shared/providers/update_provider.dart
import 'dart:html' as html; // ignore: avoid_web_libraries_in_flutter
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

final updateProvider = StateNotifierProvider<UpdateNotifier, bool>((ref) {
  return UpdateNotifier();
});

class UpdateNotifier extends StateNotifier<bool> {
  UpdateNotifier() : super(false) {
    _init();
  }

  void _init() {
    // Listen for the custom JS event we'll add to index.html
    html.window.addEventListener('pwa_update_available', (event) {
      state = true;
    });
  }

  void activateUpdate() {
    // Tell the Service Worker to skipWaiting
    html.window.dispatchEvent(new html.CustomEvent('pwa_activate_update'));
  }
}